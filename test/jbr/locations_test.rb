require 'test_helper'

# Where a lead's work happens is a property on the customer's file: the one already there at
# that street and ZIP, or one added for them.
class LocationsTest < Minitest::Test
  ADDRESS = { street: '1 Main St', city: 'Newark', state: 'NJ', zip: '07102' }

  def test_a_customer_at_another_address_gets_a_new_property
    stub_customer_with 'id' => 'elsewhere', 'address' => { 'street1' => '2 Side St' }
    stub_request(:post, GRAPHQL_URL).with(body: /propertyCreate/).to_return body: {
      data: { 'propertyCreate' => { 'properties' => [ { 'id' => 'property-02' } ] } },
    }.to_json
    stub_request(:post, GRAPHQL_URL).with(body: /requestCreate/).
      to_return body: { data: { 'requestCreate' => { 'request' => { 'id' => 'request-01' } } } }.
        to_json

    create

    assert_requested(:post, GRAPHQL_URL) do |request|
      variables = JSON.parse(request.body)['variables']
      variables['clientId'] == 'client-01' && variables['input'] == { 'properties' => [
        { 'address' => { 'street1' => '1 Main St', 'city' => 'Newark', 'province' => 'NJ',
                         'postalCode' => '07102', } },
      ] }
    end
    assert_requested(:post, GRAPHQL_URL) do |request|
      request.body.include?('requestCreate') &&
        JSON.parse(request.body).dig('variables', 'input', 'propertyId') == 'property-02'
    end
  end

  # City and state are written but never matched: Jobber holds whatever was typed, so "NC" and
  # "North Carolina" would read as two homes. The ZIP already places the home.
  def test_a_property_at_the_same_street_and_zip_is_the_one_whatever_the_city_reads
    stub_customer_with 'id' => 'property-01', 'address' => {
      'street1' => '1 Main St', 'city' => 'NEWARK', 'postalCode' => '07102',
    }
    stub_request(:post, GRAPHQL_URL).with(body: /requestCreate/).
      to_return body: { data: { 'requestCreate' => { 'request' => { 'id' => 'request-01' } } } }.
        to_json

    create

    assert_requested(:post, GRAPHQL_URL) do |request|
      request.body.include?('requestCreate') &&
        JSON.parse(request.body).dig('variables', 'input', 'propertyId') == 'property-01'
    end
  end

  def test_a_property_jobber_declines_to_add_leaves_the_lead_nowhere
    stub_customer_with 'id' => 'elsewhere', 'address' => {}
    stub_request(:post, GRAPHQL_URL).with(body: /propertyCreate/).
      to_return body: { data: { 'propertyCreate' => { 'properties' => [] } } }.to_json
    stub_request(:post, GRAPHQL_URL).with(body: /requestCreate/).
      to_return body: { data: { 'requestCreate' => { 'request' => { 'id' => 'request-01' } } } }.
        to_json

    create

    assert_requested(:post, GRAPHQL_URL) do |request|
      request.body.include?('requestCreate') &&
        JSON.parse(request.body).dig('variables', 'input').key?('propertyId') &&
        JSON.parse(request.body).dig('variables', 'input', 'propertyId').nil?
    end
  end

private

  # A customer already answering to the phone, with one property on file.
  def stub_customer_with(property)
    stub_graphql 'clientPhones' => { 'nodes' => [ { 'client' => {
      'id' => 'client-01', 'updatedAt' => '2026-06-01',
      'clientProperties' => { 'nodes' => [ property ] },
    } } ] }
  end

  def create
    account.leads.create name: 'Jane', surname: 'Doe', phone: '5553335555',
      email: 'jane@example.com', address: ADDRESS, description: 'New Plumber Lead',
      notes: 'Needs new faucet', source: nil
  end
end
