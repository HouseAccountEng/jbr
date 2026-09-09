module Jbr
  # The requests on a Jobber account's board: work somebody asked the business for.
  class Leads < Collection
    # The mutation that opens a request against a client and a property.
    CREATE = <<~GRAPHQL
      mutation($input: RequestCreateInput!) {
        requestCreate(input: $input) { request { id client { id } } userErrors { message } }
      }
    GRAPHQL

    # File a request against the client answering to the phone and the property at the address,
    # opening either where Jobber has none.
    # @param first_name [String] what to call whoever asked.
    # @param last_name [String, nil] their last name.
    # @param phone [String] number they are reached on, and matched to a client by.
    # @param email [String, nil] address they are written to.
    # @param title [String] what the request is called on the board.
    # @param instructions [String, nil] what they asked for, in their words.
    # @param address [Hash] any of :street, :city, :state and :zip, where the work happens.
    # @return [Lead] the request, and the client it was opened against.
    def create(first_name:, last_name:, phone:, email:, title:, instructions:, address:)
      customer = Customers.new(account: @account).find_or_create_by phone: phone,
        first_name: first_name, last_name: last_name, email: email, address: address
      location_id = Locations.new(account: @account).find_or_create_for customer, address
      input = { clientId: customer.id, propertyId: location_id, title: title,
                assessment: { instructions: instructions }, }
      output = @account.query CREATE, variables: { input: input }
      Lead.new node: output.dig('requestCreate', 'request')
    end
  end
end
