module Jbr
  # An invoice an app under test named, keyed by the readers' names rather than Jobber's.
  class Mock::Invoice < Invoice
    # The mock spells every key as the reader is named.
    def self.keys = {}

    # @return [Company::Job, nil] job the app named beside the invoice.
    def job = record Company::Job, :job

  private

    def completed_at = time :completed_at
  end
end
