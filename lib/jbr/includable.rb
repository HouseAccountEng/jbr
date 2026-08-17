module Jbr
  # Extends a list of records with the chaining that says what to bring back beside them.
  # Nothing extra comes back unasked: a page costs what it carries.
  module Includable
    # @param names [Array<Symbol, Hash>] :client, :line_items, :property, or
    #   property: :client for the client whose file the place sits on.
    # @return [Resource] the same list, asking Jobber for those too.
    def includes(*names)
      named = names.each_with_object({}) do |name, all|
        name.is_a?(Hash) ? all.merge!(name) : all[name] = nil
      end
      self.class.new oauth: @oauth, includes: @includes.merge(named)
    end

  private

    # What the includes ask Jobber for, in its own words.
    def selections = @includes.map { |name, nested| selection_of name, nested }.join ' '

    def selection_of(name, nested)
      case name
        when :client then Cliental::SELECTION
        when :line_items then LineItem::SELECTION
        when :property then Properted.selection client: nested == :client
      end
    end
  end
end
