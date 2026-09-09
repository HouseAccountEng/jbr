module Jbr
  # A price the business sent to answer a lead, which Jobber calls a request.
  class Quote < Company::Quote
    # @return [Lead, nil] request the quote answers, where Jobber filed one beside it.
    def lead = record Lead, :request

    # Jobber files the total among the quote's amounts.
    # @return [BigDecimal, nil] what the quote comes to, in dollars.
    def amount
      total = @node.dig :amounts, :total
      BigDecimal total.to_s if total.present?
    end
  end
end
