module Jbr
  # Work the business accepted and scheduled.
  class Job < Company::Job
    # The node keys Jobber spells otherwise than the vocabulary.
    def self.keys
      { description: :title, created_at: :createdAt, scheduled_at: :startAt,
        completed_at: :completedAt, amount: :total, }
    end

    # @return [String, nil] ID of the quote the job was won with.
    def quote_id = @node.dig :quote, :id

    # @return [BigDecimal, nil] what that quote came to, in dollars.
    def quote_amount
      total = @node.dig :quote, :amounts, :total
      BigDecimal total.to_s if total.present?
    end

    # @return [Array<Line>] lines the job is made of, empty where the query never asked for
    #   them: a page costs what it carries, so nothing nested arrives unasked.
    def lines = @node.dig(:lineItems, :nodes).to_a.map { |node| Line.new node: node }

    # @return [Location, nil] where the work happens, where it came back beside the job.
    def location = record Location, :property
  end
end
