module Jbr
  # One line of the work a job is made of.
  class Line < Company::Line
    # The node keys Jobber spells otherwise than the vocabulary.
    def self.keys = { amount: :totalPrice }

    # The most lines to read off one record. Bounded because Jobber prices a connection by the
    # page it is asked for and prices an unbounded one at its own maximum, so the lines of a
    # page of jobs were charged for as though every job had the largest job's worth of them.
    PAGE = 20

    # What to ask for wherever a record lists the lines it is made of.
    SELECTION = "lineItems(first: #{PAGE}) { nodes { #{node_keys.join ' '} } }"
  end
end
