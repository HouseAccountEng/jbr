require 'test_helper'

class JobsTest < Minitest::Test
  def test_every_job_is_walked_when_nothing_is_filtered_for
    client = { 'id' => 'client-01', 'firstName' => 'Jane',
      'phones' => [ { 'normalizedPhoneNumber' => '+15553335555', 'primary' => true,
                      'smsAllowed' => true, } ],
    }
    quote = { 'id' => 'quote-01', 'amounts' => { 'total' => 240.0 } }
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01', 'quote' => quote,
                                            'title' => 'Tune-up', 'instructions' => 'Ring twice',
                                            'jobStatus' => 'archived', 'total' => 260.0,
                                            'client' => client,
                                            'property' => { 'id' => 'property-01',
                                              'address' => { 'street1' => '1 Main St' }, },
                                            'createdAt' => '2026-08-08T11:00:00Z',
                                            'startAt' => '2026-08-09T14:00:00Z',
                                            'completedAt' => '2026-08-10T09:00:00Z', } ],
                             'pageInfo' => { 'hasNextPage' => false },
    }

    job = oauth.jobs.includes(:client, property: :client).first

    assert_equal 'job-01', job.id
    assert_equal 'Tune-up', job.title
    assert_equal 'Tune-up', job.name
    assert_equal 'Ring twice', job.instructions
    assert_equal 'archived', job.status
    assert_equal 'quote-01', job.quote_id
    assert_in_delta 260.0, job.total
    assert_in_delta 240.0, job.quote_total
    assert_equal Time.utc(2026, 8, 8, 11), job.created_at
    assert_equal Time.utc(2026, 8, 9, 14), job.scheduled_at
    assert_equal Time.utc(2026, 8, 10, 9), job.completed_at
    assert_equal 'client-01', job.client.id
    assert_equal '5553335555', job.client.phone
    assert_equal 'property-01', job.property.id
    assert_equal '1 Main St', job.property.street
    assert_requested(:post, JobberStubs::GRAPHQL_URL) { |request| boundary_of(request).nil? }
  end

  def test_a_schedule_is_split_at_the_moment_it_is_asked_about
    stub_graphql 'jobs' => { 'nodes' => [], 'pageInfo' => { 'hasNextPage' => false } }

    assert_empty oauth.jobs.upcoming.to_a
    assert_requested(:post, JobberStubs::GRAPHQL_URL) { |request| boundary_of(request) == 'after' }

    assert_empty oauth.jobs.past.to_a
    assert_requested(:post, JobberStubs::GRAPHQL_URL) { |request| boundary_of(request) == 'before' }
  end

  def test_a_page_carries_only_what_it_was_asked_to
    stub_graphql 'jobs' => { 'nodes' => [], 'pageInfo' => { 'hasNextPage' => false } }

    oauth.jobs.to_a
    assert_requested(:post, JobberStubs::GRAPHQL_URL, times: 1) { |it| asked_of(it) == [] }

    oauth.jobs.includes(:property).to_a
    assert_requested(:post, JobberStubs::GRAPHQL_URL, times: 1) { |it| asked_of(it) == %w[property] }

    oauth.jobs.includes(:client, property: :client).to_a
    assert_requested(:post, JobberStubs::GRAPHQL_URL, times: 1) do |it|
      asked_of(it) == %w[client property client]
    end
  end

private

  # What the query brought back beside the job, in the order it asked for it.
  def asked_of(request) = JSON.parse(request.body)['query'].scan(/\b(client|property) \{/).flatten

  # Which side of now the query asked for, or nil where it asked for no side at all.
  def boundary_of(request)
    JSON.parse(request.body).dig('variables', 'filter', 'startAt')&.keys&.first
  end
end
