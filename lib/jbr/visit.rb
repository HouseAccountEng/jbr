module Jbr
  # One stop at a property: when the work on a job is scheduled to happen.
  class Visit < Resource
    include Cliental, Named, Properted

    # @return [String, nil] what the visit is called.
    def title = @node['title']

    # @return [String, nil] the ID of the job the visit belongs to.
    def job_id = @node.dig 'job', 'id'

    # @return [Boolean, nil] whether the visit takes the whole day rather than an hour of it.
    def all_day? = @node['allDay']

    # @return [Boolean, nil] whether the client has confirmed the visit.
    def client_confirmed? = @node['clientConfirmed']

    # @return [Time, nil] the visit start time
    def starts_at = time 'startAt'

    # @return [Time, nil] the visit end time
    def ends_at = time 'endAt'
  end
end
