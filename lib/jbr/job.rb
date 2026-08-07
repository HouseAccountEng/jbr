module Jbr
  # Work a Jobber user accepted and scheduled.
  class Job < Resource
    # The query that reads one job, its quote and its two timestamps.
    FIND = <<~GRAPHQL
      query($id: EncodedId!) {
        job(id: $id) { id quote { id } startAt completedAt }
      }
    GRAPHQL

    # @return [String, nil] the ID of the quote the job was won with.
    attr_reader :quote_id

    # @param id [String] the Jobber ID of the job.
    # @return [Job, nil] itself, or nil when Jobber has no such job.
    def find(id)
      output = @oauth.query FIND, variables: { id: id  }
      return unless job = output['job']

      @id = job['id']
      @quote_id = job.dig 'quote', 'id'
      @scheduled_at = job['startAt']
      @completed_at = job['completedAt']
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
