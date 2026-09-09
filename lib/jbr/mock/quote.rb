module Jbr
  # A quote an app under test named, its lead under the mock's own key rather than Jobber's.
  class Mock::Quote < Quote
    # @return [Company::Lead, nil] lead the app named beside the quote.
    def lead = record Company::Lead, :lead
  end
end
