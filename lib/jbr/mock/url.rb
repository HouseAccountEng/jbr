module Jbr
  # The authorize URL an app under test asked for.
  class Mock::URL < URL
    # @return [String] whatever {Jbr.mock} was told to answer.
    def self.for(_)
      Jbr.mock.oauth_url
    end
  end
end
