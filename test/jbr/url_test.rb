require 'test_helper'

class URLTest < Minitest::Test
  def test_the_authorize_url_carries_the_app_and_what_the_caller_passed
    url = URI.parse Jbr::URL.for(redirect_uri: 'https://example.com/callback', state: 'abc')

    assert_equal 'api.getjobber.com', url.host
    assert_equal '/api/oauth/authorize', url.path
    assert_equal({ 'redirect_uri' => 'https://example.com/callback', 'state' => 'abc',
                   'response_type' => 'code', 'client_id' => 'client-id' },
                 URI.decode_www_form(url.query).to_h)
  end
end
