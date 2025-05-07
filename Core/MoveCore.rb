# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  CUSTOM_MOVES = {}
  MOVE_DATA = load_data("Data/moves.dat") unless defined? MOVE_DATA
  MOVE_MAX_ID = MOVE_DATA.max_by { |_, v| v.flags[:ID].nil? ? 0 : v.flags[:ID] }[1].flags[:ID] unless defined? MOVE_MAX_ID
  $move_current_max = MOVE_MAX_ID + 1

end

class MoveModifier

  include UniLib

  attr_accessor(:move)
  attr_accessor(:name)
  attr_accessor(:desc)
  attr_accessor(:function)
  attr_accessor(:type)
  attr_accessor(:category)
  attr_accessor(:basedamage)
  attr_accessor(:accuracy)
  attr_accessor(:maxpp)
  attr_accessor(:target)
  attr_accessor(:priority)
  attr_accessor(:flags)

  def initialize(symbol)
    @symbol = symbol
    @flags = {}
    CUSTOM_MOVES[symbol] = self
  end

  def build
    data = {}
    m = MOVE_DATA[@symbol]
    unless m.nil?
      data[:name] = m.name
      data[:desc] = m.desc
      data[:function] = m.function
      data[:type] = m.type
      data[:category] = m.category
      data[:basedamage] = m.basedamage
      data[:accuracy] = m.accuracy
      data[:maxpp] = m.maxpp
      data[:target] = m.target
      data[:priority] = m.priority
      m.instance_variable_get(:@flags).each { |k, v| data[k] = v }
    end
    data[:name] = @name if @name
    data[:desc] = @desc if @desc
    data[:function] = @function if @function
    data[:type] = @type if @type
    data[:category] = @category if @category
    data[:basedamage] = @basedamage if @basedamage
    data[:accuracy] = @accuracy if @accuracy
    data[:maxpp] = @maxpp if @maxpp
    data[:target] = @target if @target
    data[:priority] = @priority if @priority
    @flags.each { |k, v| data[k] = v }
    $cache.moves[@symbol] = MoveData.new(@symbol, data)
    UniLib.dev_log(UniLib.obj_print($cache.moves[@symbol]))
  end

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

unless UniLib.lib_loaded(__FILE__)

  def add_moves(save)
    UniLib::CUSTOM_MOVES.each { |_, move_builder| move_builder.build }
  end

end

UniLib.add_play_event(:add_moves, 1001)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.replace_in_method(:PokeBattle_Move, :pbEffectMessages, "if !pbIsMultiHit && !attacker.effects[:ParentalBond]",
  "if !pbIsMultiHit and !attacker.effects[:ParentalBond] and !attacker.effects[:Multihit]")