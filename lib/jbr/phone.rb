module Jbr
  # The numbers on a client's file, and which of them the client is reached on.
  class Phone
    # What Jobber is asked for wherever a client is read: the number, and what ranks it.
    SELECTION = 'phones { normalizedPhoneNumber smsAllowed primary }'

    # Ten digits whose area code and exchange open with 2 through 9, behind the E.164 +1.
    NORTH_AMERICAN = /\A\+1([2-9]\d{2}[2-9]\d{6})\z/

    # The number to reach a client on, without its country code.
    # @param phones [Array<Hash>, nil] the numbers as Jobber answered them.
    # @return [String, nil] the ten digits to call, or nil where none can be dialed.
    def self.from(phones)
      # The index breaks a tie because sort_by does not: two equally ranked numbers would
      # otherwise swap between runs, and the client would answer a different phone each time.
      ranked = Array(phones).each_with_index.sort_by do |phone, index|
        [ phone['primary'] ? 0 : 1, phone['smsAllowed'] ? 0 : 1, index ]
      end
      numbers = ranked.lazy.map { |phone, _| phone['normalizedPhoneNumber'].to_s }
      numbers.filter_map { |number| number[NORTH_AMERICAN, 1] }.first
    end
  end
end
