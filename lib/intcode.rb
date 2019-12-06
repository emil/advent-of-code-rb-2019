#frozen_string_literal: true
# Intcode https://adventofcode.com/2019/day/2
class Intcode

  def initialize(int_code)
    @init_int_code = int_code
    @halted = false
  end

  OPCODE_METHODS = {
    1 => :opcode_1_2,
    2 => :opcode_1_2,
    3 => :opcode_3,
    4 => :opcode_4,
    5 => :opcode_5,
    6 => :opcode_6,
    7 => :opcode_7_8,
    8 => :opcode_7_8,
    99 => :opcode_99
  }.freeze

  def run(input_code = 1)
    @int_code = @init_int_code.dup
    @output = []
    @index = 0
    @input_code = input_code
    loop do
      opcode, *params = instruction_to_params
      send(OPCODE_METHODS.fetch(opcode), opcode, *params)
      return @output.last if @halted
    end
    raise 'Intcode error'
  end

  private

  def opcode_99(*)
    @halted = true
  end

  def opcode_1_2(opcode, index1, index2, index3)
    ops = { 1 => :+, 2 => :* }
    left  = @int_code[index1]
    right = @int_code[index2]
    @int_code[index3] = left.send(ops[opcode], right)
    @index += 4
  end

  def opcode_3(_opcode, at_index)
    @int_code[at_index] = @input_code
    @index += 2
  end

  def opcode_4(_opcode, at_index)
    @output.push(@int_code[at_index])
    @index += 2
  end

  def opcode_5(_opcode, at_index, index_from)
    if !@int_code[at_index].zero?
      @index = @int_code[index_from]
    else
      @index += 3
    end
  end

  def opcode_6(_opcode, at_index, index_from)
    if @int_code[at_index].zero?
      @index = @int_code[index_from]
    else
      @index += 3
    end
  end

  def opcode_7_8(opcode, left, right, index_to)
    ops = { 7 => :<, 8 => :== }
    @int_code[index_to] = @int_code[left].send(ops[opcode], @int_code[right]) ? 1 : 0
    @index += 4
  end

  OPCODE_PARAMS = {
    1 => 3,
    2 => 3,
    3 => 1,
    4 => 1,
    5 => 2,
    6 => 2,
    7 => 3,
    8 => 3,
    99 => 0
  }.freeze

  # returns [opcode, param1_index, param2_index ...]
  def instruction_to_params
    param_modes, opcode = current_instruction.divmod(100)
    digit_count = OPCODE_PARAMS.fetch(opcode)

    modes = []
    while digit_count.positive?
      param_modes, mode = param_modes.divmod(10)
      modes << mode
      digit_count -= 1
    end
    [opcode].concat(mode_to_index(modes))
  end

  def mode_to_index(param_modes)
    param_modes.each_with_object([]) do |mode, acc|
      param_index = @index + acc.length + 1
      # direct value or index
      acc << (mode.zero? ? @int_code[param_index] : param_index)
    end
  end

  def current_instruction
    @int_code[@index]
  end
end
