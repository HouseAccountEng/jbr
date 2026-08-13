module Jbr
  # Extends a record that names the client the work is for: a visit, a job, a property,
  # anything Jobber files under somebody.
  module Cliental
    # What Jobber calls each field of that client.
    FIELDS = %w[id firstName lastName companyName email]

    # What to ask for wherever a record names its client.
    SELECTION = "client { #{FIELDS.join ' '} #{Phone::SELECTION} }"

    # @return [Client] who the work is for.
    def client = Client.new node: @node.fetch('client', {})
  end
end
