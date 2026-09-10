module Jbr
  # The visits on a Jobber account, oldest first, walked a page at a time.
  class Visits < Collection
    include Listable

    # What a visit answers with: the keys the vocabulary reads, and the job it belongs to.
    FIELDS = "#{Visit.node_keys.join ' '} job { id }"

    # Shadows Enumerable#find on purpose, the way jobs do: a visit is reached by the ID Jobber
    # files it under, not by asking every visit on the account whether it is the one.
    # @param id [String] Jobber ID of the visit.
    # @return [Visit, nil] nil when Jobber has no visit under that ID.
    def find(id)
      node = @account.query(one, variables: { id: id })['visit']
      Visit.new node: node if node
    end

  private

    def page = paged FIELDS, PAGE

    def one
      <<~GRAPHQL
        query($id: EncodedId!) {
          visit(id: $id) { #{FIELDS} }
        }
      GRAPHQL
    end

    def field = 'visits'

    def filtered = 'VisitFilterAttributes'

    def item(node) = Visit.new node: node
  end
end
