module Jbr
  # The quotes on a Jobber account, each reached by the ID Jobber files it under.
  class Quotes < Reader
    # The query that reads one quote, what it comes to, and the request it came from.
    FIND = <<~GRAPHQL
      query($id: EncodedId!) {
        quote(id: $id) { id amounts { total } request { id } }
      }
    GRAPHQL

    # @param id [String] Jobber ID of the quote.
    # @return [Quote, nil] nil when Jobber has no quote under that ID.
    def find(id)
      node = @account.query(FIND, variables: { id: id })['quote']
      Quote.new node: node if node
    end
  end
end
