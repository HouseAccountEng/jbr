module Jbr
  # What credentials do when Jobber says the access token is stale, and how they do it safely
  # where many processes hold copies of the same ones: through a store, only one of them asks
  # Jobber for a new token and the rest take the one it wrote.
  module Refreshing
  private

    def refresh
      # With no store there is nobody to compare against: refresh, and leave what we end up
      # holding for the caller to persist.
      return exchange unless @store

      @store.exclusively { |stored| renew stored }
    end

    def renew(stored)
      # Under the store's lock, holding what it says right now. A token that is no longer the one
      # we tried is one somebody else has already replaced, and adopting it asks Jobber nothing —
      # which is what keeps a queue of workers from refreshing a hundred times over, each with a
      # refresh token the first of them has already spent.
      return adopt stored if stored[:access_token] != @access_token

      @refresh_token = stored[:refresh_token]
      exchange.tap { |renewed| @store.write self if renewed }
    end

    def exchange
      adopt self.class.post(refresh_token: @refresh_token, grant_type: 'refresh_token')
    rescue Refused
      refused
    end

    def adopt(credentials)
      @access_token = credentials[:access_token]
      @refresh_token = credentials[:refresh_token]
      @expires_at = credentials[:expires_at]
      true
    end

    def refused
      # Refused while holding the freshest refresh token there is, so the grant itself is dead
      # rather than our copy being behind.
      @invalid_at = Time.now
      @store&.write self
      false
    end
  end
end
