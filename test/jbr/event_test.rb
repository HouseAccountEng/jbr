require 'test_helper'

class EventTest < Minitest::Test
  def test_an_event_names_its_account_and_its_item
    event = Jbr::Event.new Jbr::Event.params_for(item_id: 'job-01', account_id: 'account-01')

    assert_equal 'job-01', event.item_id
    assert_equal 'account-01', event.account_id
  end

  def test_a_payload_that_is_not_an_event_names_nothing
    event = Jbr::Event.new({})

    assert_nil event.item_id
    assert_nil event.account_id
  end
end
