module Jbr
  # A quote that reads from {Jbr.mock} instead of Jobber.
  class Mock::Quote < Quote
    # @return [Mock::Quote] itself, carrying the mocked IDs.
    def find(_)
      @id = Jbr.mock.quote[:id]
      @request_id = Jbr.mock.quote[:request_id]

      self
    end
  end
end
