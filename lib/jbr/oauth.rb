module Jbr
  # Credentials for one Jobber account, and the gateway to all they read or write.
  class OAuth
    # The mutation that revokes the app on the account.
    DISCONNECT_MUTATION = <<~GRAPHQL
      mutation Disconnect {
        appDisconnect {
          app { name author }
          userErrors { message }
        }
      }
    GRAPHQL

    # @param credentials [Hash] the tokens, their expiry, the account and when it went bad.
    def initialize(credentials = {})
      @access_token = credentials[:access_token]
      @refresh_token = credentials[:refresh_token]
      @expires_at = credentials[:expires_at]
      @account_id = credentials[:account_id]
      @invalid_at = credentials[:invalid_at]
    end

    # The credentials as Jobber last gave them, plus the moment a refusal to refresh landed.
    attr_reader :access_token, :refresh_token, :expires_at, :invalid_at
    # @return [String, nil] the account these credentials reach.
    attr_accessor :account_id

    # The resources these credentials read and write.
    def account = Account.new oauth: self
    def clients = Client.new oauth: self
    def invoices = Invoice.new oauth: self
    def jobs = Jobs.new oauth: self
    def quotes = Quote.new oauth: self
    def requests = Request.new oauth: self
    def visits = Visits.new oauth: self

    # Run a statement, waiting for what Jobber will still answer and refreshing a stale token.
    # @return [Hash] the data Jobber answered, or empty when the credentials are dead.
    def query(statement, variables: {})
      throttle.wait
      client.query(statement, variables: variables) { |extensions| throttle.read extensions }
    rescue GraphQL::Unauthorized
      refresh ? retry : {}
    end

    # Delete a token. If the token is invalid, do nothing.
    def delete
      client.query DISCONNECT_MUTATION
    rescue GraphQL::Unauthorized => e
    end

    # Exchange an authorization code for credentials, then learn their account.
    # @param code [String] the code Jobber sent to the redirect URI.
    # @param redirect_uri [String] the URI the code came back to.
    # @return [OAuth] the new credentials.
    def self.create(code:, redirect_uri:)
      credentials = post code: code, redirect_uri: redirect_uri, grant_type: 'authorization_code'
      new(credentials).tap { |oauth| oauth.account_id = oauth.account.id }
    end

    # @return [String, nil] The client ID to interact with the API.
    def self.client_id = ENV['JOBBER_CLIENT_ID']

    # @return [String, nil] The client secret to interact with the API.
    def self.client_secret = ENV['JOBBER_CLIENT_SECRET']

    # Exchange a code or a refresh token for credentials.
    def self.post(params = {})
      Token.post params.merge(client_id: client_id, client_secret: client_secret)
    end

  private

    def throttle = @throttle ||= Throttle.new

    def refresh
      output = self.class.post refresh_token: @refresh_token, grant_type: 'refresh_token'
      @access_token = output[:access_token]
      @refresh_token = output[:refresh_token]
      @expires_at = output[:expires_at]
    rescue Refused
      @invalid_at = Time.now
      false
    end

    def client
      GraphQL::Client.new endpoint: 'https://api.getjobber.com/api/graphql',
        token: @access_token, headers: headers
    end

    def headers = { 'X-JOBBER-GRAPHQL-VERSION' => '2026-04-22' }
  end
end
