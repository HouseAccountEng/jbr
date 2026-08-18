module Jbr
  # The visits an app under test asked {Jbr.mock} to answer with. Only the walk is mocked:
  # narrowing a list, and reading it as records or as IDs, is the same code a real one runs.
  class Mock::Visits < Visits
    # @return [Mock::Visit] the visit the app listed under that ID.
    def find(id) = Mock::Visit.new node: listed(id)

  private

    def walk(_statement)
      Enumerator.new { |yielder| selected.each { |it| yielder << Mock::Visit.new(node: it) } }
    end

    def selected = Jbr.mock.visits.select { |visit| scheduled? visit[:starts_at] }

    def listed(id) = Jbr.mock.visits.to_a.find { |visit| visit[:id] == id }.to_h
  end
end
