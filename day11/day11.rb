#frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/intcode'

# https://adventofcode.com/2019/day/11
class Day11 < MiniTest::Test
  ROBOT_BRAIN = DATA.read.split(',').map(&method(:Integer)).freeze
  BLACK = 0
  WHITE = 1
  LEFT = 0
  RIGHT = 1

  def test_1
    int_code = ROBOT_BRAIN.dup
    assert_equal 1732, run_paint_robot(int_code, BLACK).count
  end

  def test_2
    int_code = ROBOT_BRAIN.dup
    painted_panels = run_paint_robot(int_code, WHITE)
    coords = painted_panels.keys
    min_x = min_y = max_x = max_y = nil

    coords.each do |y, x|
      min_y = y if min_y.nil? || y < min_y
      max_y = y if max_y.nil? || y > max_y
      min_x = x if min_x.nil? || x < min_x
      max_x = x if max_x.nil? || x > max_x
    end
    rows = max_y - min_y + 1
    cols = max_x - min_x + 1
    identifier = Array.new(rows) { ' ' * cols }
    painted_panels.each do |coords, count_and_colour|
      identifier[coords[0] - min_y][coords[1] - min_x] = '#' if count_and_colour.last == WHITE
    end
    puts identifier.join("\n")
  end

  private

  def run_paint_robot(int_code, start_colour)
    instruction = :colour
    y, x = 0, 0
    degrees = 90
    painted_panels = {}
    int_code = Intcode.new(int_code) do |colour_or_direction|
      if instruction == :colour
        current_panel = [y, x]
        painted_panels[current_panel] ||= [0, colour_or_direction]
        painted_panels[current_panel][0] += 1
        painted_panels[current_panel][1] = colour_or_direction
        # next output instruction is :direction
        instruction = :direction
      else
        if colour_or_direction == LEFT
          degrees = (degrees + 90) % 360
        elsif colour_or_direction == RIGHT
          degrees = (degrees - 90) % 360
        else
          raise "Unknown direction #{direction}"
        end
        # 1 step
        case degrees
        when 90
          y +=1
        when 180
          x -=1
        when 270
          y -=1
        when 0
          x +=1
        else
          raise "Unknown degrees #{degrees}"
        end
        current_panel = [y, x]
        # provide 0 if the robot is over a black panel or 1 if the robot is over a white panel.
        panel_colour = (painted_panels[current_panel] || [nil, BLACK])[1]
        int_code.input << panel_colour
        instruction = :colour
      end
    end
    int_code.run(start_colour)

    painted_panels
  end
end
__END__
3,8,1005,8,309,1106,0,11,0,0,0,104,1,104,0,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,1,10,4,10,1001,8,0,29,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,0,10,4,10,102,1,8,51,3,8,102,-1,8,10,1001,10,1,10,4,10,108,0,8,10,4,10,1002,8,1,72,1,1104,8,10,2,1105,15,10,2,1106,0,10,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,1,10,4,10,101,0,8,107,3,8,102,-1,8,10,1001,10,1,10,4,10,108,1,8,10,4,10,101,0,8,128,2,6,8,10,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,0,10,4,10,102,1,8,155,1006,0,96,2,108,10,10,1,101,4,10,3,8,1002,8,-1,10,101,1,10,10,4,10,1008,8,0,10,4,10,1002,8,1,188,2,1,5,10,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,0,10,4,10,102,1,8,214,2,6,18,10,1006,0,78,1,105,1,10,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,1,10,4,10,102,1,8,247,2,103,8,10,2,1002,10,10,2,106,17,10,1,1006,15,10,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,1,10,4,10,101,0,8,285,1,1101,18,10,101,1,9,9,1007,9,992,10,1005,10,15,99,109,631,104,0,104,1,21102,387507921664,1,1,21102,1,326,0,1106,0,430,21102,932826591260,1,1,21102,337,1,0,1106,0,430,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,21101,206400850983,0,1,21101,0,384,0,1105,1,430,21102,3224464603,1,1,21102,395,1,0,1106,0,430,3,10,104,0,104,0,3,10,104,0,104,0,21102,838433657700,1,1,21102,418,1,0,1106,0,430,21101,825012007272,0,1,21101,429,0,0,1106,0,430,99,109,2,21202,-1,1,1,21101,40,0,2,21101,461,0,3,21102,1,451,0,1105,1,494,109,-2,2105,1,0,0,1,0,0,1,109,2,3,10,204,-1,1001,456,457,472,4,0,1001,456,1,456,108,4,456,10,1006,10,488,1102,1,0,456,109,-2,2106,0,0,0,109,4,1202,-1,1,493,1207,-3,0,10,1006,10,511,21101,0,0,-3,21202,-3,1,1,21201,-2,0,2,21102,1,1,3,21102,1,530,0,1106,0,535,109,-4,2106,0,0,109,5,1207,-3,1,10,1006,10,558,2207,-4,-2,10,1006,10,558,22101,0,-4,-4,1106,0,626,22102,1,-4,1,21201,-3,-1,2,21202,-2,2,3,21101,0,577,0,1106,0,535,22102,1,1,-4,21101,1,0,-1,2207,-4,-2,10,1006,10,596,21102,0,1,-1,22202,-2,-1,-2,2107,0,-3,10,1006,10,618,21201,-1,0,1,21102,618,1,0,105,1,493,21202,-2,-1,-2,22201,-4,-2,-4,109,-5,2105,1,0
