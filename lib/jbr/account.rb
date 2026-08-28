module Jbr
  # The Jobber account a set of credentials belongs to.
  class Account < Resource
    # The query that reads the account behind the current credentials.
    FIND = <<~GRAPHQL
      { account { id name phone } }
    GRAPHQL

    # @return [String, nil] the account ID.
    def id = node['id']

    # @return [String, nil] what the business calls itself.
    def name = node['name']

    # @return [String, nil] the number the business is reached on, as Jobber holds it.
    def phone = node['phone']

  private

    # Read once and remembered, whichever of the three is asked for first.
    def node = @node = @node.presence || @oauth.query(FIND).fetch('account', {})
  end
end
