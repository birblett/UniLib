# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
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

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.with_priority(999) {

# type modifiers (in battle, on switch in)
UniLib.insert_in_method(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, :TAIL,
  "self.apply_effect_event(:primary_type_battle, self, true) { |m| @type1 = m } if onactive
  self.apply_effect_event(:secondary_type_battle, self, true) { |m| @type2 = (m == @type1 ? nil : m) } if onactive")

# type modifiers (in battle, on update)
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "self.apply_effect_event(:primary_type_battle, self, false) { |m| @type1 = m }
  self.apply_effect_event(:secondary_type_battle, self, false) { |m| @type2 = (m == @type1 ? nil : m) }")

# resistance modifiers and overrides
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, "if opponent.crested",
  "opponent.effect_event_value(:forced_resistance) { |forced| typemod = forced[type] unless forced[type].nil? }
  opponent.effect_event_value(:fake_reduce_weakness) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_WEAKNESS_MAP) }
  opponent.effect_event_value(:fake_resistance) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_RESISTANCE_MAP) }
  opponent.apply_effect_event(:type_effectiveness_simple, opponent, type, true) { |m| typemod *= m }
  typemod = 0 if typemod < 0")

# resistance modifiers and overrides (ai)
UniLib.insert_in_method_before(:PokeBattle_AI, :pbTypeModNoMessages, "case opponent.crested",
  "opponent.effect_event_value(:forced_resistance) { |forced| typemod = forced[type] unless forced[type].nil? }
  opponent.effect_event_value(:fake_reduce_weakness) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_WEAKNESS_MAP) }
  opponent.effect_event_value(:fake_resistance) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_RESISTANCE_MAP) }
  opponent.apply_effect_event(:type_effectiveness_simple, opponent, type, false) { |m| typemod *= m }
  typemod = 0 if typemod < 0", 1)

# move type effectiveness modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return mod1*mod2",
  "attacker.apply_effect_event(:type_effectiveness, attacker, opponent, self, mod1, mod2) { |mod| mod1, mod2 = mod[0], mod[1] }")

# move stab override
UniLib.insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false",
  "attacker.effect_event_value(:stab_type) { |types| typecrest = true if types.include?(type) }")

# move stab override (ai)
UniLib.insert_in_method(:PokeBattle_AI, :pbRoughDamage, "typecrest = false",
  "attacker.effect_event_value(:stab_type) { |types| typecrest = true if types.include?(type) }", 1)

# battle stat modifier (on initialize)
UniLib.insert_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "crestStats if @crested",
  "stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
  self.apply_effect_event(:battle_stat_calc, self, stats) {}
  @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }")

# battle stat modifier (on update)
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
  self.apply_effect_event(:battle_stat_calc, self, stats) {}
  @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }")

# battle speed modifier (on calculation)
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbSpeed, "speed = 1 if speed <= 1",
  "self.apply_effect_event(:battle_speed_calc, self) { |m| speed *= m }")

# move damage/damage taken modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability",
  "attacker.apply_effect_event(:damage_mod, attacker, opponent, self, hitnum, nil) { |m| basemult *= m }
  opponent.apply_effect_event(:damage_taken_mod, opponent, attacker, self, hitnum, nil) { |m| basemult *= m }")

# move damage/damage taken modifier (ai)
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "typecrest = false",
  "attacker.apply_effect_event(:damage_mod, attacker, opponent, move, move.pbNumHits(attacker), self) { |m| damage *= m }
  opponent.apply_effect_event(:damage_taken_mod, opponent, attacker, move, move.pbNumHits(attacker), self) { |m| damage *= m }")

# move accuracy modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)",
  "base, acc, eva = NumberContainer.of(baseaccuracy, accuracy, evasion)
  attacker.apply_effect_event(:accuracy_mod, attacker, self, base, acc, eva) { |m| return true if m }
  baseaccuracy, accuracy, evasion = base.value, acc.value, eva.value")

# move priority modifier
UniLib.insert_in_method(:PokeBattle_Battle, :pbPriority, "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)",
  "@battlers[i].apply_effect_event(:move_priority, @battlers[i], @choices[i][2]) { |m| pri += m }")

# move priority modifier (check only)
UniLib.insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER",
  "attacker.apply_effect_event(:move_priority, attacker, self) { |m| pri += m }")

# move crit rate modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCritRate?, "c=3 if c>3",
  "attacker.apply_effect_event(:crit_mod, attacker, opponent, self) { |m| c += m }")

# hit number modifier
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "target.damagestate.reset",
  "self.apply_effect_event(:hit_count_mod, self, target, basemove) { |m| self.effects[:Multihit] = (numhits += m) > 1 }")

# move type override
UniLib.insert_in_method(:PokeBattle_Move, :pbType, :HEAD,
  "attacker.apply_effect_event(:move_type_override, attacker, self, type) { |m| type = m }")

# move type override (ai)
UniLib.insert_in_method(:PokeBattle_AI, :pbTypeModNoMessages, "id = move.move",
  "attacker.apply_effect_event(:move_type_override, attacker, move, type) { |m| type = m }")

# move subtype provider
UniLib.insert_in_method(:PokeBattle_Move, :getSecondaryType, "secondtype = []",
  "attacker.apply_effect_event(:move_subtype, attacker, self) { |m| secondtype.push(m) }")

# attacking stat modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "if opponent.ability != :UNAWARE || opponent.moldbroken",
  "attacker.apply_effect_event(:move_stat_override, attacker, opponent, self) { |m|
    m = [:hp, :atk, :def, :spa, :spd, :spe][m] if m.is_a? Integer
    case m.downcase
      when :hp then atk = attacker.hp
      when :atk then atk = attacker.attack; atkstage = attacker.stages[PBStats::ATTACK]+6
      when :def then atk = attacker.defense; atkstage = attacker.stages[PBStats::DEFENSE]+6
      when :spa then atk = attacker.spatk; atkstage = attacker.stages[PBStats::SPATK]+6
      when :spd then atk = attacker.spdef; atkstage = attacker.stages[PBStats::SPDEF]+6
      when :spe then atk = attacker.speed; atkstage = attacker.stages[PBStats::SPEED]+6
      when :opphp then atk = opponent.hp
      when :oppatk then atk = opponent.attack; atkstage = opponent.stages[PBStats::ATTACK]+6
      when :oppdef then atk = opponent.defense; atkstage = opponent.stages[PBStats::DEFENSE]+6
      when :oppspa then atk = opponent.spatk; atkstage = opponent.stages[PBStats::SPATK]+6
      when :oppspd then atk = opponent.spdef; atkstage = opponent.stages[PBStats::SPDEF]+6
      when :oppspe then atk = opponent.speed; atkstage = opponent.stages[PBStats::SPEED]+6
    end if m.is_a? Symbol
  }")

# attacking stat modifier (ai)
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "attacker.apply_effect_event(:move_stat_override, attacker, opponent, move) { |m|
    m = [:hp, :atk, :def, :spa, :spd, :spe][m] if m.is_a? Integer
    case m.downcase
      when :hp then atk = attacker.hp
      when :atk then atk = attacker.attack; atkstage = attacker.stages[PBStats::ATTACK]+6
      when :def then atk = attacker.defense; atkstage = attacker.stages[PBStats::DEFENSE]+6
      when :spa then atk = attacker.spatk; atkstage = attacker.stages[PBStats::SPATK]+6
      when :spd then atk = attacker.spdef; atkstage = attacker.stages[PBStats::SPDEF]+6
      when :spe then atk = attacker.speed; atkstage = attacker.stages[PBStats::SPEED]+6
      when :opphp then atk = opponent.hp
      when :oppatk then atk = opponent.attack; atkstage = opponent.stages[PBStats::ATTACK]+6
      when :oppdef then atk = opponent.defense; atkstage = opponent.stages[PBStats::DEFENSE]+6
      when :oppspa then atk = opponent.spatk; atkstage = opponent.stages[PBStats::SPATK]+6
      when :oppspd then atk = opponent.spdef; atkstage = opponent.stages[PBStats::SPDEF]+6
      when :oppspe then atk = opponent.speed; atkstage = opponent.stages[PBStats::SPEED]+6
    end if m.is_a? Symbol
  }")

# effect initialization event
UniLib.insert_in_method(:PokeBattle_Battler, :pbInitEffects, :TAIL,
  "self.apply_effect_event(:effects_init, self, self.battle, self.effects, oldeffects, fakebattler) {}")

# switch in event
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "if self.ability == :INTIMIDATE && onactive",
  "self.apply_effect_event(:battle_entry, self, self.battle, index) {} if onactive")

# move attempted events
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbTryUseMove, "protype=basemove.pbType(self,basemove.type)",
  "self.apply_effect_event(:try_move, self, basemove) {}")

# move effect events
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbProcessMoveAgainstTarget, "damage = basemove.pbEffect(user,target,i,alltargets,showanimation)",
  "user.apply_effect_event(:move_effect, user, target, i, basemove) {}")

# after move effect events
UniLib.insert_in_method(:PokeBattle_Battler, :pbProcessMoveAgainstTarget, "damage = basemove.pbEffect(user,target,i,alltargets,showanimation)",
  "user.apply_effect_event(:after_move_effect, user, target, i, basemove) {}")

# switch out events
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbInitialize, "pbInitPokemon(pkmn,index)",
  "self.apply_effect_event(:switch_out, self) {}")

# damage taken/dealt events
UniLib.insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?",
  "user.apply_effect_event(:damage_dealt, user, target, move, damage) {}
  target.apply_effect_event(:damage_taken, target, user, move, damage) {} if damage > 0")

# turn end event handler
UniLib.insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "if i.crested == :VESPIQUEN",
  "i.apply_effect_event(:turn_end, i) {}")

# form change handler
UniLib.insert_in_method(:PokeBattle_Battler, :pbCheckForm, "transformed=false",
  "self.apply_effect_event(:form_change, self, basemove) { |m| transformed = !(self.form = m).nil? } unless self.isFainted?")

# should switch score
UniLib.insert_in_method_before(:PokeBattle_AI, :shouldSwitch?, "switchscore = statusscore + statscore + healscore + forcedscore + typescore + specialscore",
  "@attacker.apply_effect_event(:should_switch_score, self, @attacker, @opponent) { |m| specialscore += m }")

# move scores
UniLib.insert_in_method_before(:PokeBattle_AI, :getMoveScore, "case @move.function",
  "@attacker.apply_effect_event(:move_score, self, @attacker, @opponent, @move) { |m| return -1 if m == -1; miniscore *= m }
  @opponent.apply_effect_event(:targeted_by_move, self, @opponent, @attacker, @move) { |m| return -1 if m == -1; miniscore *= m }")

# ========= effects only ========= #

# battle stats
UniLib.insert_in_function(:pbShowBattleStats, "report.push(_INTL(\"Infatuated with {1}\",@battle.battlers[pkmn.effects[:Attract]].name)) if pkmn.effects[:Attract]>=0",
  "pkmn.apply_effect_event(:display, pkmn) { |m| report.push(m) }")

# clear boss effects
UniLib.insert_in_method(:PokeBattle_Battle, :pbShieldEffects, "if onBreakdata[:effectClear]",
  "UniLib::BOSS_NEGATIVE_EFFECTS.each { |e, v| (battler.effects[e] = v; animplay = true) if battler.effects[e] } ")

}