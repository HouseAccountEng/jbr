module Jbr
  # A person the business works for, who Jobber calls a client.
  class Customer < Company::Customer
    # The node keys Jobber spells otherwise than the vocabulary.
    def self.keys = { name: :firstName, surname: :lastName }

    # What Jobber calls each flat field of a client. The phones nest: see {Phone}.
    FIELDS = 'id firstName lastName companyName email'

    # What to ask for wherever a record names its client.
    SELECTION = "client { #{FIELDS} #{Phone::SELECTION} }"

    # Jobber files nobody without one name or the other, so there is always one to call them.
    # @return [String, nil] first name, or the business's name where a person has none.
    def name = super.presence || attribute(:companyName).presence

    # @return [String, nil] ten digits they are reached on, nil where none can be dialed.
    def phone = Phone.from @node[:phones]

    # @return [Array<Location>] places on their file, where the query asked for them.
    def locations = @node.dig(:clientProperties, :nodes).to_a.map { |node| Location.new node: node }
  end
end
