module Jbr
  # A bill the business issued for finished work.
  class Invoice < Company::Invoice
    # The node keys Jobber spells otherwise than the vocabulary.
    def self.keys = { amount: :total, issued_at: :issuedDate }

    # Jobber lists the jobs an invoice bills, and one it bills one.
    # @return [Job, nil] job the invoice bills, where Jobber listed one.
    def job
      node = @node.dig :jobs, :nodes, 0
      Job.new node: node if node
    end

  private

    def completed_at = job&.completed_at
  end
end
