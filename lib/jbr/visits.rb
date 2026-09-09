module Jbr
  # The visits on a Jobber account, oldest first, walked a page at a time.
  class Visits < Collection
    include Includable, Listable

    # What a visit answers with, before anything it was asked to bring back with it: the keys
    # the vocabulary reads, none written by hand.
    FIELDS = Visit.node_keys.join ' '

    # Shadows Enumerable#find on purpose, the way jobs do: a visit is reached by the ID Jobber
    # files it under, not by asking every visit on the account whether it is the one.
    # @param id [String] Jobber ID of the visit.
    # @return [Visit, nil] nil when Jobber has no visit under that ID.
    def find(id)
      node = @account.query(one, variables: { id: id })['visit']
      Visit.new node: node if node
    end

  private

    def page = paged "#{FIELDS} #{selections}", PAGE

    def one
      <<~GRAPHQL
        query($id: EncodedId!) {
          visit(id: $id) { #{FIELDS} #{selections} }
        }
      GRAPHQL
    end

    def field = 'visits'

    def filtered = 'VisitFilterAttributes'

    def item(node) = Visit.new node: node
  end
end
