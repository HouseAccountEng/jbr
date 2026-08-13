module Jbr
  # What every Jobber resource shares: the node Jobber answered with, the credentials it was
  # read through, and the paging that every list of them arrives in.
  class Resource
    # @param oauth [OAuth] the credentials to reach Jobber with, where reaching it is needed.
    # @param node [Hash] the record as Jobber answered it.
    # @param includes [Hash] what a list was asked to bring back beside its records.
    def initialize(oauth: nil, node: {}, includes: {})
      @oauth = oauth
      @node = node
      @id = node['id']
      @includes = includes
    end

    # @return [String, nil] the Jobber ID, from the node it came in or once one was created.
    attr_reader :id

  private

    # @return [Time, nil] what Jobber answered under a key, as a time.
    def time(key) = (Time.iso8601 @node[key] if @node[key])

    # Every item a paged query answers, one at a time, a page read only once the one before
    # it runs out. The filter is data: handed none, the query narrows nothing.
    def walk(filter = nil)
      Enumerator.new do |yielder|
        after = nil
        loop do
          answered = @oauth.query(page, variables: { after: after, filter: filter }.compact)
          current = answered.fetch field, {}
          current.fetch('nodes', []).each { |node| yielder << item(node) }
          break unless current.dig 'pageInfo', 'hasNextPage'

          after = current.dig 'pageInfo', 'endCursor'
        end
      end
    end

    # The two halves of a schedule, split at the moment they are asked for rather than per
    # page: read page by page the boundary would slide, and something could cross it unseen.
    def from_now = { startAt: { after: Time.now.iso8601 } }

    def until_now = { startAt: { before: Time.now.iso8601 } }
  end
end
