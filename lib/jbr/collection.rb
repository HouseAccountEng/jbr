module Jbr
  # A list of records read through the credentials, with what it was asked to bring back beside
  # each record and what it was narrowed to.
  class Collection < Company::Collection
    # @param account [Account] credentials to reach Jobber with.
    # @param includes [Hash] what to bring back beside each record, by name.
    # @param filter [Hash, nil] what the list was narrowed to, in the shape Jobber filters by.
    def initialize(account:, includes: {}, filter: nil)
      @account = account
      @includes = includes
      @filter = filter
    end
  end
end
