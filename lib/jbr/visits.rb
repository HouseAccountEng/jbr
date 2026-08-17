module Jbr
  # The visits on a Jobber account, oldest first, walked a page at a time.
  class Visits < Resource
    include Enumerable, Includable

    # What a visit answers with, before anything it was asked to bring back with it.
    FIELDS = 'id title startAt endAt allDay clientConfirmed job { id }'

    # Every visit on the account, past and future alike. Nothing is read until the walk
    # starts, and a page is read only once the one before it runs out.
    def each(&) = walk.each(&)

    # @return [Enumerator<Visit>] the visits scheduled from now on.
    def upcoming = walk from_now

    # @return [Enumerator<Visit>] the visits that started before now.
    def past = walk until_now

    # Shadows Enumerable#find on purpose, the way jobs do: a visit is reached by the ID Jobber
    # files it under, not by asking every visit on the account whether it is the one.
    # @param id [String] the Jobber ID of the visit.
    # @return [Visit, nil] nil when Jobber has no visit under that ID.
    def find(id)
      node = @oauth.query(one, variables: { id: id })['visit']
      Visit.new node: node if node
    end

  private

    def one
      <<~GRAPHQL
        query($id: EncodedId!) {
          visit(id: $id) { #{FIELDS} #{selections} }
        }
      GRAPHQL
    end

    # Twenty a page, the same as jobs: Jobber prices a query by its page size, and what an
    # includes brings back is charged for on top of every row of it.
    def page
      <<~GRAPHQL
        query($after: String, $filter: VisitFilterAttributes) {
          visits(first: 20, after: $after, filter: $filter) {
            nodes { #{FIELDS} #{selections} }
            pageInfo { hasNextPage endCursor }
          }
        }
      GRAPHQL
    end

    def field = 'visits'

    def item(node) = Visit.new node: node
  end
end
