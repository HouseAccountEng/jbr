module Jbr
  class Client < Resource
    LOOKUP = <<~GRAPHQL.freeze
      query($searchTerm: String!) {
        clientPhones(searchTerm: $searchTerm) { nodes { client { id updatedAt } } }
      }
    GRAPHQL

    CREATE = <<~GRAPHQL.freeze
      mutation($input: ClientCreateInput!) {
        clientCreate(input: $input) { client { id } userErrors { message } }
      }
    GRAPHQL

    # Create a client instance with the provided attributes.
    # @return [Client] itself
    # @param params [Hash] the attributes of the client
    # @option params [String] :first_name the client’s first name
    # @option params [String] :last_name the client’s last name
    # @option params [String] :phone the client’s phone number
    # @option params [<String, nil>] :email the client’s email address
    def create_with(params = {})
      self.tap { @create_params = params }
    end

    def find_or_create_by(phone:)
      find_by_phone(phone) || create
      self
    end

  private

    def find_by_phone(phone)
      output = @oauth.query LOOKUP, variables: { searchTerm: phone }
      recent = (output.dig('clientPhones', 'nodes') || []).max_by do |clients|
        clients.dig('client', 'updatedAt') || ''
      end
      @id = recent&.dig 'client', 'id'
    end

    def create
      output = @oauth.query CREATE, variables: { input: input }
      @id = output.dig 'clientCreate', 'client', 'id'
    end

    def input
      { firstName: @create_params[:first_name],
        lastName: @create_params[:last_name],
        phones: [{ number: @create_params[:phone], primary: true }],
        emails: ([{ address: @create_params[:email], primary: true }] if @create_params[:email].present?)
      }.compact
    end
  end
end
