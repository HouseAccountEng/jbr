module Jbr
  # A job that reads from {Jbr.mock} instead of Jobber.
  class Mock::Job < Job
    # @return [Object, nil] the values the app asked for.
    def id = @node[:id]

    def title = @node[:title]

    def instructions = @node[:instructions]

    def status = @node[:status]

    def quote_id = @node[:quote_id]

    def total = @node[:total]

    def quote_total = @node[:quote_total]

    def created_at = @node[:created_at]

    def client = Mock::Client.new(node: @node.fetch(:client, {}))

    def property = Mock::Property.new(node: @node.fetch(:property, {}))

    def scheduled_at = @node[:scheduled_at]

    def completed_at = @node[:completed_at]
  end
end
