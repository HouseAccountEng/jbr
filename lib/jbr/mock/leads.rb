module Jbr
  # The one lead an app under test asked {Jbr.mock} to answer with.
  class Mock::Leads
    # @return [Company::Lead] lead the app named, whatever was asked to be filed.
    def create(**) = Company::Lead.new node: Jbr.mock.lead.to_h
  end
end
