module Jbr
  # One line of the work a job is made of: how many of a thing, what it is called, and what
  # doing it involves.
  class LineItem < Resource
    # What Jobber calls each field of a line.
    FIELDS = %w[quantity name description]

    # What to ask for wherever a record lists the lines it is made of.
    SELECTION = "lineItems { nodes { #{FIELDS.join ' '} } }"

    # @param nodes [Array<Hash>, nil] the lines as Jobber answered them, if it answered any.
    # @return [Array<LineItem>] one per line, in the order Jobber holds them.
    def self.from(nodes) = nodes.to_a.map { |node| new node: node }

    # @return [Integer, Float, nil] how many of it the job is for.
    def quantity = whole @node['quantity']

    # @return [String, nil] what the line is called.
    def name = @node['name']

    # @return [String, nil] what doing it involves, in whoever wrote the line's own words.
    def description = @node['description']

    # @return [String] how many of what: `3 Bathroom Faucet Installation`, and the name alone
    #   where Jobber holds no quantity for the line.
    def quantified = [ quantity, name ].compact.join ' '

    # @return [String] how a line reads: `3 Faucet install (Fits a new faucet)`, and without
    #   the parenthesis where nobody described it.
    def to_s = [ quantified, described ].compact.join ' '

  private

    # Jobber answers every quantity as a Float, and a whole one reads as an Integer:
    # `3 Faucets` rather than `3.0 Faucets`. A fraction keeps its point — `3.5 Faucets` —
    # since rounding it would lie about what was billed.
    def whole(number) = number && ((number % 1).zero? ? number.to_i : number)

    def described = ("(#{description})" if description.present?)
  end
end
