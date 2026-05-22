module Jbr
  class Job < Resource
    FIND = <<~GRAPHQL.freeze
      query($id: EncodedId!) {
        job(id: $id) { id quote { id } startAt completedAt }
      }
    GRAPHQL

    attr_reader :quote_id

    def find(id)
      output = @oauth.query FIND, variables: { id: id  }
      @id = output.dig 'job', 'id'
      @quote_id = output.dig 'job', 'quote', 'id'
      @scheduled_at = output.dig 'job', 'startAt'
      @completed_at = output.dig 'job', 'completedAt'
      self
    end

    # @return [Time] the job scheduled time
    def scheduled_at
      Time.iso8601(@scheduled_at) if @scheduled_at
    end

    # @return [Time] the job completed time
    def completed_at
      Time.iso8601(@completed_at) if @completed_at
    end
  end
end
