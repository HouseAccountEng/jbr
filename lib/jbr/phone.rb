module Jbr
  # The numbers on a client's file, and which of them the client is reached on.
  class Phone
    # What Jobber is asked for wherever a client is read: the number, and what ranks it.
    SELECTION = 'phones { normalizedPhoneNumber smsAllowed primary }'

    # The primary number first, then one that takes texts, then the rest as filed; the first
    # of them that can be dialed is the one.
    # @param phones [Array<Hash>, nil] numbers as Jobber answered them.
    # @return [String, nil] ten digits to call, or nil where none can be dialed.
    def self.from(phones)
      # The index breaks a tie because sort_by does not: two equally ranked numbers would
      # otherwise swap between runs, and the client would answer a different phone each time.
      ranked = Array(phones).each_with_index.sort_by do |phone, index|
        [ phone['primary'] ? 0 : 1, phone['smsAllowed'] ? 0 : 1, index ]
      end
      ranked.lazy.filter_map { |phone, _| Company::Phone.from phone['normalizedPhoneNumber'] }.first
    end
  end
end
