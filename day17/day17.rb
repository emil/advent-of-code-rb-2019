#frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/intcode'

# https://adventofcode.com/2019/day/17
class Day17 < MiniTest::Test
  ASCII = DATA.read.split(',').map(&method(:Integer)).freeze
  SCAFFOLD = '#'.ord
  ROBOT_UP = '^'.ord
  ROBOT_DOWN = 'v'.ord
  ROBOT_LEFT = '<'.ord
  ROBOT_RIGHT = '>'.ord

  def test_final_part_one
    int_code = ASCII.dup
    view = view_of_the_scaffolds(int_code)
    assert_equal 3936, view.scaffolds.map { |k, _| intersection?(k, view) ? k.first * k.last : 0 }.sum
  end

  def test_final_part_two
    int_code = ASCII.dup
    view = view_of_the_scaffolds(int_code)

    int_code = ASCII.dup
    int_code[0] = 2
    assert_equal 785_733, visit_every_part_of_the_scaffolds(int_code, view)
  end

  private

  View = Struct.new(:rows, :cols, :scaffolds) do
    def robot_pos
      scaffolds.find { |_, v| %w[^ v < >].map(&:ord).include?(v) }
    end
  end

  def view_of_the_scaffolds(int_code)
    row, col = 0, 0
    cols = 0
    scaffolds_view = {}
    output_proc = lambda { |code|
      print code.chr
      if code == 10
        row += 1
        col = 0
      else
        scaffolds_view[[row, col]] = code
        col += 1
        cols = [cols, col].max
      end
    }
    int_code = Intcode.new(int_code, nil, output: output_proc)
    int_code.run
    puts "rows, cols: #{row}, #{cols}"
    View.new(row, cols, scaffolds_view)
  end

  def intersection?(coords, view)
    ns = neighbours(coords, view.rows, view.cols)
    view.scaffolds[coords] == SCAFFOLD && !ns.empty? && ns.all? { |yx| view.scaffolds[yx] == SCAFFOLD }
  end

  def neighbours(coords, rows, cols)
    y, x = coords
    neighbours = []
    if (1...(rows - 1)).cover?(y) && (1...(cols - 1)).cover?(x)
      neighbours << [y-1, x]
      neighbours << [y+1, x]
      neighbours << [y, x-1]
      neighbours << [y, x+1]
    end
    neighbours
  end

  def visit_every_part_of_the_scaffolds(int_code, view)
    path = []
    robot_pos, robot_direction = view.robot_pos
    left, right = left_and_right(robot_pos, robot_direction)

    loop do
      if view.scaffolds[left] == SCAFFOLD
        robot_direction = direction(robot_direction, :left)
        path << 'L'
      elsif view.scaffolds[right] == SCAFFOLD
        robot_direction = direction(robot_direction, :right)
        path << 'R'
      else
        break
      end
      steps, robot_pos = advance(robot_direction, robot_pos, view)
      break if steps.zero?

      path << steps.to_s
      left, right = left_and_right(robot_pos, robot_direction)
    end

    puts path.join(',')
    # R,4,L,12,L,8,R,4,L,8,R,10,R,10,R,6,R,4,L,12,L,8,R,4,R,4,R,10,L,12,R,4,L,12,L,8,R,4,L,8,R,10,R,10,R,6,R,4,L,12,L,8,R,4,R,4,R,10,L,12,L,8,R,10,R,10,R,6,R,4,R,10,L,12

    main_routine = "A,B,A,C,A,B,A,C,B,C\n".chars
    function_a = "R,4,L,12,L,8,R,4\n".chars
    function_b = "L,8,R,10,R,10,R,6\n".chars
    function_c = "R,4,R,10,L,12\n".chars
    video_feed = "n\n".chars
=begin
    output_proc = lambda { |code|
      print code.chr
    }
=end
    int_code = Intcode.new(int_code) #, output: output_proc)
    [
      *main_routine,
      *function_a,
      *function_b,
      *function_c,
      *video_feed
    ].each do |c|
      int_code.input << c.ord
    end

    int_code.run
  end

  def left_and_right(pos, robot_direction)
    case robot_direction
    when ROBOT_UP
      [
        [pos[0], pos[1] - 1],
        [pos[0], pos[1] + 1]
      ]
    when ROBOT_DOWN
      [
        [pos[0], pos[1] + 1],
        [pos[0], pos[1] - 1]
      ]
    when ROBOT_RIGHT
      [
        [pos[0] - 1, pos[1]],
        [pos[0] + 1, pos[1]]
      ]
    when ROBOT_LEFT
      [
        [pos[0] + 1, pos[1]],
        [pos[0] - 1, pos[1]]
      ]
    else
      raise "Unknown direction #{robot_direction}"
    end
  end

  def direction(current_direction, left_or_right)
    if left_or_right == :left
      {
        ROBOT_UP => ROBOT_LEFT,
        ROBOT_LEFT => ROBOT_DOWN,
        ROBOT_DOWN => ROBOT_RIGHT,
        ROBOT_RIGHT => ROBOT_UP
      }.fetch(current_direction)
    elsif left_or_right == :right
      {
        ROBOT_UP => ROBOT_RIGHT,
        ROBOT_RIGHT => ROBOT_DOWN,
        ROBOT_DOWN => ROBOT_LEFT,
        ROBOT_LEFT => ROBOT_UP
      }.fetch(current_direction)
    else
      raise "Unknown direction #{left_or_right}"
    end
  end

  def advance(robot_direction, pos, view)
    new_pos = pos.dup
    steps = 0
    loop do
      case robot_direction
      when ROBOT_UP
        candidate_pos = [new_pos[0] - 1, new_pos[1]]
      when ROBOT_DOWN
        candidate_pos = [new_pos[0] + 1, new_pos[1]]
      when ROBOT_LEFT
        candidate_pos = [new_pos[0], new_pos[1] - 1]
      when ROBOT_RIGHT
        candidate_pos = [new_pos[0], new_pos[1] + 1]
      else
        raise "Unknown direction #{robot_direction}"
      end
      break unless view.scaffolds[candidate_pos] == 35

      steps += 1
      new_pos = candidate_pos
    end
    [steps, new_pos]
  end
end
__END__
1,330,331,332,109,3272,1102,1,1182,16,1101,0,1427,24,102,1,0,570,1006,570,36,102,1,571,0,1001,570,-1,570,1001,24,1,24,1106,0,18,1008,571,0,571,1001,16,1,16,1008,16,1427,570,1006,570,14,21101,58,0,0,1105,1,786,1006,332,62,99,21102,1,333,1,21102,73,1,0,1106,0,579,1102,1,0,572,1101,0,0,573,3,574,101,1,573,573,1007,574,65,570,1005,570,151,107,67,574,570,1005,570,151,1001,574,-64,574,1002,574,-1,574,1001,572,1,572,1007,572,11,570,1006,570,165,101,1182,572,127,1001,574,0,0,3,574,101,1,573,573,1008,574,10,570,1005,570,189,1008,574,44,570,1006,570,158,1106,0,81,21101,340,0,1,1105,1,177,21101,0,477,1,1105,1,177,21102,1,514,1,21101,176,0,0,1106,0,579,99,21102,1,184,0,1106,0,579,4,574,104,10,99,1007,573,22,570,1006,570,165,1002,572,1,1182,21102,375,1,1,21101,211,0,0,1105,1,579,21101,1182,11,1,21101,222,0,0,1106,0,979,21101,0,388,1,21101,0,233,0,1105,1,579,21101,1182,22,1,21101,0,244,0,1105,1,979,21102,401,1,1,21101,255,0,0,1106,0,579,21101,1182,33,1,21102,266,1,0,1105,1,979,21101,414,0,1,21101,0,277,0,1106,0,579,3,575,1008,575,89,570,1008,575,121,575,1,575,570,575,3,574,1008,574,10,570,1006,570,291,104,10,21102,1,1182,1,21101,313,0,0,1105,1,622,1005,575,327,1101,0,1,575,21102,327,1,0,1106,0,786,4,438,99,0,1,1,6,77,97,105,110,58,10,33,10,69,120,112,101,99,116,101,100,32,102,117,110,99,116,105,111,110,32,110,97,109,101,32,98,117,116,32,103,111,116,58,32,0,12,70,117,110,99,116,105,111,110,32,65,58,10,12,70,117,110,99,116,105,111,110,32,66,58,10,12,70,117,110,99,116,105,111,110,32,67,58,10,23,67,111,110,116,105,110,117,111,117,115,32,118,105,100,101,111,32,102,101,101,100,63,10,0,37,10,69,120,112,101,99,116,101,100,32,82,44,32,76,44,32,111,114,32,100,105,115,116,97,110,99,101,32,98,117,116,32,103,111,116,58,32,36,10,69,120,112,101,99,116,101,100,32,99,111,109,109,97,32,111,114,32,110,101,119,108,105,110,101,32,98,117,116,32,103,111,116,58,32,43,10,68,101,102,105,110,105,116,105,111,110,115,32,109,97,121,32,98,101,32,97,116,32,109,111,115,116,32,50,48,32,99,104,97,114,97,99,116,101,114,115,33,10,94,62,118,60,0,1,0,-1,-1,0,1,0,0,0,0,0,0,1,40,26,0,109,4,2101,0,-3,586,21001,0,0,-1,22101,1,-3,-3,21102,1,0,-2,2208,-2,-1,570,1005,570,617,2201,-3,-2,609,4,0,21201,-2,1,-2,1105,1,597,109,-4,2106,0,0,109,5,1201,-4,0,629,21002,0,1,-2,22101,1,-4,-4,21102,0,1,-3,2208,-3,-2,570,1005,570,781,2201,-4,-3,652,21002,0,1,-1,1208,-1,-4,570,1005,570,709,1208,-1,-5,570,1005,570,734,1207,-1,0,570,1005,570,759,1206,-1,774,1001,578,562,684,1,0,576,576,1001,578,566,692,1,0,577,577,21102,702,1,0,1105,1,786,21201,-1,-1,-1,1106,0,676,1001,578,1,578,1008,578,4,570,1006,570,724,1001,578,-4,578,21101,0,731,0,1106,0,786,1105,1,774,1001,578,-1,578,1008,578,-1,570,1006,570,749,1001,578,4,578,21102,1,756,0,1105,1,786,1106,0,774,21202,-1,-11,1,22101,1182,1,1,21101,774,0,0,1106,0,622,21201,-3,1,-3,1105,1,640,109,-5,2105,1,0,109,7,1005,575,802,20101,0,576,-6,20102,1,577,-5,1106,0,814,21101,0,0,-1,21101,0,0,-5,21102,0,1,-6,20208,-6,576,-2,208,-5,577,570,22002,570,-2,-2,21202,-5,45,-3,22201,-6,-3,-3,22101,1427,-3,-3,1202,-3,1,843,1005,0,863,21202,-2,42,-4,22101,46,-4,-4,1206,-2,924,21101,1,0,-1,1105,1,924,1205,-2,873,21102,35,1,-4,1105,1,924,2102,1,-3,878,1008,0,1,570,1006,570,916,1001,374,1,374,2102,1,-3,895,1101,0,2,0,2102,1,-3,902,1001,438,0,438,2202,-6,-5,570,1,570,374,570,1,570,438,438,1001,578,558,921,21001,0,0,-4,1006,575,959,204,-4,22101,1,-6,-6,1208,-6,45,570,1006,570,814,104,10,22101,1,-5,-5,1208,-5,41,570,1006,570,810,104,10,1206,-1,974,99,1206,-1,974,1101,0,1,575,21101,973,0,0,1105,1,786,99,109,-7,2105,1,0,109,6,21101,0,0,-4,21102,0,1,-3,203,-2,22101,1,-3,-3,21208,-2,82,-1,1205,-1,1030,21208,-2,76,-1,1205,-1,1037,21207,-2,48,-1,1205,-1,1124,22107,57,-2,-1,1205,-1,1124,21201,-2,-48,-2,1106,0,1041,21101,-4,0,-2,1105,1,1041,21102,-5,1,-2,21201,-4,1,-4,21207,-4,11,-1,1206,-1,1138,2201,-5,-4,1059,2102,1,-2,0,203,-2,22101,1,-3,-3,21207,-2,48,-1,1205,-1,1107,22107,57,-2,-1,1205,-1,1107,21201,-2,-48,-2,2201,-5,-4,1090,20102,10,0,-1,22201,-2,-1,-2,2201,-5,-4,1103,2102,1,-2,0,1106,0,1060,21208,-2,10,-1,1205,-1,1162,21208,-2,44,-1,1206,-1,1131,1106,0,989,21101,0,439,1,1106,0,1150,21102,477,1,1,1105,1,1150,21101,0,514,1,21101,0,1149,0,1106,0,579,99,21101,1157,0,0,1106,0,579,204,-2,104,10,99,21207,-3,22,-1,1206,-1,1138,1202,-5,1,1176,1202,-4,1,0,109,-6,2106,0,0,28,11,34,1,9,1,34,1,9,1,34,1,9,1,34,1,9,1,34,1,9,1,34,1,5,5,34,1,5,1,24,13,1,1,5,1,24,1,11,1,1,1,5,1,24,1,3,5,3,1,1,9,22,1,3,1,3,1,3,1,7,1,1,1,22,1,3,1,3,1,3,13,20,1,3,1,3,1,11,1,1,1,1,1,6,7,5,11,11,1,1,10,5,1,5,1,1,1,3,1,15,1,3,1,5,2,5,1,3,5,3,1,15,1,3,1,5,2,5,1,3,1,1,1,5,1,15,1,3,1,5,2,5,13,15,9,1,2,9,1,1,1,25,1,3,1,1,2,9,1,1,1,25,1,3,1,1,2,9,1,1,1,25,1,3,1,1,2,9,1,1,1,25,5,1,2,9,1,1,1,31,12,1,1,31,1,12,1,31,1,12,9,19,5,20,1,44,1,44,1,34,5,5,1,34,1,3,1,5,1,34,1,3,1,5,1,34,1,3,1,5,1,34,1,3,1,5,1,34,1,3,1,5,1,34,11,38,1,44,1,44,1,44,13,18
