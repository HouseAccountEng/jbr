require 'test_helper'

class LeadsTest < Minitest::Test
  ADDRESS = { street: '1 Main St', city: 'Newark', state: 'NJ', zip: '07102' }

  # The address as Jobber echoes it back on a property.
  STORED = { 'street1' => '1 Main St', 'city' => 'Newark', 'postalCode' => '07102' }

  def test_a_lead_is_filed_against_a_new_customer_and_the_place_opened_with_them
    stub_graphql 'clientPhones' => { 'nodes' => [] }
    stub_request(:post, GRAPHQL_URL).with(body: /clientCreate/).to_return body: { data: {
      'clientCreate' => { 'client' => { 'id' => 'client-01', 'clientProperties' => {
        'nodes' => [ { 'id' => 'property-01', 'address' => STORED } ],
      }, } },
    } }.to_json
    opened = stub_opened_at 'property-01', client: 'client-01'

    lead = create

    assert_equal 'request-01', lead.id
    assert_equal 'client-01', lead.customer.id
    assert_requested opened
    assert_requested(:post, GRAPHQL_URL) do |request|
      input = JSON.parse(request.body).dig 'variables', 'input'
      request.body.include?('clientCreate') && input['firstName'] == 'Jane' &&
        input['lastName'] == 'Doe' &&
        input['phones'] == [ { 'number' => '5553335555', 'primary' => true } ] &&
        input['emails'] == [ { 'address' => 'jane@example.com', 'primary' => true } ] &&
        input['properties'] == [ { 'address' => STORED.merge('province' => 'NJ') } ]
    end
  end

  def test_a_customer_with_no_email_and_no_address_is_opened_with_neither
    stub_graphql 'clientPhones' => { 'nodes' => [] }
    stub_request(:post, GRAPHQL_URL).with(body: /clientCreate/).
      to_return body: { data: { 'clientCreate' => { 'client' => { 'id' => 'client-01' } } } }.
        to_json
    stub_request(:post, GRAPHQL_URL).with(body: /propertyCreate/).
      to_return body: { data: { 'propertyCreate' => { 'properties' => [] } } }.to_json
    stub_opened_at nil

    lead = create email: nil, address: {}

    assert_equal 'request-01', lead.id
    assert_nil lead.customer
    assert_requested(:post, GRAPHQL_URL) do |request|
      input = JSON.parse(request.body).dig 'variables', 'input'
      request.body.include?('clientCreate') && !input.key?('emails') && !input.key?('properties')
    end
  end

  def test_the_most_recently_updated_customer_answering_to_the_phone_is_the_one
    stub_graphql 'clientPhones' => { 'nodes' => [
      { 'client' => { 'id' => 'older', 'updatedAt' => '2026-01-01', 'clientProperties' => {
        'nodes' => [ { 'id' => 'property-old', 'address' => STORED } ],
      }, } },
      { 'client' => { 'id' => 'newer', 'updatedAt' => '2026-06-01', 'clientProperties' => {
        'nodes' => [ { 'id' => 'property-new', 'address' => STORED } ],
      }, } },
    ] }
    opened = stub_opened_at 'property-new', client: 'newer'

    assert_equal 'newer', create.customer.id
    assert_requested opened
  end

  def test_a_mutation_jobber_took_but_would_not_act_on_raises_what_it_said
    stub_graphql 'clientPhones' => { 'nodes' => [] }
    stub_request(:post, GRAPHQL_URL).with(body: /clientCreate/).to_return body: { data: {
      'clientCreate' => { 'client' => nil, 'userErrors' => [
        { 'message' => 'Phone number is invalid' }, { 'message' => 'Email has already been taken' },
      ], },
    } }.to_json

    error = assert_raises(Jbr::Error) { create }
    assert_equal 'Phone number is invalid; Email has already been taken', error.message
  end

private

  def create(email: 'jane@example.com', address: ADDRESS)
    account.leads.create name: 'Jane', surname: 'Doe', phone: '5553335555', email: email,
      address: address, description: 'New Plumber Lead', notes: 'Needs new faucet', source: nil
  end

  # Answer a request opened against that property, with the title and the instructions given.
  def stub_opened_at(property_id, client: nil)
    stub_request(:post, GRAPHQL_URL).with { |request| filed_at? request, property_id }.
      to_return body: { data: { 'requestCreate' => { 'request' => {
        'id' => 'request-01', 'client' => ({ 'id' => client } if client),
      } } } }.to_json
  end

  def filed_at?(request, property_id)
    input = JSON.parse(request.body).dig 'variables', 'input'
    request.body.include?('requestCreate') && input['propertyId'] == property_id &&
      input['title'] == 'New Plumber Lead' &&
      input['assessment'] == { 'instructions' => 'Needs new faucet' }
  end
end
