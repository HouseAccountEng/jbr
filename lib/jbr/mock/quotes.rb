module Jbr
  # The one quote an app under test asked {Jbr.mock} to answer with.
  class Mock::Quotes
    # @return [Company::Quote, nil] quote the app named, whatever ID is asked for.
    def find(_id) = (Company::Quote.new node: Jbr.mock.quote if Jbr.mock.quote)
  end
end
