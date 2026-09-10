module Jbr
  # A bill the business issued for finished work, which Jobber alone answers for.
  class Invoice < Company::Resource
    # What every invoice reads.
    def self.attributes = %i[id amount completed_at issued_at]

    # The node keys Jobber spells otherwise than the readers.
    def self.keys = { amount: :total, issued_at: :issuedDate }

    # Jobber lists the jobs an invoice bills, and one it bills one.
    # @return [Job, nil] job the invoice bills, where Jobber listed one.
    def job
      node = @node.dig :jobs, :nodes, 0
      Job.new node: node if node
    end

    # @return [BigDecimal, nil] what the invoice comes to, in dollars.
    def amount = decimal :amount

    # @return [Time, nil] moment the billed work was finished, or the bill issued where undated.
    def fulfilled_at = completed_at || issued_at

  private

    def completed_at = job&.completed_at

    def issued_at = time :issued_at
  end
end
