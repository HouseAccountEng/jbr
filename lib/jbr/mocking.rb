module Jbr
  # The switch an app under test throws to answer Jobber without a network. Touching
  # {#mock} once turns every entry point below over to its Mock counterpart.
  module Mocking
    # @return [Mock] the answers this process gives, created on first use.
    def mock
      @mock ||= Jbr::Mock.new
    end

    # @param params [Hash] the +code+ and +redirect_uri+ to exchange.
    # @return [OAuth] credentials for the account that authorized the app.
    def create_oauth(params = {})
      (@mock ? Mock::OAuth : OAuth).create **params
    end

    # @param params [Hash] the +redirect_uri+ and +state+ to come back with.
    # @return [String] the URL a Jobber user authorizes the app on.
    def oauth_url_for(params = {})
      (@mock ? Mock::URL : URL).for **params
    end

    # @param params [Hash] credentials already on file.
    # @return [OAuth] those credentials, ready to read and write with.
    def oauth_for(params = {})
      (@mock ? Mock::OAuth : OAuth).new params
    end
  end

  extend Mocking
end
