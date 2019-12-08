#frozen_string_literal: true
# Intcode https://adventofcode.com/2019/day/2
class Intcode
  attr_reader :last_output_signal
  def initialize(int_code, phase_setting = nil, &blk)
    @int_code = int_code.dup
    @halted = false
    @feedback_loop = blk
    # phase setting is the first input code if present
    @input_codes = []
    @input_codes = [phase_setting] unless phase_setting.nil?
    @output = []
    @index = 0
  end

  OPCODE_METHODS = {
    1 => :add_or_multiply,
    2 => :add_or_multiply,
    3 => :input,
    4 => :output,
    5 => :jump_if_true,
    6 => :jump_if_false,
    7 => :less_than_or_equal,
    8 => :less_than_or_equal,
    99 => :halt
  }.freeze

  def run(input_code)
    @input_codes << input_code
    loop do
      opcode, *params = instruction_to_params
      send(OPCODE_METHODS.fetch(opcode), opcode, *params)
      if @halted
        return @last_output_signal
      end
    end
    raise 'Intcode error'
  end

  private

  def halt(*)
    @halted = true
  end

  def add_or_multiply(opcode, index1, index2, index3)
    ops = { 1 => :+, 2 => :* }
    left  = @int_code[index1]
    right = @int_code[index2]
    @int_code[index3] = left.send(ops[opcode], right)
    @index += 4
  end

  def input(_opcode, at_index)
    raise 'Input codes exhausted' if @input_codes.empty?

    @int_code[at_index] = @input_codes.shift
    @index += 2
  end

  def output(_opcode, at_index)
    @index += 2
    @last_output_signal = @int_code[at_index]
    if @feedback_loop.nil?
      @output << @int_code[at_index]
    else
      @feedback_loop.call(@int_code[at_index])
    end
  end

  def jump_if_true(_opcode, at_index, index_from)
    if !@int_code[at_index].zero?
      @index = @int_code[index_from]
    else
      @index += 3
    end
  end

  def jump_if_false(_opcode, at_index, index_from)
    if @int_code[at_index].zero?
      @index = @int_code[index_from]
    else
      @index += 3
    end
  end

  def less_than_or_equal(opcode, left, right, index_to)
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
