require 'test_helper'

class VisitsTest < Minitest::Test
  def test_a_visit_carries_its_job_its_address_and_its_times
    address = { 'street1' => '1 Main St', 'postalCode' => '27601' }
    client = { 'id' => 'client-01', 'firstName' => 'Jane', 'lastName' => 'Doe',
      'email' => 'jane@example.com',
      'phones' => [ { 'normalizedPhoneNumber' => '+441632960001', 'primary' => true,
                      'smsAllowed' => true, },
                    { 'normalizedPhoneNumber' => '+15553335555', 'primary' => false,
                      'smsAllowed' => true, },
                    { 'normalizedPhoneNumber' => '+15554446666', 'primary' => false,
                      'smsAllowed' => false, }, ],
    }
    owner = { 'id' => 'client-02', 'companyName' => 'Ada & Co' }
    node = { 'id' => 'visit-01', 'title' => 'Tune-up', 'job' => { 'id' => 'job-01' },
      'client' => client,
      'property' => { 'id' => 'property-01', 'address' => address, 'client' => owner },
      'allDay' => true, 'clientConfirmed' => false,
      'startAt' => '2026-08-09T14:00:00Z', 'endAt' => '2026-08-09T16:00:00Z',
    }
    stub_graphql 'visits' => { 'nodes' => [ node ], 'pageInfo' => { 'hasNextPage' => false } }

    visit = oauth.visits.includes(:client, property: :client).upcoming.first

    assert_equal 'visit-01', visit.id
    assert_equal 'Tune-up', visit.title
    assert_equal 'job-01', visit.job_id
    assert_equal 'client-01', visit.client.id
    assert_equal 'Jane', visit.client.first_name
    assert_equal 'Jane', visit.client.name
    assert_equal '5553335555', visit.client.phone
    assert_equal 'property-01', visit.property.id
    assert_equal '1 Main St', visit.property.street
    assert_equal '27601', visit.property.zip
    # The client on the property's file comes with it, a business named where a business is
    assert_equal 'Ada & Co', visit.property.client.name
    assert_equal Time.utc(2026, 8, 9, 14), visit.starts_at
    assert_equal Time.utc(2026, 8, 9, 16), visit.ends_at
    assert visit.all_day?
    refute visit.client_confirmed?
  end

  def test_an_unscheduled_visit_has_no_job_and_no_times
    node = { 'id' => 'visit-01', 'startAt' => nil, 'endAt' => nil }
    stub_graphql 'visits' => { 'nodes' => [ node ], 'pageInfo' => { 'hasNextPage' => false } }

    visit = oauth.visits.includes(:client, property: :client).upcoming.first

    assert_nil visit.job_id
    assert_nil visit.starts_at
    assert_nil visit.ends_at
  end

  def test_every_visit_is_walked_when_nothing_is_filtered_for
    stub_graphql 'visits' => { 'nodes' => [ { 'id' => 'visit-01' } ],
                               'pageInfo' => { 'hasNextPage' => false },
    }

    assert_equal %w[visit-01], oauth.visits.map(&:id)
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      JSON.parse(request.body).dig('variables', 'filter').nil?
    end
  end

  def test_every_page_of_visits_is_read
    fetched = stub_two_pages

    assert_equal %w[visit-01 visit-02], oauth.visits.upcoming.map(&:id)
    assert_requested fetched, times: 2
  end

  def test_a_page_is_read_only_once_the_one_before_it_runs_out
    fetched = stub_two_pages

    assert_equal 'visit-01', oauth.visits.upcoming.first.id
    assert_requested fetched, times: 1
  end

  def test_the_visits_of_dead_credentials_are_none
    stub_graphql_failure status: 401
    stub_refusal_to_refresh

    assert_empty oauth.visits.upcoming.to_a
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
