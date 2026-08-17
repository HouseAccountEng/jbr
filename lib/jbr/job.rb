module Jbr
  # Work a Jobber user accepted and scheduled.
  class Job < Resource
    include Cliental, Itemized, Named, Properted

    # @return [String, nil] what the job is called, where whoever opened it named it.
    def title = @node['title']

    # @return [String, nil] what the work is, in the words whoever opened the job wrote.
    def instructions = @node['instructions']

    # What the job's lines add up to, each as how many of what: `3 Faucet install and 2 Valve
    # change` — `to_sentence` reading each line's own string form. The lines say what the work
    # was where a title only says what it was called, so this reads better than one, and falls
    # back to {#name} where the job has no lines or the query never asked for them.
    # @return [String] the lines as a sentence, or the title, or the ID. Never nil, never empty.
    def summary = line_items.to_sentence.presence || name

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
