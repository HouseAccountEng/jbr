require 'test_helper'

# What reaches a caller when Jobber will not answer. Nothing here waits or asks again: a
# caller running this from a background job has a queue that will bring the whole job back,
# which is worth more than a worker asleep holding a transaction open.
class RefusalsTest < Minitest::Test
  def test_a_refusal_for_cost_says_what_the_query_would_have_cost
    stub = stub_request(:post, GRAPHQL_URL).to_return body: {
      errors: [ { message: 'Throttled' } ],
      extensions: { cost: { requestedQueryCost: 1_885,
                            throttleStatus: { maximumAvailable: 10_000,
                                              currentlyAvailable: 1_254,
                                              restoreRate: 500, }, } },
    }.to_json

    # Nothing waits and nothing asks again. The numbers are for whoever reads the log, and
    # the queue that brings a background job back is what will ask a second time
    error = assert_raises(Jbr::Error) { oauth.query '{ ok }' }

    assert_equal 'Throttled (cost 1885, 1254 of 10000 available, restoring 500/s)', error.message
    assert_requested stub, times: 1
  end

  def test_a_failure_that_is_not_about_cost_is_raised_rather_than_asked_again
    stub = stub_request(:post, GRAPHQL_URL).
      to_return body: { errors: [ { message: 'Field does not exist' } ] }.to_json

    # Jobber's own class never leaves the gem, so a caller rescuing Jbr::Error catches this
    # the way the README says it will. And asking again would only be told the same thing
    error = assert_raises(Jbr::Error) { oauth.query '{ nope }' }

    assert_equal 'Field does not exist', error.message
    assert_requested stub, times: 1
  end
end
