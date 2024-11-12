# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
>> battle effect event API. refer to the Events API for event types provided.
DOC
class BattleEffects

  attr_accessor(:display)

  def self.add(symbol)
    CUSTOM_BATTLE_EFFECTS[symbol] = BattleEffects.new(symbol) unless CUSTOM_BATTLE_EFFECTS[symbol]
    CUSTOM_BATTLE_EFFECTS[symbol]
  end

  <<-DOC
  @param proc
  >> proc that provides a display in the battle inspector. accepts a user (PokeBattle_Pokemon) argument; returns a string.
  DOC
  def set_display(proc)
    @event_hash[:display] = [] unless @event_hash[:display].nil?
    @event_hash[:display].push(proc)
  end

  <<-DOC
  @param type - unused
  >> unimplemented event
  DOC
  def primary_type(type)
    print "Warning for BattleEffects #{@symbol}: BattleEffects does not support direct primary type setting with primary_type method"
    self
  end

  <<-DOC
  @param type - unused
  >> unimplemented event
  DOC
  def secondary_type(type)
    print "Warning for BattleEffects #{@symbol}: BattleEffects does not support direct secondary type setting with secondary_type method"
    self
  end

end