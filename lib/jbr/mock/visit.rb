module Jbr
  # A visit an app under test listed, keyed by the vocabulary's names rather than Jobber's.
  class Mock::Visit < Visit
    # The mock spells every key as the reader is named.
    def self.keys = {}

    # @return [Company::Location, nil] place the app listed beside the visit.
    def location = record Company::Location, :location
  end
end
