require 'test_helper'

# Who a job is for, as it comes back beside the job's place.
class CustomersTest < Minitest::Test
  def test_a_customer_is_reached_on_the_number_that_can_be_dialed_ranked_by_use
    owner = { 'id' => 'client-01', 'firstName' => 'Jane', 'lastName' => 'Doe',
      'email' => 'jane@example.com',
      'phones' => [ { 'normalizedPhoneNumber' => '+441632960001', 'primary' => true,
                      'smsAllowed' => true, },
                    { 'normalizedPhoneNumber' => '+15553335555', 'primary' => false,
                      'smsAllowed' => true, },
                    { 'normalizedPhoneNumber' => '+15554446666', 'primary' => false,
                      'smsAllowed' => false, }, ],
    }

    customer = customer_of 'client' => owner

    assert_equal 'client-01', customer.id
    assert_equal 'Jane', customer.name
    assert_equal 'Doe', customer.surname
    assert_equal 'jane@example.com', customer.email
    assert_equal '5553335555', customer.phone
  end

  def test_a_customer_untitled_by_a_first_name_is_named_by_its_business
    customer = customer_of 'client' => { 'firstName' => '', 'companyName' => 'Ada & Co' }

    assert_equal 'Ada & Co', customer.name
  end

  def test_a_customer_named_by_neither_is_named_by_nothing_rather_than_an_empty_string
    assert_nil customer_of('client' => { 'firstName' => '', 'companyName' => '' }).name
  end

  # Jobber answers a field it holds nothing for with an empty string as readily as with null,
  # and a caller that validates presence needs the two to arrive as the same nothing.
  def test_a_field_left_empty_is_no_field_rather_than_an_empty_string
    address = { 'street1' => '1 Main St', 'city' => '', 'postalCode' => nil }
    location = location_of 'address' => address

    assert_equal '1 Main St', location.street
    assert_nil location.city
    assert_nil location.zip
    assert_nil location.latitude
  end

private

  def customer_of(property) = location_of(property).customer

  def location_of(property)
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01', 'property' => property } ],
                             'pageInfo' => { 'hasNextPage' => false }, }
    account.jobs.includes(location: :customer).first.location
  end
end
