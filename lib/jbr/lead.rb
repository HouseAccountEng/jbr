module Jbr
  # Somebody who asked the business for work, which Jobber files as a request.
  class Lead < Company::Lead
    # @return [String, nil] ID of the client the request was opened against.
    def customer_id = @node.dig :client, :id
  end
end
