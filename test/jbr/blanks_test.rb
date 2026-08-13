require 'test_helper'

# Jobber answers a field it holds nothing for with an empty string as readily as with null.
# A caller that validates presence needs the two to arrive as the same nothing.
class BlanksTest < Minitest::Test
  def test_a_client_untitled_by_a_first_name_is_named_by_its_business
    client = { 'id' => 'client-01', 'firstName' => '', 'companyName' => 'Ada & Co' }
    stub_visit 'client' => client

    assert_equal 'Ada & Co', visit.client.name
  end

  def test_a_client_named_by_neither_is_named_by_nothing_rather_than_by_an_empty_string
    stub_visit 'client' => { 'id' => 'client-01', 'firstName' => '', 'companyName' => '' }

    assert_nil visit.client.name
  end

  def test_a_job_left_untitled_is_named_by_the_id_it_is_filed_under
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01', 'title' => '' } ],
                             'pageInfo' => { 'hasNextPage' => false }, }

    assert_equal 'job-01', oauth.jobs.first.name
  end

  def test_a_visit_is_named_the_same_way_a_job_is
    stub_visit 'title' => 'Tune-up'
    assert_equal 'Tune-up', visit.name

    stub_visit 'title' => ''
    assert_equal 'visit-01', visit.name
  end

  def test_an_address_field_left_empty_does_not_come_back
    address = { 'street1' => '1 Main St', 'city' => '', 'postalCode' => nil }
    stub_visit 'property' => { 'id' => 'property-01', 'address' => address }

    assert_equal '1 Main St', visit.property.street
    assert_nil visit.property.city
    assert_equal({ street: '1 Main St' }, visit.property.address)
  end

  def test_an_empty_time_is_no_time_rather_than_an_argument_error
    stub_visit 'startAt' => '', 'endAt' => nil

    assert_nil visit.starts_at
    assert_nil visit.ends_at
  end

  def test_an_address_is_sent_without_the_fields_a_caller_left_empty
    assert_equal({ street1: '1 Main St' },
      Jbr::Property.address_from(street: '1 Main St', city: '', zip: nil))
  end

private

  def stub_visit(node)
    stub_graphql 'visits' => { 'nodes' => [ { 'id' => 'visit-01' }.merge(node) ],
                               'pageInfo' => { 'hasNextPage' => false }, }
  end

  def visit = oauth.visits.includes(:client, property: :client).first
end
