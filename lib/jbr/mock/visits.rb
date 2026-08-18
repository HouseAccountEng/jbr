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

    # The half of the schedule the list was narrowed to, from what the app dated each visit.
    # One it left undated is one nothing has started, so it counts as upcoming.
    def selected
      return Jbr.mock.visits unless @filter

      started = @filter.dig(:startAt, :before).present?
      Jbr.mock.visits.select { |visit| started?(visit) == started }
    end

    def started?(visit) = visit[:starts_at] ? visit[:starts_at] <= Time.now : false

    def listed(id) = Jbr.mock.visits.to_a.find { |visit| visit[:id] == id }.to_h
  end
end
