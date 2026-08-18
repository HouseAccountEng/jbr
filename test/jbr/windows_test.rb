require 'test_helper'
require 'active_support/core_ext/integer/time'

# Half a schedule is as much of it as the account holds, unless the caller says how much of it
# they meant: the next three months of visits, or the last year of jobs.
class WindowsTest < Minitest::Test
  def test_the_next_three_months_of_visits_are_bounded_at_both_ends
    stub_graphql 'visits' => { 'nodes' => [], 'pageInfo' => { 'hasNextPage' => false } }

    oauth.visits.upcoming(3.months).to_a

    assert_asked_about after: Time.now, before: Time.now + 3.months
  end

  def test_the_last_year_of_jobs_is_bounded_at_both_ends
    stub_graphql 'jobs' => { 'nodes' => [], 'pageInfo' => { 'hasNextPage' => false } }

    oauth.jobs.past(1.year).to_a

    assert_asked_about after: Time.now - 1.year, before: Time.now
  end

  def test_a_half_nobody_measured_is_open_at_its_far_end
    stub_graphql 'jobs' => { 'nodes' => [], 'pageInfo' => { 'hasNextPage' => false } }

    oauth.jobs.past.to_a

    assert_asked_about before: Time.now
  end

private

  # The two ends of the stretch the query asked about, to the minute, where a nil end is one
  # it named at all.
  def assert_asked_about(after: nil, before: nil)
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      bounds = JSON.parse(request.body).dig 'variables', 'filter', 'startAt'
      near?(bounds['after'], after) && near?(bounds['before'], before)
    end
  end

  def near?(asked, expected)
    return asked.nil? if expected.nil?

    (Time.iso8601(asked) - expected).abs < 60
  end
end
