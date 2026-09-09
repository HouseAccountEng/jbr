require 'test_helper'

class AccountTest < Minitest::Test
  def test_the_authorize_url_carries_the_app_and_what_the_caller_passed
    url = URI.parse Jbr::Account.url_for(redirect_uri: 'https://example.com/callback', state: 'abc')

    assert_equal 'api.getjobber.com', url.host
    assert_equal '/api/oauth/authorize', url.path
    assert_equal({ 'redirect_uri' => 'https://example.com/callback', 'state' => 'abc',
                   'response_type' => 'code', 'client_id' => 'client-id',
    },
                 URI.decode_www_form(url.query).to_h)
  end

  def test_create_exchanges_the_code_and_learns_the_account
    stub_token
    stub_graphql 'account' => { 'id' => 'account-01' }

    account = Jbr::Account.create code: 'code', redirect_uri: 'https://example.com'

    assert_equal 'new-token', account.access_token
    assert_equal 'new-refresh', account.refresh_token
    assert_equal 'account-01', account.account_id
    assert account.expires_at > Time.now
  end

  def test_create_raises_when_jobber_rejects_the_code
    stub_request(:post, TOKEN_URL).to_return status: 400, body: 'invalid_grant'

    error = assert_raises(Jbr::Error) do
      Jbr::Account.create code: 'code', redirect_uri: 'https://example.com'
    end
    assert_equal 'invalid_grant', error.message
  end

  def test_the_business_is_read_by_the_keys_the_vocabulary_names
    stub_graphql 'account' => {
      'id' => 'account-01', 'name' => 'Acme Plumbing', 'phone' => '(704) 459-7540',
    }

    business = account.business

    assert_equal 'account-01', business.id
    assert_equal 'Acme Plumbing', business.name
    assert_equal '7044597540', business.phone
    assert_requested(:post, GRAPHQL_URL) { |it| it.body.include? '{ account { id name phone } }' }
  end

  def test_an_expired_token_is_refreshed_and_the_query_retried
    stub_request(:post, GRAPHQL_URL).
      to_return({ status: 401, body: 'expired' }, { body: { data: { 'ok' => true } }.to_json })
    stub_token
    credentials = account

    assert_equal({ 'ok' => true }, credentials.query('{ ok }'))
    assert_equal 'new-token', credentials.access_token
    assert_nil credentials.invalid_at
  end

  def test_delete_disconnects_the_app
    stub_graphql 'appDisconnect' => { 'app' => { 'name' => 'HouseAccount' } }

    assert_nil account.delete['userErrors']
  end

  def test_delete_of_an_already_invalid_token_does_nothing
    stub_graphql_failure status: 401, body: 'expired'

    assert_nil account.delete
  end

  def test_the_client_credentials_come_from_the_environment
    assert_equal 'client-id', Jbr::Account.client_id
    assert_equal 'client-secret', Jbr::Account.client_secret
  end
end
