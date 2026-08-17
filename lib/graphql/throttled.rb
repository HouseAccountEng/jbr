module GraphQL
  # An endpoint refusing a query for what it costs rather than for anything about the query
  # itself. Worth telling apart: the same query may be answered a moment later.
  class Throttled < Error
  end
end
