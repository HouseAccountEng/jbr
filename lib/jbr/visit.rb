module Jbr
  # One stop of a job: when the work is scheduled to happen.
  class Visit < Company::Visit
    # What every visit reads: the vocabulary's names, and whether the client confirmed it,
    # which Jobber alone asks.
    def self.attributes = super + %i[confirmed]

    # The node keys Jobber spells otherwise than the vocabulary.
    def self.keys
      { description: :title, starts_at: :startAt, ends_at: :endAt, anytime: :allDay,
        confirmed: :clientConfirmed, }
    end

    # @return [Boolean, nil] whether the client confirmed the visit.
    def confirmed? = attribute :confirmed

    # @return [Location, nil] where the stop happens, where it came back beside the visit.
    def location = record Location, :property
  end
end
