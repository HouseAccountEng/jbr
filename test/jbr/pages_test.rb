require 'test_helper'

# Jobber is asked for a page at a time, and only once the page before it runs out, so `first`
# costs one request where `to_a` costs as many as the account has pages.
class PagesTest < Minitest::Test
  def test_every_visit_is_walked_when_nothing_is_filtered_for
    stub_graphql 'visits' => { 'nodes' => [ { 'id' => 'visit-01' } ],
                               'pageInfo' => { 'hasNextPage' => false }, }

    assert_equal %w[visit-01], account.visits.map(&:id)
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      JSON.parse(request.body).dig('variables', 'filter').nil?
    end
  end

  def test_every_page_of_visits_is_read
    fetched = stub_two_pages

    assert_equal %w[visit-01 visit-02], account.visits.upcoming.map(&:id)
    assert_requested fetched, times: 2
  end

  def test_a_page_is_read_only_once_the_one_before_it_runs_out
    fetched = stub_two_pages

    assert_equal 'visit-01', account.visits.upcoming.first.id
    assert_requested fetched, times: 1
  end

  def test_the_visits_of_dead_credentials_are_none
    stub_graphql_failure status: 401
    stub_refusal_to_refresh

    assert_empty account.visits.upcoming.to_a
  end

private

  # Two pages of one visit each, the second answered only when the first runs out.
  def stub_two_pages
    stub_request(:post, JobberStubs::GRAPHQL_URL).to_return(
      { body: page_with('visit-01', 'hasNextPage' => true, 'endCursor' => 'cursor-01') },
      { body: page_with('visit-02', 'hasNextPage' => false) },
    )
  end

  def page_with(id, page_info)
    { data: { 'visits' => { 'nodes' => [ { 'id' => id } ], 'pageInfo' => page_info } } }.to_json
  end
end
