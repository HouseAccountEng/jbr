module Jbr
  # What every Jobber resource shares: the credentials it is read or written through.
  class Resource
    # @param oauth [OAuth] the credentials to reach Jobber with.
    def initialize(oauth:)
      @oauth = oauth
    end

    # @return [String, nil] the Jobber ID, once the resource has been read or created.
    attr_reader :id
  end
end
