module Jbr
  # What every Jobber resource shares: the node Jobber answered with, the credentials it was
  # read through, and what a list of them was asked and narrowed to.
  class Resource
    # @param oauth [OAuth] the credentials to reach Jobber with, where reaching it is needed.
    # @param node [Hash] the record as Jobber answered it.
    # @param includes [Hash] what a list was asked to bring back beside its records.
    # @param filter [Hash] what a list was narrowed to, in the shape Jobber filters by.
    def initialize(oauth: nil, node: {}, includes: {}, filter: nil)
      @oauth = oauth
      @node = node
      @id = node['id']
      @includes = includes
      @filter = filter
    end

    # @return [String, nil] the Jobber ID, from the node it came in or once one was created.
    attr_reader :id

  private

    # @return [Time, nil] what Jobber answered under a key, as a time. An empty answer is no
    #   answer: Time.iso8601 raises on one, where nothing at all it simply has none of.
    def time(key) = (Time.iso8601 @node[key] if @node[key].present?)
  end
end
