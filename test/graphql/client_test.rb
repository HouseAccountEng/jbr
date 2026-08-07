require 'test_helper'

class GraphQLClientTest < Minitest::Test
  def test_a_query_returns_the_data_and_carries_the_token_and_the_headers
    posted = stub_request(:post, GRAPHQL_URL).
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json',
                      'X-JOBBER-GRAPHQL-VERSION' => '2026-04-22' }).
      to_return body: { data: { 'ok' => true } }.to_json

    assert_equal({ 'ok' => true }, oauth.query('{ ok }'))
    assert_requested posted
  end

  def test_a_rejected_token_raises_unauthorized
    stub_graphql_failure status: 401, body: 'expired'

    error = assert_raises(GraphQL::Unauthorized) { client.query '{ ok }' }
    assert_equal 'expired', error.message
  end

  def test_any_other_failure_raises_the_body
    stub_graphql_failure status: 500, body: 'boom'

    error = assert_raises(GraphQL::Error) { client.query '{ ok }' }
    assert_equal 'boom', error.message
  end

  def test_errors_in_a_successful_body_are_joined_into_one_message
    stub_request(:post, GRAPHQL_URL).
      to_return body: { errors: [ { 'message' => 'no such field' }, { 'message' => 'try again' } ] }.to_json

    error = assert_raises(GraphQL::Error) { client.query '{ ok }' }
    assert_equal 'no such field; try again', error.message
  end

private

  def client = GraphQL::Client.new endpoint: GRAPHQL_URL, token: 'token'
end
