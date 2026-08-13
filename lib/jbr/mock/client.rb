module Jbr
  # A client that reads from {Jbr.mock} instead of Jobber.
  class Mock::Client < Client
    # @return [Object, nil] the values the app asked for.
    def id = @node[:id]

    def first_name = @node[:first_name]

    def last_name = @node[:last_name]

    def company_name = @node[:company_name]

    def email = @node[:email]

    def phone = @node[:phone]
  end
end
