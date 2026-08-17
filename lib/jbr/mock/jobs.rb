module Jbr
  # The jobs an app under test asked {Jbr.mock} to answer with.
  class Mock::Jobs < Jobs
    # The job filed under that ID where the app listed one, and otherwise the single job it
    # named — which is every app that mocks a lookup without mocking a list.
    # @return [Mock::Job] the job asked for.
    def find(id) = Mock::Job.new node: listed(id) || Jbr.mock.job

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

    # Only a real list is looked through: an app that mocked the list as something raising
    # was mocking the walk failing, and a lookup is a question of its own.
    def listed(id) = (Jbr.mock.jobs.find { |job| job[:id] == id } if Jbr.mock.jobs.is_a? Array)
  end
end
