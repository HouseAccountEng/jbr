module Jbr
  # The numbers on a client's file, and which of them the client is reached on.
  class Phone
    # What Jobber is asked for wherever a client is read: the number, and what ranks it.
    SELECTION = 'phones { normalizedPhoneNumber smsAllowed primary }'

    # What the North American plan recognizes: ten digits whose area code and exchange both
    # open with 2 through 9. Jobber normalizes to E.164, so the country code leads. Anything
    # else -- a number abroad, an extension, whatever somebody typed -- is not a match.
    NORTH_AMERICAN = /\A\+1([2-9]\d{2}[2-9]\d{6})\z/

    # The number to reach a client on, without its country code: the primary before the
    # rest, one that takes texts before one that does not, and the first of those the North
    # American plan recognizes. A file holding none we can dial answers nothing.
    # @param phones [Array<Hash>, nil] the numbers as Jobber answered them.
    # @return [String, nil] the ten digits to call, or nil when no number qualifies.
    def self.from(phones)
      ranked = Array(phones).each_with_index.sort_by do |phone, index|
        [ phone['primary'] ? 0 : 1, phone['smsAllowed'] ? 0 : 1, index ]
      end
      numbers = ranked.lazy.map { |phone, _| phone['normalizedPhoneNumber'].to_s }
      numbers.filter_map { |number| number[NORTH_AMERICAN, 1] }.first
    end
  end
end
