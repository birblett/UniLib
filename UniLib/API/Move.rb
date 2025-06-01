# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
>> builder class for explicitly creating new moves
DOC
module MoveBuilder

  <<-DOC
  @param symbol - id to register under
  @param name - move name, string
  @param desc - move description, string
  @param type - move type, symbol
  @param category - move category, one of :physical, :special, :status
  @param maxpp - move pp, int
  @param basedamage - move damage, int - 0 will make the move non-damaging
  @param accuracy - move accuracy, int - 0 is guaranteed hit
  @param function - move function, int - for effects defined by overriding pbEffect, best formatted as hex - 0 has no special effects
  @param target - move target, one of :User, :SingleNonUser, :AllNonUsers, :OppositeOpposing, :AllOpposing, :UserSide, :OpposingSide, :DragonDarts
  @param priority - move priority, int
  @param flags - additional move flags
  >> creates a new move builder unless it already exists for the specified move; otherwise overwrites existing traits if specified
  DOC
  def self.add(symbol, name, desc, type, category, maxpp, basedamage = 0, accuracy = 0, function = 0, target = :SingleNonUser, priority = 0, flags = {})
    return MoveModifier.add(symbol) if UniLib.cached(UniLib::MOVE)
    m = MoveModifier.add(symbol).name(name).desc(desc).type(type).category(category).maxpp(maxpp).damage(basedamage).accuracy(accuracy)
          .function(function).target(target).priority(priority)
    flags.each { |f, v| m.flag(f, v) }
    m
  end

end

<<-DOC
>> modifier class for modifying moves
DOC
class MoveModifier

  <<-DOC
  @param symbol - id to register under
  >> registers a move modifier
  DOC
  def self.add(symbol)
    CUSTOM_MOVES[symbol] = MoveModifier.new(symbol) if CUSTOM_MOVES[symbol].nil?
    CUSTOM_MOVES[symbol]
  end

  <<-DOC
  @param name - move name, string
  >> sets the move name
  DOC
  def name(name)
    return self if UniLib.cached(UniLib::MOVE)
    @name = name
    self
  end

  <<-DOC
  @param desc - move description, string
  >> sets the move description
  DOC
  def desc(desc)
    return self if UniLib.cached(UniLib::MOVE)
    @desc = desc
    self
  end

  <<-DOC
  @param type - move type, symbol
  >> sets the move type
  DOC
  def type(type)
    return self if UniLib.cached(UniLib::MOVE)
    @type = type
    self
  end

  <<-DOC
  @param category - move category, one of :physical, :special, :status
  >> sets the move category
  DOC
  def category(category)
    return self if UniLib.cached(UniLib::MOVE)
    @category = category if [:physical, :special, :status].include? category
    self
  end

  <<-DOC
  @param maxpp - move pp, int
  >> sets the move max pp
  DOC
  def maxpp(max)
    return self if UniLib.cached(UniLib::MOVE)
    @maxpp = max
    self
  end

  <<-DOC
  @param basedamage - move damage, int - 0 will make the move non-damaging
  >> sets the move base damage
  DOC
  def damage(damage)
    return self if UniLib.cached(UniLib::MOVE)
    @basedamage = damage
    self
  end

  <<-DOC
  @param accuracy - move accuracy, int - 0 is guaranteed hit
  >> sets the move accuracy
  DOC
  def accuracy(accuracy)
    return self if UniLib.cached(UniLib::MOVE)
    @accuracy = accuracy
    self
  end

  <<-DOC
  @param target - move target, one of :User, :SingleNonUser, :AllNonUsers, :OppositeOpposing, :AllOpposing, :UserSide, :OpposingSide, :DragonDarts
  >> sets the move targetting style
  DOC
  def target(target)
    return self if UniLib.cached(UniLib::MOVE)
    @target = target if [:User, :SingleNonUser, :AllNonUsers, :OppositeOpposing, :AllOpposing, :UserSide, :OpposingSide, :DragonDarts].include? target
    self
  end

  <<-DOC
  @param function - move function, int - for effects defined by overriding pbEffect, best formatted as hex - 0 has no special effects
  >> sets the move function
  DOC
  def function(function)
    return self if UniLib.cached(UniLib::MOVE)
    @function = function
    self
  end

  <<-DOC
  @param priority - move priority, int
  >> sets the move priority
  DOC
  def priority(priority)
    return self if UniLib.cached(UniLib::MOVE)
    @priority = priority
    self
  end

  <<-DOC
  @param flags - additional move flags
  >> sets a move flag
  DOC
  def flag(flag, value)
    return self if UniLib.cached(UniLib::MOVE)
    @flags[flag] = value
    self
  end

end