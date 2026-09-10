module Jbr
  # The properties on a client's file, and the one a request is opened at.
  class Locations < Reader
    # The mutation that adds a property to a client already on file.
    CREATE = <<~GRAPHQL
      mutation($clientId: EncodedId!, $input: PropertyCreateInput!) {
        propertyCreate(clientId: $clientId, input: $input) {
          properties { id }
          userErrors { message }
        }
      }
    GRAPHQL

    # What Jobber calls each address field, against what a caller passes.
    FIELDS = { street1: :street, city: :city, province: :state, postalCode: :zip }

    # The address as Jobber takes it, without the fields a caller left blank.
    # @param fields [Hash] any of :street, :city, :state and :zip.
    # @return [Hash] address, by Jobber's names.
    def self.address_from(fields)
      FIELDS.to_h { |jobber, ours| [ jobber, fields[ours] ] }.compact_blank
    end

    # Reach the property at an address on a client's file, adding one where none matches.
    # @param customer [Customer] whose file, with the places already on it.
    # @param address [Hash] any of :street, :city, :state and :zip.
    # @return [String, nil] ID of the property, or nil where Jobber declined to add one.
    def find_or_create_for(customer, address)
      wanted = self.class.address_from address
      match = customer.locations.find { |location| same_address? wanted, location }
      match ? match.id : create(customer.id, wanted)
    end

  private

    def create(client_id, address)
      output = @account.query CREATE, variables: {
        clientId: client_id, input: { properties: [ { address: address } ] },
      }
      output.dig 'propertyCreate', 'properties', 0, 'id'
    end

    def same_address?(wanted, location)
      wanted[:street1] == location.street && wanted[:postalCode] == location.zip
    end
  end
end
