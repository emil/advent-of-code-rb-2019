#frozen_string_literal: true

require 'minitest/autorun'

# https://adventofcode.com/2019/day/16
class Day16 < MiniTest::Test
  SIGNAL = DATA.read.chomp.split('').map(&method(:Integer)).freeze
  BASE_PATTERN = [0, 1, 0, -1].freeze
  SIGNAL_FIRST_SEVEN = Integer(SIGNAL.take(7).join, 10)
  def test_repeating_pattern
    assert_equal [1, 0, -1, 0, 1, 0, -1, 0], repeating_pattern(8, 0).to_a
    assert_equal [0, 1, 1, 0, 0, -1, -1, 0], repeating_pattern(8, 1).to_a
    assert_equal [0, 0, 1, 1, 1, 0, 0, 0], repeating_pattern(8, 2).to_a
  end

  def test_repeating_pattern_at
    assert_equal([1, 0, -1, 0, 1, 0, -1, 0], (0...8).map {|i| repeating_pattern_at(8, 0, i) })
    assert_equal([0, 1, 1, 0, 0, -1, -1, 0], (0...8).map {|i| repeating_pattern_at(8, 1, i) })
    assert_equal([0, 0, 1, 1, 1, 0, 0, 0], (0...8).map {|i| repeating_pattern_at(8, 2, i) })
  end

  def test_fft_1
    signal = '12345678'.split('').map(&method(:Integer))
    assert_equal '48226158', fft(signal).map(&:to_s).join
    assert_equal '34040438', fft(signal, 2).map(&:to_s).join
    assert_equal '03415518', fft(signal, 3).map(&:to_s).join
  end

  def test_fft_2
    signal = '80871224585914546619083218645595'.split('').map(&method(:Integer))
    assert_equal '24176176', fft(signal, 100).map(&:to_s).take(8).join
  end

  def test_fft_final_1
    signal = SIGNAL
    assert_equal '44098263', fft(signal, 100).map(&:to_s).take(8).join
  end

  def test_fft_final_2
    signal = SIGNAL * 10_000
    signal = signal[SIGNAL_FIRST_SEVEN..-1]
    assert_equal '12482168', fft_last_half(signal).take(8).join
  end

  private

  def fft(signal, phases = 1, repeating_pattern_cache = Hash.new { |h, key| h[key] = repeating_pattern(*key).to_a })
    input_signal = signal
    phases.times do
      input_signal = (0...signal.length).reduce([]) do |acc, iteration|
        sum = 0
        repeating_pattern_cache[[signal.length, iteration]].each_with_index { |e, i|
          sum += (e * input_signal[i])
        }
        acc << sum.abs % 10
      end
    end
    input_signal
  end
  # https://www.reddit.com/r/adventofcode/comments/ebai4g/2019_day_16_solutions/
  def fft_last_half(signal, phases = 100)
    input_signal = signal
    phases.times do
      input_signal.to_enum.with_index.reverse_each { |_, i| input_signal[i] = ((input_signal[i+1] || 0) + input_signal[i]) % 10 }
    end
    input_signal
  end

  def repeating_pattern(length, iteration)
    repeating = iteration + 1
    count = 0
    Enumerator.new do |yielder|
      length.times do |i|
        repeating.times do |j|
          yielder << BASE_PATTERN[((i % BASE_PATTERN.length) + (j+1) / repeating ) % BASE_PATTERN.length]
          count += 1
          break if count >= length
        end
        break if count >= length
      end
    end
  end

  def repeating_pattern_at(length, iteration, index)
    raise ArgumentError unless index >= 0 && index < length

    repeating = iteration + 1
    d, r = index.divmod(length + repeating)
    i, j = r.divmod(length)
    i += d
    BASE_PATTERN[((i % BASE_PATTERN.length) + (j+1) / repeating ) % BASE_PATTERN.length]
  end

end
__END__
59702216318401831752516109671812909117759516365269440231257788008453756734827826476239905226493589006960132456488870290862893703535753691507244120156137802864317330938106688973624124594371608170692569855778498105517439068022388323566624069202753437742801981883473729701426171077277920013824894757938493999640593305172570727136129712787668811072014245905885251704882055908305407719142264325661477825898619802777868961439647723408833957843810111456367464611239017733042717293598871566304020426484700071315257217011872240492395451028872856605576492864646118292500813545747868096046577484535223887886476125746077660705155595199557168004672030769602168262
