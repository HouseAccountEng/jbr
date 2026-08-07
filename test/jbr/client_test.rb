require 'test_helper'

class ClientTest < Minitest::Test
  ADDRESS = { street: '1 Main St', city: 'Newark', state: 'NJ', zip: '07102' }

  # The address as Jobber echoes it back on a property, given the fields above.
  STORED = { 'street1' => '1 Main St', 'city' => 'Newark',
             'province' => 'NJ', 'postalCode' => '07102',
  }

  def test_a_new_client_is_created_with_every_field_given
    stub_graphql 'clientPhones' => { 'nodes' => [] }
    created = stub_request(:post, GRAPHQL_URL).with(body: /clientCreate/).to_return body: {
      data: { 'clientCreate' => { 'client' => {
        'id' => 'client-01', 'clientProperties' => { 'nodes' => [ { 'id' => 'property-01' } ] },
      } } },
    }.to_json

    client = build.find_or_create_by phone: '5553335555'

    assert_equal 'client-01', client.id
    assert_equal 'property-01', client.property_id
    assert_requested created
  end

  def test_a_client_with_no_address_or_email_sends_neither
    stub_graphql 'clientPhones' => { 'nodes' => [] }
    created = stub_request(:post, GRAPHQL_URL).
      with { |request| request.body.include?('clientCreate') &&
                       !request.body.include?('"properties"') &&
                       !request.body.include?('"emails"') }.
      to_return body: { data: { 'clientCreate' => { 'client' => { 'id' => 'client-01' } } } }.
        to_json

    client = build(first_name: 'Jane', phone: '5553335555').find_or_create_by phone: '5553335555'

    assert_equal 'client-01', client.id
    assert_nil client.property_id
    assert_requested created
  end

  def test_the_most_recently_updated_match_wins_and_its_property_is_reused
    stub_graphql 'clientPhones' => { 'nodes' => [
      { 'client' => { 'id' => 'older', 'updatedAt' => '2026-01-01', 'clientProperties' => {
        'nodes' => [ { 'id' => 'property-old', 'address' => STORED } ],
      },
      } },
      { 'client' => { 'id' => 'newer', 'updatedAt' => '2026-06-01', 'clientProperties' => {
        'nodes' => [ { 'id' => 'property-new', 'address' => STORED } ],
      },
      } },
    ] }

    client = build.find_or_create_by phone: '5553335555'

    assert_equal 'newer', client.id
    assert_equal 'property-new', client.property_id
  end

  def test_a_match_at_another_address_gets_a_new_property
    stub_graphql 'clientPhones' => { 'nodes' => [ { 'client' => {
      'id' => 'client-01', 'updatedAt' => '2026-06-01',
      'clientProperties' => { 'nodes' => [ { 'id' => 'elsewhere', 'address' => {} } ] },
    } } ] }
    stub_request(:post, GRAPHQL_URL).with(body: /propertyCreate/).to_return body: {
      data: { 'propertyCreate' => { 'properties' => [ { 'id' => 'property-02' } ] } },
    }.to_json

    client = build.find_or_create_by phone: '5553335555'

    assert_equal 'client-01', client.id
    assert_equal 'property-02', client.property_id
  end

  def test_a_property_jobber_declines_to_create_leaves_none
    stub_graphql 'clientPhones' => { 'nodes' => [ { 'client' => {
      'id' => 'client-01', 'updatedAt' => '2026-06-01', 'clientProperties' => { 'nodes' => [] },
    } } ] }
    stub_request(:post, GRAPHQL_URL).with(body: /propertyCreate/).
      to_return body: { data: { 'propertyCreate' => { 'properties' => [] } } }.to_json

    assert_nil build.find_or_create_by(phone: '5553335555').property_id
  end

private

  def build(params = { first_name: 'Jane', last_name: 'Doe', phone: '5553335555',
                       email: 'jane@example.com', address: ADDRESS,
  })
    oauth.clients.create_with params
  end
end
