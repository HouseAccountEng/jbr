module Jbr
  # Where the work happens: one address on a client's file.
  class Property < Resource
    # The mutation that adds a property to a client already on file.
    CREATE = <<~GRAPHQL
      mutation propertyCreateMutation($clientId: EncodedId!, $input: PropertyCreateInput!) {
        propertyCreate(clientId: $clientId, input: $input) {
          properties { id }
          userErrors { message }
        }
      }
    GRAPHQL

    # The address as Jobber takes it, from the fields a caller passes.
    # @param fields [Hash] any of :street, :city, :state and :zip.
    # @return [Hash] the address, without the fields the caller left out.
    def self.address_from(fields = {})
      { street1: fields[:street], city: fields[:city],
        province: fields[:state], postalCode: fields[:zip],
      }.compact
    end

    # Reach the property at an address, adding one when none of the client's matches.
    # @param client_id [String] the client the property belongs to.
    # @param address [Hash] the fields the work happens at.
    # @param existing [Array<Hash>] the properties already on the client's file.
    # @return [String, nil] the property ID.
    def find_or_create_for(client_id:, address:, existing: [])
      wanted = self.class.address_from address
      match = existing.find { |property| wanted.transform_keys(&:to_s) == property['address'] }
      return match['id'] if match

      output = @oauth.query CREATE, variables: {
        clientId: client_id, input: { properties: [ { address: wanted } ] },
      }
      (output&.dig('propertyCreate', 'properties')&.first || {})['id']
    end
  end
end
