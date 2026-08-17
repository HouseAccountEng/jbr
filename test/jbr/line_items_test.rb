require 'test_helper'

class LineItemsTest < Minitest::Test
  def test_a_job_reads_out_the_lines_it_was_asked_for
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01', 'lineItems' => { 'nodes' => [
      { 'quantity' => 3.0, 'name' => 'Bathroom Faucet Installation' },
      { 'quantity' => 2.0, 'name' => 'Change Toilet Valve' },
      { 'quantity' => 1.5, 'name' => 'Hours of labour' },
      { 'quantity' => 0, 'name' => 'Waived disposal fee' },
      { 'quantity' => nil, 'name' => 'Unquantified' },
    ] }, } ], 'pageInfo' => { 'hasNextPage' => false }, }

    job = oauth.jobs.includes(:line_items).first
    items = job.line_items

    # Every line Jobber holds, in the order it holds them, whatever each is quantified at
    assert_equal [ 'Bathroom Faucet Installation', 'Change Toilet Valve', 'Hours of labour',
                   'Waived disposal fee', 'Unquantified', ], items.map(&:name)
    assert_equal 3, items.first.quantity
    assert_equal '3 Bathroom Faucet Installation', items.first.to_s
    # A whole quantity reads as an integer and a fraction keeps its point
    assert_in_delta 1.5, items[2].quantity
    assert_equal '1.5 Hours of labour', items[2].to_s
    # A line Jobber holds no quantity for reads as its name alone
    assert_equal 'Unquantified', items.last.to_s
    # And a job summarizes itself by its lines, each as how many of what
    assert_equal '3 Bathroom Faucet Installation, 2 Change Toilet Valve, 1.5 Hours of labour, ' \
                 '0 Waived disposal fee, and Unquantified', job.summary
    assert_requested(:post, JobberStubs::GRAPHQL_URL) { |request| request.body.include? 'lineItems' }
  end

  def test_lines_nobody_asked_for_do_not_arrive
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01' } ],
                             'pageInfo' => { 'hasNextPage' => false }, }

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
