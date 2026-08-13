module Jbr
  # The visits an app under test asked {Jbr.mock} to answer with.
  class Mock::Visits < Visits
    # @return [Enumerator<Mock::Visit>] every visit the app named.
    def each(&) = mocked(Jbr.mock.visits).each(&)

    # @return [Enumerator<Mock::Visit>] those it dated from now on, and any it left undated.
    def upcoming = mocked Jbr.mock.visits.reject { |visit| started? visit }

    # @return [Enumerator<Mock::Visit>] those it dated before now.
    def past = mocked Jbr.mock.visits.select { |visit| started? visit }

  private

    def mocked(visits)
      Enumerator.new { |yielder| visits.each { |visit| yielder << Mock::Visit.new(node: visit) } }
    end

    def started?(visit) = visit[:starts_at] ? visit[:starts_at] <= Time.now : false
  end
end
