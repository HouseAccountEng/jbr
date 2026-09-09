module Jbr
  # The one invoice an app under test asked {Jbr.mock} to answer with.
  class Mock::Invoices
    # @return [Company::Invoice, nil] invoice the app named, whatever ID is asked for.
    def find(_id) = (Company::Invoice.new node: Jbr.mock.invoice if Jbr.mock.invoice)
  end
end
