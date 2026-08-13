module Jbr
  # The jobs an app under test asked {Jbr.mock} to answer with.
  class Mock::Jobs < Jobs
    # @return [Mock::Job] the one job the app named, whatever ID is asked for.
    def find(_) = Mock::Job.new node: Jbr.mock.job

    # @return [Enumerator<Mock::Job>] every job the app named.
    def each(&) = mocked(Jbr.mock.jobs).each(&)

    # @return [Enumerator<Mock::Job>] those it dated from now on, and any it left undated.
    def upcoming = mocked Jbr.mock.jobs.reject { |job| started? job }

    # @return [Enumerator<Mock::Job>] those it dated before now.
    def past = mocked Jbr.mock.jobs.select { |job| started? job }

  private

    def mocked(jobs)
      Enumerator.new { |yielder| jobs.each { |job| yielder << Mock::Job.new(node: job) } }
    end

    def started?(job) = job[:scheduled_at] ? job[:scheduled_at] <= Time.now : false
  end
end
