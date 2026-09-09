module Jbr
  # The jobs an app under test asked {Jbr.mock} to answer with. Only the walk is mocked:
  # narrowing a list, and reading it as records or as IDs, is the same code a real one runs.
  class Mock::Jobs < Jobs
    # The job filed under that ID where the app listed one, and otherwise the single job it
    # named, which is every app that mocks a lookup without mocking a list.
    # @param id [String] ID the app filed the job under.
    # @return [Company::Job, nil] job asked for, nil where the app named none.
    def find(id)
      node = listed(id) || Jbr.mock.job
      Company::Job.new node: node if node
    end

  private

    def walk(_statement)
      Enumerator.new do |yielder|
        selected.each { |node| yielder << Company::Job.new(node: node) }
      end
    end

    def selected = Jbr.mock.jobs.select { |job| scheduled? job[:scheduled_at] }

    # Only a real list is looked through: an app that mocked the list as something raising
    # was mocking the walk failing, and a lookup is a question of its own.
    def listed(id) = (Jbr.mock.jobs.find { |job| job[:id] == id } if Jbr.mock.jobs.is_a? Array)
  end
end
