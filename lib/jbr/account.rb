module Jbr
  # The Jobber account a set of credentials belongs to.
  class Account < Resource
    # The query that reads the account behind the current credentials.
    FIND = <<~GRAPHQL
      { account { id } }
    GRAPHQL

    # @return [String] the account ID, read once and remembered.
    def id
      @id ||= @oauth.query(FIND).dig 'account', 'id'
    end
  end
end
