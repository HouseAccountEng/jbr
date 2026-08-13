module Jbr
  # How much Jobber will still answer, and how long to wait before asking again. Jobber holds
  # an app to two limits at once, and this keeps both: a count of requests over a window, and
  # a bucket of query cost that drains as it is asked and refills at a rate it reports.
  class Throttle
    # Jobber answers 2,500 requests every 5 minutes, which is one every 0.12 seconds. Spacing
    # them is what keeps a walk of many pages under the count, whatever each page costs.
    SPACING = 300.0 / 2_500

    # @return [Float] the seconds waited, which is zero where nothing was owed.
    def wait
      owed = [ spacing_owed, restore_owed ].max
      sleep owed if owed.positive?
      @asked_at = Time.now
      owed
    end

    # Takes in what the answer said it had left. Jobber reports the bucket beside the data,
    # so what the next caller may ask for is known before they ask for it.
    # @param extensions [Hash, nil] the +extensions+ Jobber answered beside the data.
    def read(extensions)
      cost = extensions.to_h['cost'].to_h
      status = cost['throttleStatus'].to_h
      @cost = cost['actualQueryCost'].to_f
      @available = status['currentlyAvailable'].to_f
      @restore_rate = status['restoreRate'].to_f
    end

  private

    # Nothing is owed to the first caller: a request that follows no other is not too soon.
    def spacing_owed = (@asked_at ? [ SPACING - (Time.now - @asked_at), 0.0 ].max : 0.0)

    # What the last answer cost is what the next one is taken to cost, since a walk asks the
    # same query of every page. Where the bucket cannot pay for it, wait for it to refill.
    def restore_owed
      return 0.0 unless @restore_rate.to_f.positive? && @available.to_f < @cost.to_f

      (@cost - @available) / @restore_rate
    end
  end
end
