module Jbr
  # The requests on a Jobber account's board: work somebody asked the business for.
  class Leads < Company::Leads
    # The mutation that opens a request against a client and a property.
    CREATE = <<~GRAPHQL
      mutation($input: RequestCreateInput!) {
        requestCreate(input: $input) { request { id client { id } } userErrors { message } }
      }
    GRAPHQL

    # @param account [Account] credentials to reach Jobber with.
    def initialize(account:)
      @account = account
    end

    # Files a request against the client answering to the phone and the property at the address,
    # opening either where Jobber has none. The description is the request's title and the
    # notes its instructions; Jobber has no source for a request, so that one is dropped.
    # @return [Lead] the request, and the client it was opened against.
    def create(name:, surname:, phone:, email:, address:, description:, notes:, source:)
      customer = Customers.new(account: @account).find_or_create_by phone: phone,
        name: name, surname: surname, email: email, address: address
      location_id = Locations.new(account: @account).find_or_create_for customer, address
      input = { clientId: customer.id, propertyId: location_id, title: description,
                assessment: { instructions: notes }, }
      output = @account.query CREATE, variables: { input: input }
      Lead.new node: output.dig('requestCreate', 'request')
    end
  end
end
