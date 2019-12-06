require 'minitest/autorun'
# range 193651-649729
# 6 digit
# Two adjacent digits are the same (like 22 in 122345).
# Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).
# Other than the range rule, the following are true:

#  111111 meets these criteria (double 11, never decreases).
#  223450 does not meet these criteria (decreasing pair of digits 50).
#  123789 does not meet these criteria (no double).
class Day4 < MiniTest::Test
  INPUT = (193651..649729).freeze

  def test_passwords_count
    passwords = []
    INPUT.each do |n|
      passwords << n if increasing_and_two_adjacent_digits?(n)
    end
    puts passwords.count
  end

  def test_digits_never_decrease
    assert !increasing?(193651)
    assert !increasing?(567780)
    assert increasing?(199999)
    assert increasing?(178999)
  end

  private
  # Two adjacent digits are the same (like 22 in 122345).
  # and are not part of a larger group of matching digits.
  # Check digits are non-decreasing,
  # so we can just count the occurrences of each digit,
  # and not worry about occurrences being separated!
  def increasing_and_two_adjacent_digits?(n)
    increasing?(n) &&
      n.digits.group_by(&:itself).values.map(&:size).include?(2)
  end

  def increasing?(n)
    prev = 10
    while n > 0
      n, curr = n.divmod(10)
      return false if curr > prev

      prev = curr
    end
    true
  end
end
