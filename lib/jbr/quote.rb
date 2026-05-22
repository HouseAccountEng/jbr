module Jbr
  class Quote < Resource
    FIND = <<~GRAPHQL.freeze
      query($id: EncodedId!) {
        quote(id: $id) { id request { id } }
      }
    GRAPHQL

    attr_reader :request_id

    def find(id)
      output = @oauth.query FIND, variables: { id: id  }
      return unless quote = output['quote']

      @id = quote['id']
      @request_id = quote.dig 'request', 'id'
      self
    end
  end
end
