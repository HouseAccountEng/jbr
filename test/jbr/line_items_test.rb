require 'test_helper'

class LineItemsTest < Minitest::Test
  def test_a_job_reads_out_the_lines_it_was_asked_for
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01', 'lineItems' => { 'nodes' => [
      { 'quantity' => 3.0, 'name' => 'Bathroom Faucet Installation',
        'description' => 'Professional installation of a new bathroom faucet', },
      { 'quantity' => 2.0, 'name' => 'Change Toilet Valve', 'description' => nil },
      { 'quantity' => 1.5, 'name' => 'Hours of labour', 'description' => 'At the hourly rate' },
      { 'quantity' => 0.5, 'name' => 'Half a call-out', 'description' => 'Shared with next door' },
      { 'quantity' => 0, 'name' => 'Waived disposal fee', 'description' => 'Not charged' },
      { 'quantity' => nil, 'name' => 'Unquantified', 'description' => 'Nobody said how many' },
    ] } } ], 'pageInfo' => { 'hasNextPage' => false } }

    job = oauth.jobs.includes(:line_items).first
    items = job.line_items

    # Under one of a thing is not a thing, whether it is a fraction, none, or unsaid
    assert_equal ['Bathroom Faucet Installation', 'Change Toilet Valve', 'Hours of labour'],
                 items.map(&:name)
    assert_equal 3, items.first.quantity
    assert_equal 'Professional installation of a new bathroom faucet', items.first.description
    assert_equal '3 Bathroom Faucet Installation ' \
                 '(Professional installation of a new bathroom faucet)', items.first.to_s
    # A line nobody described reads without the empty parenthesis
    assert_equal '2 Change Toilet Valve', items[1].to_s
    # And a fraction of more than one keeps its point, since rounding it would lie
    assert_in_delta 1.5, items[2].quantity
    assert_equal '1.5 Hours of labour (At the hourly rate)', items[2].to_s
    # And a job summarizes itself by its lines, each as how many of what
    assert_equal '3 Bathroom Faucet Installation, 2 Change Toilet Valve, ' \
                 'and 1.5 Hours of labour', job.summary
    assert_requested(:post, JobberStubs::GRAPHQL_URL) { |request| request.body.include? 'lineItems' }
  end

  def test_lines_nobody_asked_for_do_not_arrive
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01' } ],
                             'pageInfo' => { 'hasNextPage' => false } }

    job = oauth.jobs.first

    assert_empty job.line_items
    # With no lines to summarize, a job reads as whatever it is called -- here its ID, since
    # nobody titled it either
    assert_equal 'job-01', job.summary
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      !request.body.include? 'lineItems'
    end
  end
end
