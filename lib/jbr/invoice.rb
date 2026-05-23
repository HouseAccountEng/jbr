module Jbr
  class Invoice < Resource
    FIND = <<~GRAPHQL.freeze
      query($id: EncodedId!) {
        invoice(id: $id) { id total invoiceStatus issuedDate
          jobs { nodes { id completedAt } } }
      }
    GRAPHQL

    attr_reader :job_id, :total

    def find(id)
      output = @oauth.query FIND, variables: { id: id  }
      return unless invoice = output['invoice']
      return if invoice['invoiceStatus'].eql? 'draft'

      @id = invoice['id']
      @total = invoice['total']
      @issued_at = invoice['issuedDate']

      job = invoice.dig('jobs', 'nodes', 0) || {}
      @job_id = job['id']
      @completed_at = job['completedAt']

      self
    end

    # @return [Date] the invoice issued time
    def issued_at
      Time.iso8601(@issued_at) if @issued_at
    end

    # @return [Time] the job completed time
    def completed_at
      Time.iso8601(@completed_at) if @completed_at
    end
  end
end
