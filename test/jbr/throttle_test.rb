require 'test_helper'

# Jobber holds an app to two limits at once: a count of requests over five minutes, and a
# bucket of query cost. A walk of many pages has to stay under both without being told to.
class ThrottleTest < Minitest::Test
  def setup = @throttle = Jbr::Throttle.new

  # A refusal for cost as Jobber answers one: what the query would have cost, and the bucket
  # it was priced against.
  def throttled(requested:, available:, maximum:, restore: 500)
    { errors: [ { message: 'Throttled', extensions: { code: 'THROTTLED' } } ],
      extensions: { cost: { requestedQueryCost: requested,
                            throttleStatus: { maximumAvailable: maximum,
                                              currentlyAvailable: available,
                                              restoreRate: restore, }, } },
    }.to_json
  end

  def test_the_first_request_waits_for_nothing
    assert_in_delta 0, @throttle.wait
  end

  def test_the_next_request_waits_out_the_space_between_two_of_them
    @throttle.wait
    waited = @throttle.wait

    assert waited.positive?
    assert_operator waited, :<=, Jbr::Throttle::SPACING
  end

  def test_a_bucket_that_covers_the_next_query_is_waited_on_no_further
    @throttle.read 'cost' => { 'actualQueryCost' => 10,
                               'throttleStatus' => { 'currentlyAvailable' => 9_000,
                                                     'restoreRate' => 500, }, }

    assert_operator @throttle.wait, :<=, Jbr::Throttle::SPACING
  end

  def test_a_bucket_too_low_for_the_next_query_is_waited_out_at_the_rate_it_refills
    @throttle.read 'cost' => { 'actualQueryCost' => 100,
                               'throttleStatus' => { 'currentlyAvailable' => 60,
                                                     'restoreRate' => 400, }, }

    # 40 points short at 400 a second is a tenth of a second. The delta is tight on purpose:
    # at 0.12 the spacing would be answering instead, and this asks about the bucket
    assert_in_delta 0.1, @throttle.wait, 0.015
  end

  def test_an_answer_that_says_nothing_about_cost_is_waited_on_no_further
    @throttle.read nil

    assert_in_delta 0, @throttle.wait
  end

  def test_a_query_costing_more_than_the_bucket_holds_is_refused_rather_than_waited_on
    stub = stub_request(:post, JobberStubs::GRAPHQL_URL).to_return body: throttled(
      requested: 12_400, available: 9_500, maximum: 10_000,
    )

    # Nothing refills to 12,400 in a bucket of 10,000, so asking again would only be refused
    # again. A caller told to rescue Jbr::Error hears about it, with the numbers to see why
    error = assert_raises(Jbr::Error) { oauth.jobs.to_a }

    assert_equal 'Throttled (cost 12400, 9500 of 10000 available, restoring 500/s)',
                 error.message
    assert_requested stub, times: 1
  end

  def test_a_refusal_the_bucket_can_recover_from_is_waited_out_and_asked_again
    page = { 'nodes' => [], 'pageInfo' => { 'hasNextPage' => false } }
    stub = stub_request(:post, JobberStubs::GRAPHQL_URL).
      to_return({ body: throttled(requested: 100, available: 60, maximum: 10_000) },
                { body: { data: { 'jobs' => page } }.to_json })

    # 40 points short of a query the bucket holds twenty times over: wait for the shortfall to
    # refill at the rate Jobber reports, then ask the same question and be answered
    started = Time.now

    assert_empty oauth.jobs.to_a
    assert_operator Time.now - started, :>=, 0.1
    assert_requested stub, times: 2
  end

  def test_a_walk_paces_itself_between_pages
    page = { 'nodes' => [], 'pageInfo' => { 'hasNextPage' => true, 'endCursor' => 'a' } }
    last = { 'nodes' => [], 'pageInfo' => { 'hasNextPage' => false } }
    stub_request(:post, JobberStubs::GRAPHQL_URL).
      to_return({ body: { data: { 'visits' => page } }.to_json },
                { body: { data: { 'visits' => last } }.to_json })

    started = Time.now
    oauth.visits.to_a

    assert_operator Time.now - started, :>=, Jbr::Throttle::SPACING
  end
end
