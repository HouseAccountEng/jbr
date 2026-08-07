module Jbr
  # A request that records what {Jbr.mock} was told to answer.
  class Mock::Request < Request
    # @return [Mock::Request] itself, carrying the mocked IDs.
    def create(_)
      @id = Jbr.mock.request[:id]
      @client_id = Jbr.mock.request[:client_id]

      self
    end
  end
end
