module Jbr
  # One line of the work a job is made of: how many of a thing, what it is called,
  # what it says, and what it comes to.
  class LineItem < Resource
    # What Jobber calls each field of a line. The ID reads through {Resource#id}, so an app
    # can tell a line it has seen before from a new one.
    FIELDS = %w[id quantity name description totalPrice]

    # The most lines to read off one record. Bounded because Jobber prices a connection by the
    # page it is asked for and prices an unbounded one at its own maximum, so the lines of a
    # page of jobs were charged for as though every job had the largest job's worth of them.
    PAGE = 20

    # What to ask for wherever a record lists the lines it is made of.
    SELECTION = "lineItems(first: #{PAGE}) { nodes { #{FIELDS.join ' '} } }"

    # @param nodes [Array<Hash>, nil] the lines as Jobber answered them, if it answered any.
    # @return [Array<LineItem>] one per line, in the order Jobber holds them.
    def self.from(nodes) = nodes.to_a.map { |node| new node: node }

    # @return [Integer, Float, nil] how many of it the job is for.
    def quantity = whole @node['quantity']

    # @return [String, nil] what the line is called.
    def name = @node['name']

    # @return [String, nil] what the line says, beyond what it is called.
    def description = @node['description']

    # @return [Float, nil] what the line comes to — what Jobber calls `totalPrice`.
    def amount = @node['totalPrice']

    # @return [String] how many of what: `3 Bathroom Faucet Installation`, and the name alone
    #   where Jobber holds no quantity for the line.
    def to_s = [ quantity, name ].compact.join ' '

  private

    # Jobber answers every quantity as a Float, and a whole one reads as an Integer:
    # `3 Faucets` rather than `3.0 Faucets`. A fraction keeps its point — `3.5 Faucets` —
    # since rounding it would lie about what was billed.
    def whole(number) = number && ((number % 1).zero? ? number.to_i : number)
  end
end
