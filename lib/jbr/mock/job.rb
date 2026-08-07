module Jbr
  # A job that reads from {Jbr.mock} instead of Jobber.
  class Mock::Job < Job
    # @return [Mock::Job] itself, carrying the mocked IDs.
    def find(_)
      @id = Jbr.mock.job[:id]
      @quote_id = Jbr.mock.job[:quote_id]

      self
    end

    # @return [Time, nil] the times the app asked for.
    def scheduled_at = Jbr.mock.job[:scheduled_at]

    def completed_at = Jbr.mock.job[:completed_at]
  end
end
