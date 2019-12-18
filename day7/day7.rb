#frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/intcode'

# https://adventofcode.com/2019/day/7
class Day7 < MiniTest::Test
  PHASES = (0..4).to_a.permutation(5).to_a.freeze
  PHASES_FEEDBACK_LOOP_MODE = (5..9).to_a.permutation(5).to_a.freeze

  AMPLIFIER_CONTROLLER_SOFTWARE = DATA.read.split(',').map(&method(:Integer)).freeze

  def test_max_thruster_signal_1
    int_code = [3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0]
    assert_equal 43_210, max_thruster_signal(int_code)
  end

  def test_max_thruster_final
    int_code = AMPLIFIER_CONTROLLER_SOFTWARE.dup
    assert_equal 118_936, max_thruster_signal(int_code)
  end

  def test_max_thruster_signal_feedback_loop_1
    int_code = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
                27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
    assert_equal 139_629_729, max_thruster_signal_feedback_loop(int_code)
  end

  def test_max_thruster_signal_feedback_loop_final
    int_code = AMPLIFIER_CONTROLLER_SOFTWARE.dup
    assert_equal 57_660_948, max_thruster_signal_feedback_loop(int_code)
  end

  private

  def max_thruster_signal(int_code)
    PHASES.map do |phase|
      phase.inject(0) do |acc, phase_setting|
        Intcode.new(int_code, phase_setting).run(acc)
      end
    end.max
  end

  def max_thruster_signal_feedback_loop(int_code)
    PHASES_FEEDBACK_LOOP_MODE.map do |phase_a, phase_b, phase_c, phase_d, phase_e|
      amp_a = nil, amp_b = nil, amp_c = nil, amp_d = nil, amp_e = nil
      amp_a = Intcode.new(int_code, phase_a, :output => ->(input_code_b) { amp_b.run(input_code_b) })

      amp_b = Intcode.new(int_code, phase_b, :output => ->(input_code_c) { amp_c.run(input_code_c) })

      amp_c = Intcode.new(int_code, phase_c, :output => ->(input_code_d) { amp_d.run(input_code_d) })

      amp_d = Intcode.new(int_code, phase_d, :output => ->(input_code_e) { amp_e.run(input_code_e) })

      amp_e = Intcode.new(int_code, phase_e, :output => ->(input_code_a) { amp_a.run(input_code_a) })
      amp_a.run(0)
      amp_e.last_output_signal
    end.max
  end
end
__END__
3,8,1001,8,10,8,105,1,0,0,21,38,63,80,105,118,199,280,361,442,99999,3,9,102,5,9,9,1001,9,3,9,1002,9,2,9,4,9,99,3,9,1001,9,4,9,102,4,9,9,101,4,9,9,102,2,9,9,101,2,9,9,4,9,99,3,9,1001,9,5,9,102,4,9,9,1001,9,4,9,4,9,99,3,9,101,3,9,9,1002,9,5,9,101,3,9,9,102,5,9,9,101,3,9,9,4,9,99,3,9,1002,9,2,9,1001,9,4,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,99
