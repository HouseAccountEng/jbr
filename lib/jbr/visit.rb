module Jbr
  # One stop of a job: when the work is scheduled to happen.
  class Visit < Company::Visit
    # The node keys Jobber spells otherwise than the vocabulary.
    def self.keys
      { description: :title, starts_at: :startAt, ends_at: :endAt, all_day: :allDay,
        confirmed: :clientConfirmed, }
    end

    # @return [Location, nil] where the stop happens, where it came back beside the visit.
    def location = record Location, :property
  end
end
