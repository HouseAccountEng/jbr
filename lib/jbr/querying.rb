module Jbr
  # What credentials do with a statement: post it to Jobber, refresh a stale token once, and
  # raise every refusal as a {Error} so a caller rescues one class.
  module Querying
    # Where every query and mutation is posted.
    ENDPOINT = 'https://api.getjobber.com/api/graphql'

    # The version of the schema every statement is written against.
    HEADERS = { 'X-JOBBER-GRAPHQL-VERSION' => '2026-04-22' }

    # The mutation that revokes the app on the account.
    DISCONNECT = <<~GRAPHQL
      mutation Disconnect {
        appDisconnect {
          app { name author }
          userErrors { message }
        }
      }
    GRAPHQL

    # Nothing here ever sleeps: where Jobber holds the app to a limit it says so, and a caller
    # asking from a background job has a queue that will bring the whole job back later.
    # @param statement [String] query or mutation to run.
    # @param variables [Hash] what the statement takes.
    # @return [Hash] data Jobber answered, or empty when the credentials are dead.
    # @raise [Retriable] where Jobber refused the statement for what it costs.
    # @raise [Error] where Jobber refused the statement, or took a mutation and would not act.
    def query(statement, variables: {})
      data = client.query statement, variables: variables
      refusals = user_errors(data).map { |error| error['message'] }
      raise Error, refusals.join('; ') if refusals.any?

      data
    rescue GraphQL::Unauthorized
      refresh ? retry : {}
    rescue GraphQL::Throttled => error
      raise Retriable, error.message
    rescue GraphQL::Error => error
      raise Error, error.message
    end

    # Revoke the credentials on the account. Dead ones have nothing left to revoke.
    def delete
      client.query DISCONNECT
    rescue GraphQL::Unauthorized
    end

  private

    def client
      GraphQL::Client.new endpoint: ENDPOINT, token: @access_token, headers: HEADERS
    end

    # A mutation Jobber took but would not act on answers 200, with the reasons under the
    # mutation's own field rather than beside the data.
    def user_errors(data)
      fields = data.each_value.select { |field| field.is_a? Hash }
      fields.flat_map { |field| Array(field['userErrors']) }
    end
  end
end
