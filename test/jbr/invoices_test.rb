require 'test_helper'

class InvoicesTest < Minitest::Test
  def test_an_invoice_carries_its_job_its_amount_and_the_moment_the_work_was_finished
    stub_graphql 'invoice' => { 'id' => 'invoice-01', 'total' => '40.30',
                                'invoiceStatus' => 'sent', 'issuedDate' => '2026-05-22T12:12:53Z',
                                'jobs' => { 'nodes' => [ { 'id' => 'job-01',
                                                           'completedAt' => '2026-05-22T14:32:53Z',
                                } ] },
    }

    invoice = account.invoices.find 'invoice-01'

    assert_equal 'invoice-01', invoice.id
    assert_equal 'job-01', invoice.job_id
    assert_equal BigDecimal('40.30'), invoice.amount
    assert_equal Time.utc(2026, 5, 22, 14, 32, 53), invoice.fulfilled_at
  end

  def test_an_invoice_for_unfinished_work_is_fulfilled_when_it_was_issued
    stub_graphql 'invoice' => { 'id' => 'invoice-01', 'invoiceStatus' => 'sent',
                                'issuedDate' => '2026-05-22T12:12:53Z',
                                'jobs' => { 'nodes' => [ { 'id' => 'job-01' } ] },
    }

    assert_equal Time.utc(2026, 5, 22, 12, 12, 53), account.invoices.find('invoice-01').fulfilled_at
  end

  def test_an_invoice_with_no_job_has_no_job_and_no_dates
    stub_graphql 'invoice' => { 'id' => 'invoice-01', 'invoiceStatus' => 'sent',
                                'issuedDate' => nil, 'jobs' => { 'nodes' => [] },
    }

    invoice = account.invoices.find 'invoice-01'

    assert_nil invoice.job_id
    assert_nil invoice.amount
    assert_nil invoice.fulfilled_at
  end

  def test_a_draft_invoice_is_nil
    stub_graphql 'invoice' => { 'id' => 'invoice-01', 'invoiceStatus' => 'draft' }

    assert_nil account.invoices.find('invoice-01')
  end

  def test_a_missing_invoice_is_nil
    stub_graphql 'invoice' => nil

    assert_nil account.invoices.find('invoice-01')
  end
end
