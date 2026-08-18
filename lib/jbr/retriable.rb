module Jbr
  # Jobber refusing a query over what it costs rather than over anything about the query. The
  # bucket it is priced against refills, so the same question asked later is answered.
  class Retriable < Error
    # @param message [String] what Jobber said, with the numbers it said it with.
    # @param cost [Hash] the `requestedQueryCost` and the `throttleStatus` beside it.
    def initialize(message, cost = {})
      super message
      status = cost['throttleStatus'].to_h
      @cost = cost['requestedQueryCost']
      @available = status['currentlyAvailable']
      @maximum = status['maximumAvailable']
      @restore_rate = status['restoreRate']
    end

    # What the query would have cost, the budget it was priced against, and how fast that
    # budget refills. A cost above the maximum is one no waiting will pay for.
    attr_reader :cost, :available, :maximum, :restore_rate
  end
end
