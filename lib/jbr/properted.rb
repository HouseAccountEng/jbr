module Jbr
  # Extends a record that stands at a property: a visit, a job, anything Jobber files
  # somewhere.
  module Properted
    # What to ask for where a record names the place the work happens at.
    # @param client [Boolean] whether the place's own client comes back with it, which spares
    #   a second query for somebody Jobber already knows the place belongs to.
    def self.selection(client: false)
      [ 'property { id address {', Property::SELECTION, '}',
        (Cliental::SELECTION if client), '}',
      ].compact.join ' '
    end

    # @return [Property] where the work happens, and who Jobber holds the place for.
    def property = Property.new node: @node.fetch('property', {})
  end
end
