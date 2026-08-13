require 'test_helper'

# Jobber holds an app to two limits at once: a count of requests over five minutes, and a
# bucket of query cost. A walk of many pages has to stay under both without being told to.
class ThrottleTest < Minitest::Test
  def setup = @throttle = Jbr::Throttle.new

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
