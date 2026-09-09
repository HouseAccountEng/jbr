module Jbr
  # What the account class does before there are credentials: sends a Jobber user to authorize
  # the app, and trades the code they come back with for a first set.
  module Authorizing
    # Where a Jobber user authorizes the app.
    AUTHORIZE = 'https://api.getjobber.com/api/oauth/authorize'

    # @param code [String] code Jobber sent to the redirect URI.
    # @param redirect_uri [String] URI the code came back to.
    # @return [Account] credentials for the account that authorized the app, its ID learned.
    # @raise [Error] where Jobber will not take the code.
    def create(code:, redirect_uri:)
      credentials = post code: code, redirect_uri: redirect_uri, grant_type: 'authorization_code'
      new(credentials).tap { |account| account.account_id = account.business.id }
    end

    # @param redirect_uri [String] where Jobber sends the user back to.
    # @param state [String] what the app recognizes them by when they come back.
    # @return [String] URL a Jobber user authorizes the app on.
    def url_for(redirect_uri:, state:)
      return Jbr.mock.oauth_url if Jbr.mocked?

      uri = URI AUTHORIZE
      uri.query = URI.encode_www_form redirect_uri: redirect_uri, state: state,
        response_type: 'code', client_id: client_id
      uri.to_s
    end

    # @return [String, nil] client ID the app is registered with Jobber as.
    def client_id = ENV['JOBBER_CLIENT_ID']

    # @return [String, nil] client secret the app proves itself to Jobber with.
    def client_secret = ENV['JOBBER_CLIENT_SECRET']

    # @param params [Hash] grant to exchange: a code, or a refresh token.
    # @return [Hash] tokens Jobber answered, and the moment the access one expires.
    def post(params = {})
      return Mock::Account.post params if Jbr.mocked?

      Token.post params.merge(client_id: client_id, client_secret: client_secret)
    end
  end
end
