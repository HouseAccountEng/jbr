module GraphQL
  # An endpoint refusing a query for what it costs rather than for anything about the query
  # itself. Worth telling apart: the same query is answered once the budget it is priced
  # against has refilled.
  class Throttled < Error
  end
end
