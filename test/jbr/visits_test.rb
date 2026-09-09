require 'test_helper'

class VisitsTest < Minitest::Test
  def test_a_visit_carries_its_location_its_customer_and_its_times
    address = { 'street1' => '1 Main St', 'postalCode' => '27601' }
    owner = { 'id' => 'client-01', 'firstName' => 'Jane', 'lastName' => 'Doe',
      'email' => 'jane@example.com',
      'phones' => [ { 'normalizedPhoneNumber' => '+441632960001', 'primary' => true,
                      'smsAllowed' => true, },
                    { 'normalizedPhoneNumber' => '+15553335555', 'primary' => false,
                      'smsAllowed' => true, },
                    { 'normalizedPhoneNumber' => '+15554446666', 'primary' => false,
                      'smsAllowed' => false, }, ],
    }
    stub_visit 'title' => 'Tune-up', 'allDay' => true, 'clientConfirmed' => false,
      'property' => { 'id' => 'property-01', 'address' => address, 'client' => owner },
      'startAt' => '2026-08-09T14:00:00Z', 'endAt' => '2026-08-09T16:00:00Z'

    visit = self.visit
    customer = visit.location.customer

    assert_equal 'visit-01', visit.id
    assert_equal 'Tune-up', visit.description
    assert_equal 'property-01', visit.location.id
    assert_equal '1 Main St', visit.location.street
    assert_equal '27601', visit.location.zip
    # The client on the property's file comes with it, reached on the number we can dial
    assert_equal 'client-01', customer.id
    assert_equal 'Jane', customer.name
    assert_equal 'Doe', customer.surname
    assert_equal 'jane@example.com', customer.email
    assert_equal '5553335555', customer.phone
    assert_equal Time.utc(2026, 8, 9, 14), visit.starts_at
    assert_equal Time.utc(2026, 8, 9, 16), visit.ends_at
    assert visit.all_day?
    refute visit.confirmed?
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      request.body.include? 'nodes { id title startAt endAt allDay clientConfirmed property {'
    end
  end

  def test_a_customer_untitled_by_a_first_name_is_named_by_its_business
    stub_visit 'property' => { 'client' => { 'firstName' => '', 'companyName' => 'Ada & Co' } }

    assert_equal 'Ada & Co', visit.location.customer.name
  end

  def test_a_customer_named_by_neither_is_named_by_nothing_rather_than_an_empty_string
    stub_visit 'property' => { 'client' => { 'firstName' => '', 'companyName' => '' } }

    assert_nil visit.location.customer.name
  end

  # Jobber answers a field it holds nothing for with an empty string as readily as with null,
  # and a caller that validates presence needs the two to arrive as the same nothing.
  def test_a_field_left_empty_is_no_field_rather_than_an_empty_string
    address = { 'street1' => '1 Main St', 'city' => '', 'postalCode' => nil }
    stub_visit 'property' => { 'id' => 'property-01', 'address' => address },
      'startAt' => '', 'endAt' => nil

    assert_equal '1 Main St', visit.location.street
    assert_nil visit.location.city
    assert_nil visit.location.zip
    assert_nil visit.location.latitude
    assert_nil visit.starts_at
    assert_nil visit.ends_at
  end

  def test_a_visit_nobody_asked_the_location_of_stands_nowhere
    stub_visit({})

    assert_nil account.visits.first.location
  end

private

  def stub_visit(node)
    stub_graphql 'visits' => { 'nodes' => [ { 'id' => 'visit-01' }.merge(node) ],
                               'pageInfo' => { 'hasNextPage' => false }, }
  end

  def visit = account.visits.includes(location: :customer).upcoming.first
end
