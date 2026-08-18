module GraphQL
  # An endpoint refusing a query for what it costs rather than for anything about the query
  # itself. Worth telling apart: the same query is answered once the budget it is priced
  # against has refilled.
  class Throttled < Error
    # @param message [String] what the endpoint said, with the numbers it said it with.
    # @param cost [Hash] what it priced the query at, and the budget it priced it against.
    def initialize(message, cost = {})
      super message
      @cost = cost
    end

    # @return [Hash] those numbers, in the endpoint's own words.
    attr_reader :cost
  end
end
