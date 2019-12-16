#frozen_string_literal: true

require 'minitest/autorun'
# https://adventofcode.com/2019/day/12

class Day12 < MiniTest::Test
  # four largest moons: Io, Europa, Ganymede, and Callisto.
  MOONS = %i[io europa ganymede callisto].freeze
  INITIAL_POSITION = DATA.readlines.map do |line|
    /x=(?<x>-?\d+)/ =~line
    /y=(?<y>-?\d+)/ =~line
    /z=(?<z>-?\d+)/ =~line
    [x.to_i, y.to_i, z.to_i].freeze
  end.freeze

  MOON_COMBINATIONS = MOONS.product(MOONS).select { |first, last| first != last }.group_by {|e| e[0]}.freeze

  def setup
    @positions = {}
    @positions[:io] = INITIAL_POSITION[0].dup
    @positions[:europa] = INITIAL_POSITION[1].dup
    @positions[:ganymede] = INITIAL_POSITION[2].dup
    @positions[:callisto] = INITIAL_POSITION[3].dup

    @velocity = {
      :io => [0, 0, 0],
      :europa => [0, 0, 0],
      :ganymede => [0, 0, 0],
      :callisto => [0, 0, 0]
    }
  end

  def test_total_energy
    1000.times do
      MOON_COMBINATIONS.each do |moon, moon_pairs|
        collect_gravity(moon_pairs, @positions, @velocity[moon])
      end
      # update positions from the velocity
      MOONS.each do |moon|
        @velocity[moon].each_with_index { |e, i| @positions[moon][i] += e }
      end
    end

    assert_equal 9139, MOONS.map { |moon|
      @positions[moon].map(&:abs).sum *
        @velocity[moon].map(&:abs).sum
    }.sum
  end

  def test_return_to_initial_state
    count = 0
    periods = {}
    track = {
      0 => {@positions.values.map{ |e| e[0] } => true},
      1 => {@positions.values.map{ |e| e[1] } => true},
      2 => {@positions.values.map{ |e| e[2] } => true}
    }
    loop do
      MOON_COMBINATIONS.each do |moon, moon_pairs|
        collect_gravity(moon_pairs, @positions, @velocity[moon])
      end
      # update positions from the velocity
      MOONS.each do |moon|
        @velocity[moon].each_with_index { |e, i| @positions[moon][i] += e }
      end
      count +=1
      [0, 1, 2].each do |axis|
        next unless periods[axis].nil?

        axis_values = @positions.values.map{ |e| e[axis] }
        if track[axis][axis_values] && @velocity.values.map {|e| e[axis]}.all?(&:zero?)
          periods[axis] = count
        end
      end

      break if periods.length == 3
    end
    assert_equal 420_788_524_631_496, periods.values.reduce(1, :lcm)
  end

  private

  # collect gravity into the velocity (update velocity).
  def collect_gravity(moon_pairs, positions, velocity)
    moon_pairs.map { |to, from|
      positions[to].map.with_index { |pos, index| positions[from][index] <=> pos }
    }.each_with_object(velocity) {|e, acc| 3.times { |i| acc[i] += e[i] }}
  end
end
__END__
<x=14, y=2, z=8>
<x=7, y=4, z=10>
<x=1, y=17, z=16>
<x=-4, y=-1, z=1>
