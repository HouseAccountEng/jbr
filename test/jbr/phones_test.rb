require 'test_helper'

class PhonesTest < Minitest::Test
  def test_the_primary_number_is_the_one_to_call
    phones = [ dialable('+15553335555'), dialable('+15554446666', primary: true) ]

    assert_equal '5554446666', Jbr::Phone.from(phones)
  end

  def test_a_number_that_takes_texts_wins_among_the_rest
    phones = [ dialable('+15553335555', sms: false), dialable('+15554446666') ]

    assert_equal '5554446666', Jbr::Phone.from(phones)
  end

  # Ranking picks the number to try first, not the number to answer: a primary line abroad
  # is still a line we cannot dial, so the search carries on past it.
  def test_a_number_outside_the_plan_is_passed_over_however_it_ranks
    phones = [ dialable('+441632960001', primary: true), dialable('+15553335555') ]

    assert_equal '5553335555', Jbr::Phone.from(phones)
  end

  def test_a_client_with_nothing_to_dial_has_no_phone
    assert_nil Jbr::Phone.from([ dialable('+441632960001'), dialable('+1555333555') ])
    assert_nil Jbr::Phone.from([ dialable('+11553335555') ])
    assert_nil Jbr::Phone.from([])
    assert_nil Jbr::Phone.from(nil)
  end

private

  def dialable(number, primary: false, sms: true)
    { 'normalizedPhoneNumber' => number, 'primary' => primary, 'smsAllowed' => sms }
  end
end
