# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.7, __FILE__)

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
    @name = name
    self
  end

  <<-DOC
  @param desc - move description, string
  >> sets the move description
  DOC
  def desc(desc)
    @desc = desc
    self
  end

  <<-DOC
  @param type - move type, symbol
  >> sets the move type
  DOC
  def type(type)
    @type = type
    self
  end

  <<-DOC
  @param category - move category, one of :physical, :special, :status
  >> sets the move category
  DOC
  def category(category)
    @category = category if [:physical, :special, :status].include? category
    self
  end

  <<-DOC
  @param maxpp - move pp, int
  >> sets the move max pp
  DOC
  def maxpp(max)
    @maxpp = max
    self
  end

  <<-DOC
  @param basedamage - move damage, int - 0 will make the move non-damaging
  >> sets the move base damage
  DOC
  def damage(damage)
    @basedamage = damage
    self
  end

  <<-DOC
  @param accuracy - move accuracy, int - 0 is guaranteed hit
  >> sets the move accuracy
  DOC
  def accuracy(accuracy)
    @accuracy = accuracy
    self
  end

  <<-DOC
  @param target - move target, one of :User, :SingleNonUser, :AllNonUsers, :OppositeOpposing, :AllOpposing, :UserSide, :OpposingSide, :DragonDarts
  >> sets the move targetting style
  DOC
  def target(target)
    @target = target if [:User, :SingleNonUser, :AllNonUsers, :OppositeOpposing, :AllOpposing, :UserSide, :OpposingSide, :DragonDarts].include? target
    self
  end

  <<-DOC
  @param function - move function, int - for effects defined by overriding pbEffect, best formatted as hex - 0 has no special effects
  >> sets the move function
  DOC
  def function(function)
    @function = function
    self
  end

  <<-DOC
  @param priority - move priority, int
  >> sets the move priority
  DOC
  def priority(priority)
    @priority = priority
    self
  end

  <<-DOC
  @param flags - additional move flags
  >> sets a move flag
  DOC
  def flag(flag, value)
    @flags[flag] = value
    self
  end

end