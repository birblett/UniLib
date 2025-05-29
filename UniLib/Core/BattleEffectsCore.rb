# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Events"

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #


module UniLib

  CUSTOM_BATTLE_EFFECTS = {}
  BOSS_NEGATIVE_EFFECTS = {}

end

class BattleEffects < EventProvider

  include UniLib

  def initialize(symbol)
    @symbol = symbol
    super()
  end

  def self.has_event?(effect, id)
    !CUSTOM_BATTLE_EFFECTS[effect].nil? and CUSTOM_BATTLE_EFFECTS[effect].event_hash[id]
  end

  def self.get_event(effect, id)
    CUSTOM_BATTLE_EFFECTS[effect].event_hash[id]
  end

end unless UniLib.lib_loaded(__FILE__)

class PokeBattle_Battler

  def effect_event_value(event)
    self.effects.each do |effect, value|
      next unless value and UniLib::CUSTOM_BATTLE_EFFECTS[effect] and BattleEffects.has_event?(effect, event)
      out = BattleEffects.get_event(effect, event)
      yield(out) unless out.nil?
    end
  end

  def apply_effect_event(event, *args)
    self.effects.each do |effect, value|
      next unless value and UniLib::CUSTOM_BATTLE_EFFECTS[effect] and BattleEffects.has_event?(effect, event)
      BattleEffects.get_event(effect, event).each { |e, out = e.(*args)| yield(out) unless out.nil? }
    end
  end

  self.add_listeners(2, :effect_event_value, :apply_effect_event)

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

target = Reborn ? "report.push(_INTL(\"Infatuated with {1}\", @battle.battlers[pkmn.effects[:Attract]].name)) if pkmn.effects[:Attract] >= 0" :
           "report.push(_INTL(\"Infatuated with {1}\",@battle.battlers[pkmn.effects[:Attract]].name)) if pkmn.effects[:Attract]>=0"
UniLib.insert_in_function(:pbShowBattleStats, target,
  "pkmn.apply_effect_event(:display, pkmn) { |m| report.push(m) }")

# clear boss effects
UniLib.insert_in_method(:PokeBattle_Battle, :pbShieldEffects, "if onBreakdata[:effectClear]",
  "UniLib::BOSS_NEGATIVE_EFFECTS.each { |e, v| (battler.effects[e] = v; animplay = true) if battler.effects[e] } ")