module Jbr
  class Account < Resource
    FIND = <<~GRAPHQL.freeze
      { account { id } }
    GRAPHQL

    def id
      @id ||= @oauth.query(FIND).dig 'account', 'id'
    end
  end
end
