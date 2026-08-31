module Jbr
  # A line of a job that reads from {Jbr.mock} instead of Jobber.
  class Mock::LineItem < LineItem
    # @return [Object, nil] the values the app asked for. The quantity is still read whole,
    #   so an app that mocks `3.0` of a thing sees the `3` a page would show.
    def id = @node[:id]

    def quantity = whole @node[:quantity]

    def name = @node[:name]

    def description = @node[:description]

    def amount = @node[:amount]
  end
end
