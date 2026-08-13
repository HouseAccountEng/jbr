require 'test_helper'

class OAuthTest < Minitest::Test
  def test_create_exchanges_the_code_and_learns_the_account
    stub_token
    stub_graphql 'account' => { 'id' => 'account-01' }

    oauth = Jbr::OAuth.create code: 'code', redirect_uri: 'https://example.com'

    assert_equal 'new-token', oauth.access_token
    assert_equal 'new-refresh', oauth.refresh_token
    assert_equal 'account-01', oauth.account_id
    assert oauth.expires_at > Time.now
  end

  def test_create_raises_when_jobber_rejects_the_code
    stub_request(:post, TOKEN_URL).to_return status: 400, body: 'invalid_grant'

    error = assert_raises(Jbr::Error) do
      Jbr::OAuth.create code: 'code', redirect_uri: 'https://example.com'
    end
    assert_equal 'invalid_grant', error.message
  end

  def test_an_expired_token_is_refreshed_and_the_query_retried
    stub_request(:post, GRAPHQL_URL).
      to_return({ status: 401, body: 'expired' }, { body: { data: { 'ok' => true } }.to_json })
    stub_token
    credentials = oauth

    assert_equal({ 'ok' => true }, credentials.query('{ ok }'))
    assert_equal 'new-token', credentials.access_token
    assert_nil credentials.invalid_at
  end

  def test_a_refusal_to_refresh_invalidates_the_credentials
    stub_graphql_failure status: 401, body: 'expired'
    stub_refusal_to_refresh
    credentials = oauth

    assert_empty credentials.query('{ ok }')
    assert credentials.invalid_at
  end

  # A token that may still work is worth more than a tidy failure: Jobber having a bad
  # moment is not Jobber saying the grant is dead, and only the second may give it up.
  def test_trouble_at_jobbers_end_leaves_the_credentials_alone
    stub_graphql_failure status: 401, body: 'expired'
    stub_request(:post, TOKEN_URL).to_return status: 500, body: 'Internal Server Error'
    credentials = oauth

    assert_raises(Jbr::Error) { credentials.query '{ ok }' }
    assert_nil credentials.invalid_at
  end

  def test_a_refusal_jobber_did_not_name_is_trouble_rather_than_a_refusal
    stub_graphql_failure status: 401, body: 'expired'
    stub_request(:post, TOKEN_URL).to_return status: 400, body: '<html>Bad Request</html>'
    credentials = oauth

    assert_raises(Jbr::Error) { credentials.query '{ ok }' }
    assert_nil credentials.invalid_at
  end

  def test_delete_disconnects_the_app
    stub_graphql 'appDisconnect' => { 'app' => { 'name' => 'HouseAccount' } }

    assert_nil oauth.delete['userErrors']
  end

  def test_delete_of_an_already_invalid_token_does_nothing
    stub_graphql_failure status: 401, body: 'expired'

    assert_nil oauth.delete
  end

  def test_the_client_credentials_come_from_the_environment
    assert_equal 'client-id', Jbr::OAuth.client_id
    assert_equal 'client-secret', Jbr::OAuth.client_secret
  end
end
