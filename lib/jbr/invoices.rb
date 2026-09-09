module Jbr
  # The invoices on a Jobber account, each reached by the ID Jobber files it under.
  class Invoices < Collection
    # The query that reads one invoice, its total, its date and the job it bills.
    FIND = <<~GRAPHQL
      query($id: EncodedId!) {
        invoice(id: $id) { id total invoiceStatus issuedDate jobs { nodes { id completedAt } } }
      }
    GRAPHQL

    # @param id [String] Jobber ID of the invoice.
    # @return [Invoice, nil] nil when Jobber has no invoice under that ID, or holds it as a draft.
    def find(id)
      node = @account.query(FIND, variables: { id: id })['invoice']
      Invoice.new node: node if node && node['invoiceStatus'] != 'draft'
    end
  end
end
