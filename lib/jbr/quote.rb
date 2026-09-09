module Jbr
  # A price the business sent to answer a lead, which Jobber calls a request.
  class Quote < Company::Quote
    # @return [String, nil] ID of the request the quote answers.
    def lead_id = @node.dig :request, :id

    # Jobber files the total among the quote's amounts.
    # @return [BigDecimal, nil] what the quote comes to, in dollars.
    def amount
      total = @node.dig :amounts, :total
      BigDecimal total.to_s if total.present?
    end
  end
end
