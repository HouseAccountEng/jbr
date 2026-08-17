module Jbr
  # Extends a record Jobber itemizes: a job, whose lines say what the work actually was
  # where the title only says what somebody called it.
  module Itemized
    # @return [Array<LineItem>] the lines the record is made of, empty where the query never
    #   asked for them — a page costs what it carries, so nothing nested arrives unasked.
    def line_items = LineItem.from @node.dig('lineItems', 'nodes')
  end
end
