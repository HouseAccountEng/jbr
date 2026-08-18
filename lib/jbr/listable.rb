module Jbr
  # What a list of records answers, and how much of an account it costs to ask. Jobber prices
  # a query by the page it asks for and by what every row of that page carries, so a list is
  # read either as records or as the IDs alone, each with a page sized to what it carries.
  module Listable
    include Enumerable

    # Records a page, not forty and not a hundred: what an includes brings back is charged for
    # on top of every row of it, so a page of jobs carrying their lines, their property and its
    # client priced past what a bucket holds. Half the page costs half the query and loses
    # nothing, since a walk simply reads more pages.
    PAGE = 20

    # IDs a page, which the same budget affords five times over where a row carries one field
    # and no nesting at all.
    IDS_PAGE = 100

    # Every record the list is narrowed to, oldest first. Nothing is read until the walk
    # starts, and a page is read only once the one before it runs out.
    def each(&) = walk(page).each(&)

    # @return [Listable] the same list, narrowed to what is scheduled from now on.
    def upcoming = narrowed from_now

    # @return [Listable] the same list, narrowed to what started before now.
    def past = narrowed until_now

    # The ID Jobber files each record under, and nothing else about it: the cheapest question
    # an account can be walked with, and the one to ask where every record is then read on its
    # own through {#find}.
    # @return [Array<String>] every ID in the list, every page of them read.
    def ids = walk(ids_page).map(&:id)

  private

    def narrowed(filter) = self.class.new(oauth: @oauth, includes: @includes, filter: filter)

    # The two halves of a schedule, split at the moment they are asked for rather than per
    # page: read page by page the boundary would slide, and something could cross it unseen.
    def from_now = { startAt: { after: Time.now.iso8601 } }

    def until_now = { startAt: { before: Time.now.iso8601 } }

    # Every record a paged query answers, one at a time, a page read only once the one before
    # it runs out. The filter is data: narrowed to nothing, the query narrows nothing.
    def walk(statement)
      Enumerator.new do |yielder|
        after = nil
        loop do
          answered = @oauth.query statement, variables: { after: after, filter: @filter }.compact
          current = answered.fetch field, {}
          current.fetch('nodes', []).each { |node| yielder << item(node) }
          break unless current.dig 'pageInfo', 'hasNextPage'

          after = current.dig 'pageInfo', 'endCursor'
        end
      end
    end

    def ids_page = paged 'id', IDS_PAGE

    def paged(fields, size)
      <<~GRAPHQL
        query($after: String, $filter: #{filtered}) {
          #{field}(first: #{size}, after: $after, filter: $filter) {
            nodes { #{fields} }
            pageInfo { hasNextPage endCursor }
          }
        }
      GRAPHQL
    end
  end
end
