require 'test_helper'

class RequestTest < Minitest::Test
  def test_a_request_is_opened_against_a_client_and_a_property
    stub_graphql 'clientPhones' => { 'nodes' => [] }
    stub_request(:post, GRAPHQL_URL).with(body: /clientCreate/).to_return body: {
      data: { 'clientCreate' => { 'client' => {
        'id' => 'client-01', 'clientProperties' => { 'nodes' => [ { 'id' => 'property-01' } ] },
      } } },
    }.to_json
    opened = stub_request(:post, GRAPHQL_URL).with(body: /requestCreate/).to_return body: {
      data: { 'requestCreate' => { 'request' => { 'id' => 'request-01' } } },
    }.to_json

    request = oauth.requests.create first_name: 'Jane', last_name: 'Doe', phone: '5553335555',
      title: 'New Plumber Lead', instructions: 'Needs new faucet'

    assert_equal 'request-01', request.id
    assert_equal 'client-01', request.client_id
    assert_requested opened
  end
end
