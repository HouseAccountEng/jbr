module Jbr
  # The one account every mocked set of credentials belongs to.
  class Mock::Account < Account
    # @return [String] the mocked account ID.
    def id = 'account-01'
  end
end
