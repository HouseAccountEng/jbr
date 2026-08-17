require 'test_helper'

# Credentials many processes hold copies of. Jobber rotates a refresh token when it is spent,
# so the second worker to notice an expired access token must not spend one the first already
# has: it takes what that one wrote instead.
class SharingTest < Minitest::Test
  # A store the way an app writes one: credentials read under a lock, and written back into it.
  class Vault
    def initialize(credentials) = @credentials = credentials

    def exclusively = yield @credentials

    def write(oauth)
      @credentials = { access_token: oauth.access_token, refresh_token: oauth.refresh_token,
                       expires_at: oauth.expires_at, invalid_at: oauth.invalid_at, }
    end

    def to_h = @credentials
  end

  def setup
    @credentials = { access_token: 'stale', refresh_token: 'refresh', expires_at: Time.now }
    @vault = Vault.new @credentials
  end

  def test_the_one_that_refreshes_writes_it_and_the_next_one_takes_it
    stub_request(:post, GRAPHQL_URL).
      to_return({ status: 401, body: 'expired' }, { body: { data: { 'ok' => true } }.to_json })
    token = stub_token

    assert_equal({ 'ok' => true }, sharer.query('{ ok }'))
    assert_equal 'new-token', @vault.to_h[:access_token]
    assert_requested token, times: 1

    # The second one is refused with the token the first replaced, and asks Jobber nothing:
    # what the store holds is already the answer
    stub_request(:post, GRAPHQL_URL).
      to_return({ status: 401, body: 'expired' }, { body: { data: { 'ok' => true } }.to_json })

    assert_equal({ 'ok' => true }, sharer.query('{ ok }'))
    assert_requested token, times: 1
  end

  def test_a_grant_jobber_says_is_dead_is_written_off_in_the_store
    stub_request(:post, GRAPHQL_URL).to_return status: 401, body: 'expired'
    stub_refusal_to_refresh

    # Refused while holding the freshest refresh token there is, so it is the grant that is
    # gone rather than this copy being behind
    assert_empty sharer.query('{ ok }')
    assert @vault.to_h[:invalid_at]
  end

private

  # Credentials as one worker of many builds them, from the store they all share.
  def sharer = Jbr::OAuth.new(**@credentials, store: @vault)
end
