#frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/intcode'

# https://adventofcode.com/2019/day/14
class Day14 < MiniTest::Test
  TRILLION = 1e12.to_i
  REACTIONS = DATA.read.freeze
  def test_1
    reactions = parse_reactions(<<~REACT).freeze
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    REACT
    assert_equal 31, calculate_reactions(['FUEL', 1], reactions)
  end

  def test_2
    reactions =  parse_reactions(<<~REACT).freeze
      9 ORE => 2 A
      8 ORE => 3 B
      7 ORE => 5 C
      3 A, 4 B => 1 AB
      5 B, 7 C => 1 BC
      4 C, 1 A => 1 CA
      2 AB, 3 BC, 4 CA => 1 FUEL
    REACT
    # puts reactions.inspect
    assert_equal 165, calculate_reactions(['FUEL', 1], reactions)
  end

  def test_3
    reactions =  parse_reactions(<<~REACT).freeze
      157 ORE => 5 NZVS
      165 ORE => 6 DCFZ
      44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
      12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
      179 ORE => 7 PSHF
      177 ORE => 5 HKGWZ
      7 DCFZ, 7 PSHF => 2 XJWVT
      165 ORE => 2 GPVTF
      3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
    REACT
    assert_equal 13312, calculate_reactions(['FUEL', 1], reactions)
  end

  def test_4
    reactions =  parse_reactions(<<~REACT).freeze
      2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
      17 NVRVD, 3 JNWZP => 8 VPVL
      53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
      22 VJHF, 37 MNCFX => 5 FWMGM
      139 ORE => 4 NVRVD
      144 ORE => 7 JNWZP
      5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
      5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
      145 ORE => 6 MNCFX
      1 NVRVD => 8 CXFTF
      1 VJHF, 6 MNCFX => 4 RFSQX
      176 ORE => 6 VJHF
    REACT
    assert_equal 180697, calculate_reactions(['FUEL', 1], reactions)
  end

  def test_final
    reactions = parse_reactions(REACTIONS).freeze
    assert_equal 502491, calculate_reactions(['FUEL', 1], reactions)
  end

  def test_3b
    reactions =  parse_reactions(<<~REACT).freeze
      157 ORE => 5 NZVS
      165 ORE => 6 DCFZ
      44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
      12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
      179 ORE => 7 PSHF
      177 ORE => 5 HKGWZ
      7 DCFZ, 7 PSHF => 2 XJWVT
      165 ORE => 2 GPVTF
      3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
    REACT

    assert_equal 82892753, max_fuel(reactions)
  end

  def test_final_3b
    reactions = parse_reactions(REACTIONS).freeze
    assert_equal 2944565, max_fuel(reactions)
  end

  private

  def max_fuel(reactions)
    (1..TRILLION).bsearch {|x| calculate_reactions(['FUEL', x], reactions) > TRILLION } - 1
  end

  def calculate_reactions(fuel, reaction_a)
    queue = Queue.new
    leftover = Hash.new(0)
    queue.push(fuel)
    required_ore = 0

    while !queue.empty?
      reaction = queue.pop
      required_chemical, required_quantity = reaction
      production_reaction, input_chemicals = reaction_a.find { |e| e[0][0] == required_chemical }
      #
      # for example:
      # when +required_chemical+ is "XJWVT" from:
      # [["FUEL", 1], [["XJWVT", 44], ["KHKGT", 5], ["QDVJ", 1], ["NZVS", 29], ["GPVTF", 9], ["HKGWZ", 48]]]
      #                 ^^^^^^
      # and the +production_reaction+,  +input_chemicals+ looks like:
      #
      # [["XJWVT", 2], [["DCFZ", 7], ["PSHF", 7]]]
      #  ^^^^^^^^
      # the +required_chemical+ is "XJWT" and the +required_quantity+ is 44
      # the +production_reaction+ is ["XJWVT", 2], the +production_multiply+ is 2
      # the +input_chemicals+ is [["DCFZ", 7], ["PSHF", 7]]]
      #
      leftover_quantity = leftover[required_chemical]

      if required_chemical == 'ORE'
        required_ore += required_quantity
      elsif leftover_quantity >= required_quantity
        leftover[required_chemical] -= required_quantity
      else
        production_multiply = production_reaction[1]
        amount_needed = required_quantity - leftover_quantity
        times = Rational(amount_needed, production_multiply).ceil
        input_chemicals.each { |e| queue.push([e[0], e[1] * times]) }
        leftover[required_chemical] = (times * production_multiply) - amount_needed
      end
      # puts "required chem: #{required_chemical}, #{required_quantity}, #{production_multiply}, #{leftover[required_chemical]}"
    end
    required_ore
  end

  # parse the input into format reaction, input elements
  # [["NZVS", 5], [["ORE", 157]]]
  # [["DCFZ", 6], [["ORE", 165]]]
  # [["FUEL", 1], [["XJWVT", 44], ["KHKGT", 5], ["QDVJ", 1], ["NZVS", 29], ["GPVTF", 9], ["HKGWZ", 48]]]
  # [["QDVJ", 9], [["HKGWZ", 12], ["GPVTF", 1], ["PSHF", 8]]]
  # [["PSHF", 7], [["ORE", 179]]]
  # [["HKGWZ", 5], [["ORE", 177]]]
  # [["XJWVT", 2], [["DCFZ", 7], ["PSHF", 7]]]
  # [["GPVTF", 2], [["ORE", 165]]]
  # [["KHKGT", 8], [["DCFZ", 3], ["NZVS", 7], ["HKGWZ", 5], ["PSHF", 10]]]
  #
  def parse_reactions(reactions)
    reactions.split("\n").map do |line|
      left, right = line.split(' => ')
      /\s*(?<quantity>\d+)\s*(?<reaction>[[:upper:]]+)/ =~ right
      r = [reaction, Integer(quantity)]
      input = left.split(',').map do |e|
        /\s*(?<quantity>\d+)\s*(?<reaction>[[:upper:]]+)/ =~ e
        [reaction, Integer(quantity)]
      end
      [r, input]
    end
  end
end
__END__
8 SPJN, 2 LJRB, 1 QMDTJ => 1 TFPRF
111 ORE => 5 GCFP
5 NGCKP => 6 QXQZ
21 RGRLZ => 7 DKVN
2 DCKF => 9 FCMVJ
7 SGHSV, 4 LZPCS => 9 DQRCZ
4 QNRH => 8 WGKHJ
135 ORE => 6 BPLFB
4 SPJN, 1 DCKF, 9 KJVZ, 1 DKVN, 4 ZKVPL, 11 TFPRF, 1 CWPVT => 8 BVMK
8 TGPV, 4 MQPLD => 2 SPFZ
11 QMDTJ, 15 LVPK, 5 LZPCS => 3 KJVZ
2 RNXF, 3 MKMQ => 6 LJRB
11 RKCXJ, 4 BJHW, 2 DKDST => 3 QNRH
3 NZHP, 1 QMDTJ => 9 BCMKN
10 DQRCZ, 1 GBJF => 7 RGRLZ
2 WLKC, 1 GBJF, 7 SPJN => 5 GBWQT
4 TGPV, 1 LTSB => 2 LZPCS
6 LJRB => 4 LQHB
3 LZPCS, 3 MDTZL, 12 DLHS => 2 CBTK
1 TGPV, 1 CQPR => 9 XQZFV
26 FSQBL => 8 HQPG
9 LQHB => 1 GBJF
7 NGCKP => 5 WLKC
9 DKDST, 1 XQZFV => 9 TPZBM
144 ORE => 9 RNXF
1 LJRB => 6 CQPR
9 MKMQ, 12 RNXF => 9 JWPLZ
5 LZPCS, 28 QMDTJ, 1 QNRH => 5 LVPK
5 TGPV, 1 HQPG => 6 FCBLK
8 LVPK, 9 DQRCZ, 1 MDTZL => 6 DCKF
1 RKCXJ, 2 LZPCS, 13 LJNJ => 1 QWFG
4 DKDST, 1 XQZFV, 10 NSXFK => 4 JRDXQ
7 QWFG, 1 BVMK, 4 BJHW, 21 QNSWJ, 3 FBTW, 3 FCBLK, 59 SPFZ, 4 GBWQT => 1 FUEL
28 LZPCS, 17 NGCKP, 1 MQPLD => 5 MDTZL
1 FCBLK, 5 WGKHJ => 7 ZKVPL
7 LJNJ => 9 BLDJP
11 FSQBL, 2 BCMKN, 1 CBTK => 9 CWPVT
1 BJHW => 1 MQPLD
11 SGHSV, 3 LJNJ => 1 NGCKP
2 FSQBL, 7 FCBLK, 1 CQPR => 4 RKCXJ
1 JRDXQ => 4 SGHSV
107 ORE => 6 MKMQ
1 DQRCZ, 3 QMDTJ, 9 XQZFV => 4 FZVH
6 NSXFK, 1 MKMQ => 6 DLHS
4 CQPR, 1 RNXF, 1 HQPG => 5 DKDST
9 RNXF => 8 LTZTR
1 LTSB, 8 BLDJP => 4 SPJN
1 FCBLK => 4 LJNJ
1 NGCKP => 3 NZHP
11 LZPCS, 22 DQRCZ, 1 QWFG, 1 QXQZ, 6 DKVN, 16 FZVH, 3 MQPLD, 23 HQPG => 3 QNSWJ
26 DLHS, 1 NSXFK => 9 BJHW
3 FCBLK, 10 HQPG => 3 LTSB
10 LTZTR, 13 JWPLZ, 16 FSQBL => 4 TGPV
11 LTSB, 1 XQZFV, 3 DQRCZ => 4 CZCJ
1 HQPG, 12 XQZFV, 17 TPZBM => 6 QMDTJ
2 LTZTR => 7 FSQBL
1 GCFP, 5 BPLFB => 1 NSXFK
3 KJVZ, 1 QXQZ, 6 DKDST, 1 FCMVJ, 2 CZCJ, 1 QNRH, 7 WLKC => 4 FBTW
