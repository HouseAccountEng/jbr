require 'test_helper'

# The mock dates nothing it was handed: what an app calls upcoming or past is what it said.
class MockCollectionsTest < Minitest::Test
  def setup = Jbr.mock

  def test_visits_are_whatever_the_app_asked_for
    starts_at = Time.now + 3600
    Jbr.mock.visits = [ { id: 'visit-02', title: 'Fixed it', starts_at: Time.now - 3600 },
                        { id: 'visit-01', title: 'Tune-up', job_id: 'job-01',
                          starts_at: starts_at, all_day: true, client_confirmed: false,
                          property: { id: 'property-01', street: '1 Main St' },
                          client: { id: 'client-01', company_name: 'Ada & Co' }, }, ]

    visit = credentials.visits.upcoming.first

    assert_equal 'visit-01', visit.id
    assert_equal 'Tune-up', visit.title
    assert_equal 'job-01', visit.job_id
    assert_equal '1 Main St', visit.property.street
    assert_equal 'client-01', visit.client.id
    assert_equal 'Ada & Co', visit.client.name
    assert visit.all_day?
    refute visit.client_confirmed?
    assert_equal starts_at, visit.starts_at
    # One the app dated before now answers to past instead, and both answer to neither twice
    assert_equal %w[visit-02], credentials.visits.past.map(&:id)
    assert_equal %w[visit-02 visit-01], credentials.visits.map(&:id)
  end

  def test_jobs_are_whatever_the_app_asked_for
    scheduled_at = Time.now + 3600
    created_at = Time.now - 86_400
    Jbr.mock.jobs = [ { id: 'job-02', scheduled_at: Time.now - 3600 },
                      { id: 'job-01', quote_id: 'quote-01', scheduled_at: scheduled_at,
                        title: 'Tune-up', instructions: 'Ring twice', status: 'archived',
                        total: 260.0, quote_total: 240.0, created_at: created_at,
                        client: { id: 'client-01' },
                        property: { id: 'property-01' }, }, ]

    job = credentials.jobs.upcoming.first

    assert_equal 'job-01', job.id
    assert_equal 'Tune-up', job.title
    assert_equal 'Ring twice', job.instructions
    assert_equal 'archived', job.status
    assert_equal 'quote-01', job.quote_id
    assert_in_delta 260.0, job.total
    assert_in_delta 240.0, job.quote_total
    assert_equal created_at, job.created_at
    assert_equal scheduled_at, job.scheduled_at
    assert_equal 'client-01', job.client.id
    assert_equal 'property-01', job.property.id
    assert_nil job.completed_at
    # The one the app left untitled answers to its ID, since something has to name it
    assert_equal 'job-02', credentials.jobs.past.first.name
    assert_equal %w[job-02], credentials.jobs.past.map(&:id)
    # And a window narrows the half further: the one dated an hour ago is not in the last minute
    assert_empty credentials.jobs.past(60).map(&:id)
    assert_equal %w[job-02 job-01], credentials.jobs.map(&:id)
  end

private

  def credentials = Jbr.oauth_for access_token: 'mock-token'
end
