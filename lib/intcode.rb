# frozen_string_literal: true

# Intcode https://adventofcode.com/2019/day/2
class Intcode
  attr_reader :last_output_signal
  attr_accessor :input

  SparseIntCode = Struct.new(:int_code) do
    attr_accessor :_int_code_h
    def initialize(int_code)
      @_int_code_h = Hash[int_code.map.with_index { |code, i| [i, code] }]
      @_int_code_h.default = 0
    end

    def [](index)
      @_int_code_h[index]
    end

    def []=(index, val)
      @_int_code_h[index] = val
    end
  end

  def initialize(int_code, phase_setting = nil, options = {})
    @halted = false
    @output_proc = options[:output]
    @input_proc = options[:input]
    # phase setting is the first input code if present
    @input = []
    if int_code.is_a?(SparseIntCode)
      @int_code = int_code
    else
      @int_code = SparseIntCode.new(int_code)
    end

    @input = [phase_setting] unless phase_setting.nil?
    @output = []
    @index = 0
    @relative_base_offset = 0
  end

  OPCODE_METHODS = {
    1 => :add_or_multiply,
    2 => :add_or_multiply,
    3 => :read_input,
    4 => :output,
    5 => :jump_if_true,
    6 => :jump_if_false,
    7 => :less_than_or_equal,
    8 => :less_than_or_equal,
    9 => :relative_base_offset,
    99 => :halt!
  }.freeze

  def run(input_code = nil)
    @input << input_code unless input_code.nil?
    loop do
      opcode, *params = instruction_to_params
      send(OPCODE_METHODS.fetch(opcode), opcode, *params)
      return @last_output_signal if @halted
    end
    raise 'Intcode error'
  end

  # public, can be invoked explicitly (Day 15)
  def halt!(*)
    @halted = true
  end

  def state
    Marshal.load(Marshal.dump(@int_code))
  end

  def state=(new_int_code)
    @int_code = new_int_code
  end

  private

  def add_or_multiply(opcode, index1, index2, index_to)
    ops = { 1 => :+, 2 => :* }
    left  = @int_code[index1]
    right = @int_code[index2]
    @int_code[index_to] = left.send(ops[opcode], right)
    @index += 4
  end

  def read_input(_opcode, at_index)
    val = if !@input.empty?
            @input.shift
          elsif !@input_proc.nil?
            @input_proc.call
          else
            raise 'Input codes exhausted'
          end

    @int_code[at_index] = val
    @index += 2
  end

  def output(_opcode, at_index)
    @index += 2
    @last_output_signal = @int_code[at_index]
    if @output_proc.nil?
      @output << @int_code[at_index]
    else
      @output_proc.call(@int_code[at_index])
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

  def relative_base_offset(_opcode, new_relative_base_offset)
    @relative_base_offset += @int_code[new_relative_base_offset]
    @index += 2
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
    9 => 1,
    99 => 0
  }.freeze

  # returns [opcode, param1_index, param2_index ...]
  def instruction_to_params
    param_modes, opcode = current_instruction.divmod(100)
    digit_count = OPCODE_PARAMS.fetch(opcode)

    modes = []
    while digit_count.positive?
      param_modes, mode = param_modes.divmod(10)
      mode = param_mode(opcode, modes.length + 1, mode)
      modes << mode
      digit_count -= 1
    end
    [opcode].concat(mode_to_index(modes))
  end

  # https://adventofcode.com/2019/day/5
  # "Parameters that an instruction writes to will never be in immediate mode."
  def param_mode(opcode, param_index, mode)
    return 0 if opcode == 3 && mode == 1
    return 0 if param_index == 3 && mode == 1

    mode
  end

  def mode_to_index(param_modes)
    param_modes.each_with_object([]) do |mode, acc|
      param_index = @index + acc.length + 1
      # direct value, index or index + relative
      acc << case mode
             when 0
               @int_code[param_index]
             when 1
               param_index
             when 2
               @int_code[param_index] + @relative_base_offset
             else
               raise "Unknown param mode  #{mode}"
             end
    end
  end

  def current_instruction
    @int_code[@index]
  end
end
