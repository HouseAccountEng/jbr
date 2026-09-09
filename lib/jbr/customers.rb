module Jbr
  # The clients on a Jobber account, reached by phone and opened where none answers to it.
  class Customers < Collection
    # The query that finds a client by phone, with the properties already on file.
    LOOKUP = <<~GRAPHQL
      query($searchTerm: String!) {
        clientPhones(first: 1, searchTerm: $searchTerm) { nodes {
          client { id updatedAt clientProperties { nodes { id address { #{Location::ADDRESS} } } } }
        } }
      }
    GRAPHQL

    # The mutation that opens a client, with a first property where an address is given.
    CREATE = <<~GRAPHQL
      mutation($input: ClientCreateInput!) {
        clientCreate(input: $input) {
          client { id clientProperties(first: 1) { nodes { id address { #{Location::ADDRESS} } } } }
          userErrors { message }
        }
      }
    GRAPHQL

    # Reach the client answering to a number, opening one with the rest where Jobber has none.
    # @param phone [String] number to match on, and to file a new client under.
    # @param first_name [String] what to call them.
    # @param last_name [String, nil] their last name.
    # @param email [String, nil] address they are written to.
    # @param address [Hash] any of :street, :city, :state and :zip, the first place on file.
    # @return [Customer] the client, with the places on their file.
    def find_or_create_by(phone:, first_name:, last_name:, email:, address:)
      find_by(phone) || create(phone:, first_name:, last_name:, email:, address:)
    end

  private

    # The most recently updated of the clients answering to the number.
    def find_by(phone)
      output = @account.query LOOKUP, variables: { searchTerm: phone }
      recent = output.dig('clientPhones', 'nodes').to_a.max_by do |node|
        node.dig('client', 'updatedAt') || ''
      end
      Customer.new node: recent['client'] if recent
    end

    def create(phone:, first_name:, last_name:, email:, address:)
      input = { firstName: first_name, lastName: last_name,
                phones: [ { number: phone, primary: true } ],
                emails: ([ { address: email, primary: true } ] if email.present?),
                properties: ([ { address: Locations.address_from(address) } ] if address.present?),
      }.compact
      output = @account.query CREATE, variables: { input: input }
      Customer.new node: output.dig('clientCreate', 'client')
    end
  end
end
