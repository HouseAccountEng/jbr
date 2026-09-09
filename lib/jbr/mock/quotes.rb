module Jbr
  # The one quote an app under test asked {Jbr.mock} to answer with.
  class Mock::Quotes
    # @return [Mock::Quote, nil] quote the app named, whatever ID is asked for.
    def find(_id) = (Mock::Quote.new node: Jbr.mock.quote if Jbr.mock.quote)
  end
end
