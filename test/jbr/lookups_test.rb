require 'test_helper'

# Reaching one record by the ID Jobber files it under, rather than walking an account to find
# it: one small query where the walk is many large ones.
class LookupsTest < Minitest::Test
  def test_a_visit_is_reached_by_the_id_jobber_files_it_under
    stub_graphql 'visit' => { 'id' => 'visit-01', 'title' => 'Tune-up' }

    visit = oauth.visits.find 'visit-01'

    assert_equal 'visit-01', visit.id
    assert_equal 'Tune-up', visit.title
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      request.body.include? '"id":"visit-01"'
    end
  end

  def test_an_id_jobber_has_no_visit_for_is_nil_rather_than_a_blank_visit
    stub_graphql 'visit' => nil

    assert_nil oauth.visits.find 'visit-99'
  end
end
