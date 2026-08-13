module Jbr
  # The endpoint that trades an authorization code or a refresh token for credentials.
  class Token
    # Where a grant is exchanged.
    URL = 'https://api.getjobber.com/api/oauth/token'

    # What Jobber calls a grant that is no good, in the OAuth 2 word for it.
    REFUSAL = 'invalid_grant'

    # Trade a grant for credentials.
    # @param params [Hash] the grant, and the app making the exchange.
    # @raise [Refused] where Jobber says the grant itself is no good.
    # @raise [Error] where Jobber could not answer about it.
    # @return [Hash] the tokens, and the moment the access one expires.
    def self.post(params = {})
      response = Net::HTTP.post_form URI(URL), params
      raise Refused, response.body if refused? response
      raise Error, response.body unless response.is_a? Net::HTTPSuccess

      output = JSON.parse response.body
      { access_token: output['access_token'], refresh_token: output['refresh_token'],
        expires_at: (Time.now + output.fetch('expires_in', 3600).to_i),
      }
    end

    def self.refused?(response)
      return false if response.is_a? Net::HTTPSuccess

      JSON.parse(response.body)['error'] == REFUSAL
    rescue JSON::ParserError
      false
    end
    private_class_method :refused?
  end
end
