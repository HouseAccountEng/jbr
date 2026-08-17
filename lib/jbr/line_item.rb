module Jbr
  # One line of the work a job is made of: how many of a thing, what it is called, and what
  # doing it involves.
  class LineItem < Resource
    # What Jobber calls each field of a line.
    FIELDS = %w[quantity name description]

    # What to ask for wherever a record lists the lines it is made of.
    SELECTION = "lineItems { nodes { #{FIELDS.join ' '} } }"

    # The lines worth reading out, from the nodes Jobber answered with. Less than one of a
    # thing is not a thing a page says: Jobber lets a line be quantified at nothing, or at a
    # fraction, and neither reads as work done.
    # @param nodes [Array<Hash>, nil] the lines as Jobber answered them, if it answered any.
    # @return [Array<LineItem>] one per line quantified at one or more.
    def self.from(nodes)
      nodes.to_a.map { |node| new node: node }.select { |item| item.quantity.to_f >= 1 }
    end

    # @return [Integer, Float, nil] how many of it the job is for.
    def quantity = whole @node['quantity']

    # @return [String, nil] what the line is called.
    def name = @node['name']

    # @return [String, nil] what doing it involves, in whoever wrote the line's own words.
    def description = @node['description']

    # @return [String] how a line reads: `3 Faucet install (Fits a new faucet)`, and without
    #   the parenthesis where nobody described it.
    def to_s = [ quantity, name, described ].compact.join ' '

  private

    # Jobber answers a quantity as a Float, and a whole one reads as an Integer: `3 Faucets`
    # rather than `3.0 Faucets`. A fraction keeps its point, since rounding it would lie.
    def whole(number) = number && ((number % 1).zero? ? number.to_i : number)

    def described = ("(#{description})" if description.present?)
  end
end
