module Jbr
  # Somebody who asked the business for work, which Jobber files as a request.
  class Lead < Company::Lead
    # @return [Customer, nil] client the request was opened against.
    def customer = record Customer, :client
  end
end
