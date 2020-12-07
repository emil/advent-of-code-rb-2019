#frozen_string_literal: true
require 'set'
# rows = y, cols = x
# [y, x]
# https://www.geeksforgeeks.org/number-integral-points-two-points/
require 'minitest/autorun'
# https://adventofcode.com/2019/day/10
class Day10 < MiniTest::Test
  ASTEROID_MAP = DATA.read

  def test_1
    map = <<~EOS
      .#..#
      .....
      #####
      ....#
      ...##
    EOS

    points = all_points(map)
    station = best_station(map)
    assert_equal [3, 4], station.first
    assert_equal 8, points.map { |point| visible_from(point, points) }.map(&:length).max
  end

  def test_2
    map = <<~EOS
      ......#.#.
      #..#.#....
      ..#######.
      .#.#.###..
      .#..#.....
      ..#....#.#
      #..#....#.
      .##.#..###
      ##...#..#.
      .#....####
    EOS
    points = all_points(map)
    assert_equal [5, 8], best_station(map).first
    assert_equal 33, points.map { |point| visible_from(point, points) }.map(&:length).max
  end

  def test_3
    map = <<~EOS
     .#..##.###...#######
     ##.############..##.
     .#.######.########.#
     .###.#######.####.#.
     #####.##.#.##.###.##
     ..#####..#.#########
     ####################
     #.####....###.#.#.##
     ##.#################
     #####.##.###..####..
     ..######..##.#######
     ####.##.####...##..#
     .#####..#.######.###
     ##...#.##########...
     #.##########.#######
     .####.#.###.###.#.##
     ....##.##.###..#####
     .#.#.###########.###
     #.#.#.#####.####.###
     ###.##.####.##.#..##
    EOS
    points = all_points(map)
    assert_equal 210, points.map { |point| visible_from(point, points) }.map(&:length).max
  end

  def test_final_1
    map = ASTEROID_MAP.dup
    points = all_points(map)
    assert_equal 280, points.map { |point| visible_from(point, points) }.map(&:length).max
  end

  def test_final_2
    map = ASTEROID_MAP.dup
    home, _ = best_station(map)
    row_cols = map.split("\n")
    height, width = row_cols.length, row_cols.first.length

    all_asteroids = all_points(map)

    directions = (-height..height).flat_map { |dy|
      (-width..width).map { |dx|
        [dx, dy] if dy.gcd(dx) == 1
      }.compact
    }
    count = 0
    answer = nil
    directions.sort_by { |dy, dx| -Math.atan2(dx, dy) }.cycle do |dx, dy|
      limit = 1
      break if count == 200
      while count < 200
        x = (dx + home.last) * limit
        y = (dy + home.first) * limit
        break unless (0...height).cover?(y) && (0...width).cover?(x)
        limit += 1
        coords = [y, x]
        asteroid = all_asteroids.delete(coords)
        next if asteroid.nil?
        if (count += 1) == 200
          y, x = asteroid
          answer = x * 100 + y
        end
      end
    end
    assert_equal 706, answer
  end

  private

  def visible_from(from_point, points)
    visible = [].to_set
    points.each do |point|
      next if point == from_point
      vec = [point.first - from_point.first, point.last - from_point.last]
      gcd = vec.first.gcd(vec.last).abs
      vec = [vec.first / gcd, vec.last / gcd]
      visible << vec
    end
    visible
  end

  def best_station(map)
    points = all_points(map)
    points.map { |point| [point, visible_from(point, points)] }.max_by { |e| e.last.length }
  end

  def all_points(map)
    row_cols = map.split("\n")
    rows, cols = row_cols.length, row_cols.first.length
    points = []
    rows.times do |row|
      cols.times do |col|
        points << [col, row] if row_cols[row][col] == '#'
      end
    end
    points
  end
end
__END__
.###.#...#.#.##.#.####..
.#....#####...#.######..
#.#.###.###.#.....#.####
##.###..##..####.#.####.
###########.#######.##.#
##########.#########.##.
.#.##.########.##...###.
###.#.##.#####.#.###.###
##.#####.##..###.#.##.#.
.#.#.#####.####.#..#####
.###.#####.#..#..##.#.##
########.##.#...########
.####..##..#.###.###.#.#
....######.##.#.######.#
###.####.######.#....###
############.#.#.##.####
##...##..####.####.#..##
.###.#########.###..#.##
#.##.#.#...##...#####..#
##.#..###############.##
##.###.#####.##.######..
##.#####.#.#.##..#######
...#######.######...####
#....#.#.#.####.#.#.#.##
