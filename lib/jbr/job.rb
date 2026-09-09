module Jbr
  # Work the business accepted and scheduled.
  class Job < Company::Job
    # The node keys Jobber spells otherwise than the vocabulary.
    def self.keys
      { description: :title, notes: :instructions, created_at: :createdAt,
        scheduled_at: :startAt, completed_at: :completedAt, amount: :total, }
    end

    # @return [Quote, nil] quote the job was won with, where Jobber filed one beside it.
    def quote = record Quote, :quote

    # @return [Array<Line>] lines the job is made of, empty where the query never asked for
    #   them: a page costs what it carries, so nothing nested arrives unasked.
    def lines = @node.dig(:lineItems, :nodes).to_a.map { |node| Line.new node: node }

    # @return [Location, nil] where the work happens, where it came back beside the job.
    def location = record Location, :property
  end
end
