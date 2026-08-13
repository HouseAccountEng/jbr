module Jbr
  # A visit that reads from {Jbr.mock} instead of Jobber.
  class Mock::Visit < Visit
    # @return [Object, nil] the values the app asked for.
    def id = @node[:id]

    def title = @node[:title]

    def job_id = @node[:job_id]

    def client = Mock::Client.new(node: @node.fetch(:client, {}))

    def property = Mock::Property.new(node: @node.fetch(:property, {}))

    def all_day? = @node[:all_day]

    def client_confirmed? = @node[:client_confirmed]

    def starts_at = @node[:starts_at]

    def ends_at = @node[:ends_at]
  end
end
