module Jbr
  # Extends a record Jobber lets go untitled: a visit, a job, anything somebody may have
  # opened without ever typing a name for it.
  module Named
    # Untitled happens often enough, and something has to stand in for it on a list.
    # @return [String] the title, or the ID Jobber files the record under. Never empty.
    def name = title.presence || id
  end
end
