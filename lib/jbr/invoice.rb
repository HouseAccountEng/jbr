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
      job = output.dig('jobs', 'nodes', 0) || {}
      @id = job['id']
      @status = job['invoiceStatus']
      @total = job['total']
      @issued_date = job['issuedDate']
      @completed_at = job['completedAt']
      self
    end

    # @return [Date] the invoice issued date
    def issued_date
      Date.iso8601(@issued_date) if @issued_date
    end

    # @return [Time] the job completed time
    def completed_at
      Time.iso8601(@completed_at) if @completed_at
    end
  end
end
