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

  private

    # Forty a page, not a hundred: Jobber prices a query by its page size and refuses the
    # wider one, and what an includes brings back is charged for on top.
    def page
      <<~GRAPHQL
        query($after: String, $filter: VisitFilterAttributes) {
          visits(first: 40, after: $after, filter: $filter) {
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
