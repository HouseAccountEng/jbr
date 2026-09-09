require 'test_helper'

class VisitsTest < Minitest::Test
  def test_a_visit_carries_its_times_and_the_job_it_belongs_to
    stub_visit 'title' => 'Tune-up', 'allDay' => true, 'clientConfirmed' => false,
      'job' => { 'id' => 'job-01' },
      'startAt' => '2026-08-09T14:00:00Z', 'endAt' => '2026-08-09T16:00:00Z'

    visit = self.visit

    assert_equal 'visit-01', visit.id
    assert_equal 'Tune-up', visit.description
    assert_equal 'job-01', visit.job.id
    assert_equal Time.utc(2026, 8, 9, 14), visit.starts_at
    assert_equal Time.utc(2026, 8, 9, 16), visit.ends_at
    assert visit.anytime?
    refute visit.confirmed?
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      request.body.include? 'nodes { id title startAt endAt allDay clientConfirmed job { id } }'
    end
  end

  # Jobber answers a field it holds nothing for with an empty string as readily as with null,
  # and a caller that validates presence needs the two to arrive as the same nothing.
  def test_a_moment_left_empty_is_no_moment_rather_than_an_empty_string
    stub_visit 'startAt' => '', 'endAt' => nil

    assert_nil visit.starts_at
    assert_nil visit.ends_at
  end

  def test_a_visit_of_no_job_belongs_nowhere
    stub_visit({})

    assert_nil visit.job
  end

private

  def stub_visit(node)
    stub_graphql 'visits' => { 'nodes' => [ { 'id' => 'visit-01' }.merge(node) ],
                               'pageInfo' => { 'hasNextPage' => false }, }
  end

  def visit = account.visits.upcoming.first
end
