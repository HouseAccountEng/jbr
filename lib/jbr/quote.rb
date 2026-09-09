module Jbr
  # A price the business sent to answer a lead, which Jobber calls a request.
  class Quote < Company::Quote
    # @return [String, nil] ID of the request the quote answers.
    def lead_id = @node.dig :request, :id
  end
end
