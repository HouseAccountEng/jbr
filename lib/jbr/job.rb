module Jbr
  # Work a Jobber user accepted and scheduled.
  class Job < Resource
    include Cliental, Named, Properted

    # @return [String, nil] what the job is called, where whoever opened it named it.
    def title = @node['title']

    # @return [String, nil] what the work is, in the words whoever opened the job wrote.
    def instructions = @node['instructions']

    # @return [String, nil] where Jobber files the job in its own workflow.
    def status = @node['jobStatus']

    # @return [String, nil] the ID of the quote the job was won with.
    def quote_id = @node.dig 'quote', 'id'

    # @return [Float, nil] what the job comes to.
    def total = @node['total']

    # @return [Float, nil] what the quote the job was won with came to.
    def quote_total = @node.dig 'quote', 'amounts', 'total'

    # @return [Time, nil] the job opening time
    def created_at = time 'createdAt'

    # @return [Time, nil] the job scheduled time
    def scheduled_at = time 'startAt'

    # @return [Time, nil] the job completed time
    def completed_at = time 'completedAt'
  end
end
