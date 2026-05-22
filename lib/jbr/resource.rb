module Jbr
  class Resource
    def initialize(oauth:)
      @oauth = oauth
    end

    attr_reader :id
  end
end
