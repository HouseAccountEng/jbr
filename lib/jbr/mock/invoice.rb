module Jbr
  # An invoice that reads from {Jbr.mock} instead of Jobber.
  class Mock::Invoice < Invoice
    # @return [Mock::Invoice] itself, carrying the mocked IDs and total.
    def find(_)
      @id = Jbr.mock.invoice[:id]
      @job_id = Jbr.mock.invoice[:job_id]
      @total = Jbr.mock.invoice[:total]

      self
    end

    # @return [Time, nil] the dates the app asked for.
    def issued_at = Jbr.mock.invoice[:issued_at]

    def completed_at = Jbr.mock.invoice[:completed_at]
  end
end
