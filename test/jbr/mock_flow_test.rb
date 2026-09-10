require 'test_helper'

# The mock layer answers without a network, so nothing here stubs a request.
class MockFlowTest < Minitest::Test
  def setup = Jbr.mock

  def teardown = Jbr.mock = nil

  def test_the_authorize_url_is_whatever_the_app_asked_for
    Jbr.mock.oauth_url = 'https://example.com/authorize'

    url = Jbr::Account.url_for redirect_uri: 'https://x.test', state: 'abc'

    assert_equal 'https://example.com/authorize', url
  end

  def test_credentials_are_created_and_revoked_without_a_network
    account = Jbr::Account.create code: 'code', redirect_uri: 'https://x.test'

    assert_kind_of Jbr::Mock::Account, account
    assert_equal 'mock-token', account.access_token
    assert_equal 'account-01', account.account_id
    assert_nil account.delete
  end

  def test_a_rejected_flow_raises_the_message_the_app_set
    Jbr.mock.oauth_error = 'Flow rejected'

    error = assert_raises(Jbr::Error) do
      Jbr::Account.create code: 'code', redirect_uri: 'https://x'
    end
    assert_equal 'Flow rejected', error.message
  end

  def test_the_accounts_go_back_to_jobber_once_the_mock_is_dropped
    Jbr.mock = nil

    refute Jbr.mocked?
    refute_kind_of Jbr::Mock::Account, credentials
  end

private

  def credentials = Jbr::Account.new access_token: 'mock-token'
end
