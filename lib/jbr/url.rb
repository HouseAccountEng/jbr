module Jbr
  # The page a Jobber user authorizes the app on.
  class URL
    # @param params [Hash] the +redirect_uri+ and +state+ to come back with.
    # @return [String] the URL to send the user to.
    def self.for(params = {})
      uri = URI 'https://api.getjobber.com/api/oauth/authorize'
      uri.query = URI.encode_www_form params.merge(response_type: 'code', client_id: client_id)
      uri.to_s
    end

    # @return [String, nil] the client ID of the app being authorized.
    def self.client_id = ENV['JOBBER_CLIENT_ID']
    private_class_method :client_id
  end
end
