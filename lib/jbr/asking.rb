module Jbr
  # What credentials do when they ask Jobber something: pace the request against both limits
  # Jobber holds an app to, wait out a refusal it can recover from, and refresh a token that
  # went stale on the way.
  module Asking
    # How many times a query refused for cost is asked again. Once is the answer where the
    # bucket only had to refill, since the wait is worked out to cover exactly the shortfall.
    # The rest are for a bucket the whole app shares: another process may drain it again while
    # this one waits, and each attempt costs only the seconds Jobber says it needs.
    ATTEMPTS = 4

    # Run a statement, waiting for what Jobber will still answer and refreshing a stale token.
    # @return [Hash] the data Jobber answered, or empty when the credentials are dead.
    def query(statement, variables: {})
      attempts = 0
      begin
        throttle.wait
        client.query(statement, variables: variables) { |extensions| throttle.read extensions }
      rescue GraphQL::Unauthorized
        refresh ? retry : {}
      rescue GraphQL::Throttled => error
        # The refusal priced the query, so the throttle now knows the shortfall and `wait` at
        # the top of the retry sits out exactly that. Only a query costing more than the bucket
        # ever holds is hopeless; the rest is a walk that asked a moment too early.
        raise Error, error.message unless throttle.affordable? && (attempts += 1) < ATTEMPTS

        retry
      rescue GraphQL::Error => error
        # The transport's own class never leaves the gem: a caller told to rescue `Jbr::Error`
        # was not catching a throttle, a 500 or an unreadable answer, and had its own job blow
        # up instead of hearing that Jobber would not answer.
        raise Error, error.message
      end
    end

  private

    def throttle = @throttle ||= Throttle.new
  end
end
