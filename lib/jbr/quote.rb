module Jbr
  # A price a Jobber user sent to their client.
  class Quote < Resource
    # The query that reads one quote and the request it came from.
    FIND = <<~GRAPHQL
      query($id: EncodedId!) {
        quote(id: $id) { id request { id } }
      }
    GRAPHQL

    # @return [String, nil] the ID of the request the quote answers.
    attr_reader :request_id

    # @param id [String] the Jobber ID of the quote.
    # @return [Quote, nil] itself, or nil when Jobber has no such quote.
    def find(id)
      output = @oauth.query FIND, variables: { id: id  }
      return unless quote = output['quote']

      @id = quote['id']
      @request_id = quote.dig 'request', 'id'
      self
    end
  end
end
