module Jbr
  # The endpoint that trades an authorization code or a refresh token for credentials.
  class Token
    # Where a grant is exchanged.
    URL = 'https://api.getjobber.com/api/oauth/token'

    # What Jobber says of a grant it will not take, in the prose it answers with. About the
    # token rather than about the app, which is what tells it from the 401 a wrong client id and
    # secret get — and that one is every account at once rather than this one.
    REFUSAL = /refresh token is not valid/

    # Trade a grant for credentials.
    # @param params [Hash] the grant, and the app making the exchange.
    # @raise [Refused] where Jobber says the grant itself is no good.
    # @raise [Error] where Jobber could not answer about it.
    # @return [Hash] the tokens, and the moment the access one expires.
    def self.post(params = {})
      response = Net::HTTP.post_form URI(URL), params
      raise Refused, response.body if REFUSAL.match? response.body
      raise Error, response.body unless response.is_a? Net::HTTPSuccess

      output = JSON.parse response.body
      { access_token: output['access_token'], refresh_token: output['refresh_token'],
        expires_at: (Time.now + output.fetch('expires_in', 3600).to_i),
      }
    end
  end
end
