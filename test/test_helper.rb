require 'simplecov'
SimpleCov.start { minimum_coverage 100 }

require 'minitest/autorun'
require 'webmock/minitest'

ENV['JOBBER_CLIENT_ID'] = 'client-id'
ENV['JOBBER_CLIENT_SECRET'] = 'client-secret'

require_relative '../lib/jbr'

# The two Jobber endpoints and the canned responses every test builds on.
module JobberStubs
  # Where every query and mutation is posted.
  GRAPHQL_URL = 'https://api.getjobber.com/api/graphql'

  # Where an authorization code is exchanged for credentials.
  TOKEN_URL = 'https://api.getjobber.com/api/oauth/token'

  # @return [Jbr::OAuth] credentials whose access token is still good.
  def oauth = Jbr::OAuth.new access_token: 'token', refresh_token: 'refresh'

  # Answer the next GraphQL post with this data payload.
  # @param data [Hash] the +data+ the endpoint returns.
  def stub_graphql(data)
    stub_request(:post, GRAPHQL_URL).to_return body: { data: data }.to_json
  end

  # Answer the next GraphQL post with a failure.
  # @param status [Integer] the HTTP status to return.
  # @param body [String] the body to return with it.
  def stub_graphql_failure(status:, body: '{}')
    stub_request(:post, GRAPHQL_URL).to_return status: status, body: body
  end

  # Answer the next token post with a fresh pair of tokens.
  def stub_token
    body = { access_token: 'new-token', refresh_token: 'new-refresh', expires_in: 3600 }
    stub_request(:post, TOKEN_URL).to_return body: body.to_json
  end

  # Answer the next token post the way Jobber answers a grant that is no good.
  def stub_refusal_to_refresh
    stub_request(:post, TOKEN_URL).to_return status: 400, body: { error: 'invalid_grant' }.to_json
  end
end

class Minitest::Test
  include JobberStubs
end
