module Jbr
  # Where work happens, which Jobber calls a property: one address on a client's file.
  class Location < Company::Location
    # The node keys Jobber spells otherwise than the vocabulary.
    def self.keys = { street: :street1, zip: :postalCode }

    # The address as Jobber answers it, the coordinates tucked inside.
    ADDRESS = 'street1 city postalCode coordinates { latitude longitude }'

    # What to ask for wherever a record names the place the work happens at.
    # @param customer [Boolean] whether whose place it is comes back beside it, which spares a
    #   second query for somebody Jobber already knows the place belongs to.
    # @return [String] selection of a property.
    def self.selection(customer: false)
      [ 'property { id address {', ADDRESS, '}', (Customer::SELECTION if customer), '}' ].
        compact.join ' '
    end

    # Jobber answers a field it holds nothing for with an empty string as readily as with
    # null, and the two arrive as the same nothing.
    # @param node [Hash] property as Jobber answered it, the address and its coordinates nested.
    def initialize(node: {})
      node = node.with_indifferent_access
      address, coordinates = node[:address].to_h, node.dig(:address, :coordinates).to_h
      super node: node.merge(address, coordinates).compact_blank
    end

    # @return [Customer, nil] whose place it is, where they came back beside the location.
    def customer = record Customer, :client
  end
end
