require 'test_helper'

# The mock layer answers without a network, so nothing here stubs a request.
class MockTest < Minitest::Test
  def setup = Jbr.mock

  def teardown = Jbr.mock = nil

  def test_the_authorize_url_is_whatever_the_app_asked_for
    Jbr.mock.oauth_url = 'https://example.com/authorize'

    url = Jbr::Account.url_for redirect_uri: 'https://x.test', state: 'abc'

    assert_equal 'https://example.com/authorize', url
  end

  def test_credentials_are_created_and_revoked_without_a_network
    account = Jbr::Account.create code: 'code', redirect_uri: 'https://x.test'

    assert_kind_of Jbr::Mock::Account, account
    assert_equal 'mock-token', account.access_token
    assert_equal 'account-01', account.account_id
    assert_nil account.delete
  end

  def test_a_rejected_flow_raises_the_message_the_app_set
    Jbr.mock.oauth_error = 'Flow rejected'

    error = assert_raises(Jbr::Error) do
      Jbr::Account.create code: 'code', redirect_uri: 'https://x'
    end
    assert_equal 'Flow rejected', error.message
  end

  def test_the_business_is_whatever_the_app_asked_for
    Jbr.mock.business = { id: 'account-02', name: 'Acme Plumbing', phone: '(704) 459-7540' }

    business = credentials.business

    assert_equal 'account-02', business.id
    assert_equal 'Acme Plumbing', business.name
    assert_equal '7044597540', business.phone
  end

  def test_a_lead_is_whatever_the_app_asked_for
    Jbr.mock.lead = { id: 'request-01', customer: { id: 'client-01' } }

    lead = credentials.leads.create title: 'New Plumber Lead'

    assert_equal 'request-01', lead.id
    assert_equal 'client-01', lead.customer.id
  end

  def test_a_quote_is_whatever_the_app_asked_for
    assert_nil credentials.quotes.find('anything')

    Jbr.mock.quote = { id: 'quote-01', lead: { id: 'request-01' } }

    quote = credentials.quotes.find 'anything'

    assert_equal 'quote-01', quote.id
    assert_equal 'request-01', quote.lead.id
  end

  def test_a_job_is_whatever_the_app_asked_for
    scheduled_at = Time.utc 2026, 5, 14
    Jbr.mock.job = { id: 'job-01', quote: { id: 'quote-01' }, scheduled_at: scheduled_at }

    job = credentials.jobs.find 'anything'

    assert_equal 'job-01', job.id
    assert_equal 'quote-01', job.quote.id
    assert_equal scheduled_at, job.scheduled_at
    assert_nil job.completed_at
  end

  def test_an_invoice_is_whatever_the_app_asked_for
    assert_nil credentials.invoices.find('anything')

    issued_at = Time.utc 2026, 5, 22
    Jbr.mock.invoice = { id: 'invoice-01', job: { id: 'job-01' }, amount: 19.99,
                         issued_at: issued_at, }

    invoice = credentials.invoices.find 'anything'

    assert_equal 'invoice-01', invoice.id
    assert_equal 'job-01', invoice.job.id
    assert_equal BigDecimal('19.99'), invoice.amount
    assert_equal issued_at, invoice.fulfilled_at
  end

  def test_the_accounts_go_back_to_jobber_once_the_mock_is_dropped
    Jbr.mock = nil

    refute Jbr.mocked?
    refute_kind_of Jbr::Mock::Account, credentials
  end

private

  def credentials = Jbr::Account.new access_token: 'mock-token'
end
