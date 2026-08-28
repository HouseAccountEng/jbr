module Jbr
  # The account that reads from {Jbr.mock} instead of Jobber.
  class Mock::Account < Account
    # @return [Object, nil] the values the app asked for, and 'account-01' for an ID it did not.
    def id = node.fetch :id, 'account-01'

    def name = node[:name]

    def phone = node[:phone]

  private

    def node = Jbr.mock.account.to_h
  end
end
