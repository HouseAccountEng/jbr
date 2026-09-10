module Jbr
  # What every kind reached through the credentials shares: the credentials.
  class Reader
    # @param account [Account] credentials to reach Jobber with.
    def initialize(account:)
      @account = account
    end
  end
end
