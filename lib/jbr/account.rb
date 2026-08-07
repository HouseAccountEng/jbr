module Jbr
  class Account < Resource
    FIND = <<~GRAPHQL
      { account { id } }
    GRAPHQL

    def id
      @id ||= @oauth.query(FIND).dig 'account', 'id'
    end
  end
end
