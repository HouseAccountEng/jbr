require 'test_helper'

class ResourcesTest < Minitest::Test
  def test_the_account_is_fetched_once_however_much_of_it_is_read
    fetched = stub_graphql 'account' => {
      'id' => 'account-01', 'name' => 'Acme Plumbing', 'phone' => '(704) 459-7540',
    }
    account = oauth.account

    assert_equal 'account-01', account.id
    assert_equal 'Acme Plumbing', account.name
    assert_equal '(704) 459-7540', account.phone
    assert_requested fetched, times: 1
  end

  def test_a_quote_carries_the_request_it_came_from
    stub_graphql 'quote' => { 'id' => 'quote-01', 'request' => { 'id' => 'request-01' } }

    quote = oauth.quotes.find 'quote-01'

    assert_equal 'quote-01', quote.id
    assert_equal 'request-01', quote.request_id
  end

  def test_a_missing_quote_is_nil
    stub_graphql 'quote' => nil

    assert_nil oauth.quotes.find('quote-01')
  end

  def test_a_job_carries_its_quote_and_its_times
    stub_graphql 'job' => { 'id' => 'job-01', 'quote' => { 'id' => 'quote-01' },
                            'startAt' => '2026-05-14T23:02:52Z',
                            'completedAt' => '2026-05-18T11:36:13Z',
    }

    job = oauth.jobs.find 'job-01'

    assert_equal 'quote-01', job.quote_id
    assert_equal Time.utc(2026, 5, 14, 23, 2, 52), job.scheduled_at
    assert_equal Time.utc(2026, 5, 18, 11, 36, 13), job.completed_at
  end

  def test_an_unscheduled_job_has_no_times
    stub_graphql 'job' => { 'id' => 'job-01', 'startAt' => nil, 'completedAt' => nil }

    job = oauth.jobs.find 'job-01'

    assert_nil job.scheduled_at
    assert_nil job.completed_at
  end

  def test_a_missing_job_is_nil
    stub_graphql 'job' => nil

    assert_nil oauth.jobs.find('job-01')
  end

  def test_an_invoice_carries_its_job_its_total_and_its_dates
    stub_graphql 'invoice' => { 'id' => 'invoice-01', 'total' => '40.30',
                                'invoiceStatus' => 'sent', 'issuedDate' => '2026-05-22T12:12:53Z',
                                'jobs' => { 'nodes' => [ { 'id' => 'job-01',
                                                           'completedAt' => '2026-05-22T14:32:53Z',
                                } ] },
    }

    invoice = oauth.invoices.find 'invoice-01'

    assert_equal 'job-01', invoice.job_id
    assert_equal '40.30', invoice.total
    assert_equal Time.utc(2026, 5, 22, 12, 12, 53), invoice.issued_at
    assert_equal Time.utc(2026, 5, 22, 14, 32, 53), invoice.completed_at
  end

  def test_an_invoice_with_no_job_has_no_dates
    stub_graphql 'invoice' => { 'id' => 'invoice-01', 'invoiceStatus' => 'sent',
                                'issuedDate' => nil, 'jobs' => { 'nodes' => [] },
    }

    invoice = oauth.invoices.find 'invoice-01'

    assert_nil invoice.job_id
    assert_nil invoice.issued_at
    assert_nil invoice.completed_at
  end

  def test_a_draft_invoice_is_nil
    stub_graphql 'invoice' => { 'id' => 'invoice-01', 'invoiceStatus' => 'draft' }

    assert_nil oauth.invoices.find('invoice-01')
  end

  def test_a_missing_invoice_is_nil
    stub_graphql 'invoice' => nil

    assert_nil oauth.invoices.find('invoice-01')
  end
end
