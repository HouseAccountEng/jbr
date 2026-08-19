module Jbr
  # A property that reads from {Jbr.mock} instead of Jobber.
  class Mock::Property < Property
    # @return [Object, nil] the values the app asked for.
    def id = @node[:id]

    def street = @node[:street]

    def city = @node[:city]

    def zip = @node[:zip]

    def latitude = @node[:latitude]

    def longitude = @node[:longitude]

    def client = Mock::Client.new(node: @node.fetch(:client, {}))
  end
end
