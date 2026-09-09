require 'test_helper'

class LinesTest < Minitest::Test
  def test_a_job_reads_out_the_lines_it_was_asked_for
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01', 'lineItems' => { 'nodes' => [
      { 'id' => 'line-01', 'quantity' => 3.0, 'name' => 'Bathroom Faucet Installation',
        'description' => 'Replace washers and reseat', 'totalPrice' => 285.0, },
      { 'quantity' => 2.0, 'name' => 'Change Toilet Valve' },
      { 'quantity' => 1.5, 'name' => 'Hours of labor' },
      { 'quantity' => 0, 'name' => 'Waived disposal fee' },
      { 'quantity' => nil, 'name' => 'Unquantified' },
    ] }, } ], 'pageInfo' => { 'hasNextPage' => false }, }

    job = account.jobs.includes(:lines).first
    lines = job.lines

    # Every line Jobber holds, in the order it holds them, whatever each is quantified at
    assert_equal [ 'Bathroom Faucet Installation', 'Change Toilet Valve', 'Hours of labor',
                   'Waived disposal fee', 'Unquantified', ], lines.map(&:name)
    assert_equal 'line-01', lines.first.id
    assert_equal 3, lines.first.quantity
    # A line also says what it is and what it comes to: Jobber's totalPrice reads as amount
    assert_equal 'Replace washers and reseat', lines.first.description
    assert_equal 285, lines.first.amount
    # A line Jobber holds neither for answers nil for both
    assert_nil lines.last.description
    assert_nil lines.last.amount
    # A whole quantity reads as an integer, a fraction keeps its point, and a line Jobber
    # holds no quantity for answers none
    assert_in_delta 1.5, lines[2].quantity
    assert_equal 0, lines[3].quantity
    assert_nil lines.last.quantity
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      request.body.include? 'lineItems(first: 20) { nodes { id name description quantity totalPrice'
    end
  end

  def test_lines_nobody_asked_for_do_not_arrive
    stub_graphql 'jobs' => { 'nodes' => [ { 'id' => 'job-01', 'title' => '' } ],
                             'pageInfo' => { 'hasNextPage' => false }, }

    job = account.jobs.first

    assert_empty job.lines
    # Nobody titled it either, so a caller has only the ID to call it by
    assert_equal '', job.description
    assert_requested(:post, JobberStubs::GRAPHQL_URL) do |request|
      !request.body.include? 'lineItems'
    end
  end
end
