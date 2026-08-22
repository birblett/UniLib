# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

class EventProvider

  attr_accessor(:event_hash)
  attr_accessor(:symbol)

  def initialize
    # used to check if event is present
    @event_hash = {}
  end

  def add_or_create_event(id, func, block)
    if func.nil? and block.nil?
      print "No function or block provided for event #{id} of #{@symbol}:#{self.class}"
      exit
    elsif block
      @event_hash[id] = [] unless @event_hash[id]
      @event_hash[id].push(block)
    else
      @event_hash[id] = [] unless @event_hash[id]
      @event_hash[id].push(func)
    end
    self
  end

end unless UniLib.lib_loaded(__FILE__)

class PokeBattle_Pokemon

  VALUE_LISTENERS = []
  EVENT_LISTENERS = []

  def self.add_listeners(priority, value, event)
    VALUE_LISTENERS.push([priority, instance_method(value)])
    EVENT_LISTENERS.push([priority, instance_method(event)])
    VALUE_LISTENERS.sort_by! { |a| a[0] }
    EVENT_LISTENERS.sort_by! { |a| a[0] }
  end

end

module EventListeners

  VALUE_LISTENERS = []
  EVENT_LISTENERS = []

  def check_type(type, vtypes, map)
    vtypes.each { |vtype| return map[vtype].include?(type) unless map[vtype].nil? }
    nil
  end

end

class PokeBattle_Battle

  def weather=(other)
    old_weather = @weather
    @weather = other
    setSpeedOrder.each { |battler| EVENT_LISTENERS.each { |_, method| method.bind(battler).(:weather_change, battler, old_weather) } }
  end

end

class PokeBattle_Battler

  include EventListeners

  def self.add_listeners(priority, value, event)
    VALUE_LISTENERS.push([priority, instance_method(value)])
    EVENT_LISTENERS.push([priority, instance_method(event)])
    VALUE_LISTENERS.sort_by! { |a| a[0] }
    EVENT_LISTENERS.sort_by! { |a| a[0] }
  end

end

class PokeBattle_AI

  include EventListeners

end

class PokeBattle_Battle

  include EventListeners

end

class PokeBattle_Move

  include EventListeners

end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

# base stat modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :calcStats, "bs = self.baseStats",
  "stats = NumberContainer.of(*bs)
  EVENT_LISTENERS.each { |_, method| method.bind(self).(:base_stat_mods, self, stats) {} }
  bs = stats.map { |n| n.value }")

# type1 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type1, :HEAD,
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:primary_type, self) { |m| return m } }")

# type2 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
  "t1 = type1
  EVENT_LISTENERS.each { |_, method| method.bind(self).(:secondary_type, self) { |m| return m if m != t1 } }")

# type modifiers (in battle, on switch in)
UniLib.insert_in_method(:PokeBattle_Battler, Rejuv ? :__blessings_onSwitchIn : :pbAbilitiesOnSwitchIn, :TAIL,
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:type1_battle, self, true) { |m| @type1 = m } }
  EVENT_LISTENERS.each { |_, method| method.bind(self).(:type2_battle, self, true) { |m| @type2 = (m == @type1 ? nil : m) } }")

# type modifiers (in battle, on update)
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:type1_battle, self, false) { |m| @type1 = m } }
  EVENT_LISTENERS.each { |_, method| method.bind(self).(:type2_battle, self, false) { |m| @type2 = (m == @type1 ? nil : m) } }")

# resistance modifiers and overrides
UniLib.insert_in_method_before(:PBTypes, :oneTypeEff, "typemod = typemod.inverse if inverse",
  "VALUE_LISTENERS.each { |_, method| method.bind(opponent).(:forced_resistance) { |forced| typemod = forced[type] unless forced[type].nil? } }
  VALUE_LISTENERS.each { |_, method| method.bind(opponent).(:fake_reduce_weakness) { |arr| typemod *= Typemod.half if check_type(type, arr, UniLib::TYPE_WEAKNESS_MAP) } }
  VALUE_LISTENERS.each { |_, method| method.bind(opponent).(:fake_resistance) { |arr| typemod *= Typemod.half if check_type(type, arr, UniLib::TYPE_RESISTANCE_MAP) } }
  EVENT_LISTENERS.each { |_, method| method.bind(opponent).(:type_effectiveness_simple, opponent, type, true) { |m| typemod *= Typemod.new(m, 1) if m } }")

# move type effectiveness modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return typemod",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:attack_type_effectiveness, attacker, opponent, self, typemod) { |m| typemod = Typemod.new(m, 1) if m } }
  EVENT_LISTENERS.each { |_, method| method.bind(opponent).(:defend_type_effectiveness, attacker, opponent, self, typemod) { |m| typemod = Typemod.new(m, 1) if m } }")

# move stab override
UniLib.insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false",
  "VALUE_LISTENERS.each { |_, method| method.bind(attacker).(:stab_type) { |types| typecrest = true if types.include?(type) } }
  EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:conditional_stab_type, attacker, self) { |c| typecrest ||= true } }")

# move stab override (ai)
UniLib.insert_in_method(:PokeBattle_AI, :pbRoughDamage, "typecrest = false",
  "VALUE_LISTENERS.each { |_, method| method.bind(attacker).(:stab_type) { |types| typecrest = true if types.include?(type) } }
  EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:conditional_stab_type, attacker, self) { |c| typecrest ||= true } }")

# battle stat modifier (on initialize)
UniLib.insert_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "crestStats if @crested",
  "stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
  EVENT_LISTENERS.each { |_, method| method.bind(self).(:battle_stat_calc, self, stats) {} }
  @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }")

# battle stat modifier (on update)
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
  EVENT_LISTENERS.each { |_, method| method.bind(self).(:battle_stat_calc, self, stats) {} }
  @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }")

# battle speed modifier (on calculation)
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbSpeed, "speed = 1 if speed <= 1",
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:battle_speed_calc, self) { |m| speed *= m } }")

# move damage/damage taken modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:damage_mod, attacker, opponent, self, hitnum, nil) { |m| basemult.append(m) } }
  EVENT_LISTENERS.each { |_, method| method.bind(opponent).(:damage_taken_mod, opponent, attacker, self, hitnum, nil) { |m| basemult.append(m) } }")

# move damage/damage taken modifier (ai)
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "if attacker.species == :AEGISLASH",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:damage_mod, attacker, opponent, move, move.pbNumHits(attacker), self) { |m| basemult.append(m) } }
  EVENT_LISTENERS.each { |_, method| method.bind(opponent).(:damage_taken_mod, opponent, attacker, move, move.pbNumHits(attacker), self) { |m| basemult.append(m) } }")

# move accuracy modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcAccuracy, "accmult.append(1.67) if @battle.state.effects[:Gravity] != 0",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:accuracy_mod, attacker, opponent, self) { |m| accmult.append(m) } }")

UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughAccuracy, "accmult.append(1.3) if attacker.ability == :COMPOUNDEYES",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:accuracy_mod, attacker, opponent, move) { |m| accmult.append(m) } }")

# move priority modifier
UniLib.insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:move_priority, attacker, self) { |m| pri += m } }")

# move crit rate modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCritRate?, "c = 3 if c > 3",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:crit_mod, attacker, opponent, self) { |m| c += m } }")

# hit number modifier
UniLib.insert_in_method(:PokeBattle_Move, :pbNumHits, :HEAD,
  "attacker.effects[:Multihit] = nil
  EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:hit_count_mod, attacker, self) { |m| return m if m and (attacker.effects[:Multihit] = m > 1) } }")

# move type override
UniLib.insert_in_method(:PokeBattle_Move, :pbType, :HEAD,
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:move_type_override, attacker, self, type) { |m| type = m } }")

# move type override (ai)
UniLib.insert_in_method(:PokeBattle_AI, :pbTypeModNoMessages, "return Typemod.normal if [:User, :OpposingSide, :BothSides, :UserSide, :AllyBattlers].include?(attacker.pbTarget(move))",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:move_type_override, attacker, move, type) { |m| type = m } }")

# move subtype provider
UniLib.insert_in_method(:PokeBattle_Move, :getSecondaryType, "secondtypes = []",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:move_subtype, attacker, self) { |m| secondtype.push(m) } }")

# attacking stat modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "unless oppUnaware",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:move_stat_override, attacker, opponent, self) { |m|
    m = [:hp, :atk, :def, :spa, :spd, :spe][m] if m.is_a? Integer
    case m.downcase
      when :hp then atk = attacker.hp
      when :atk then atk = attacker.attack; atkstage = attacker.stages[PBStats::ATTACK]+6
      when :def then atk = attacker.pbDefense(unaware: true); atkstage = attacker.stages[PBStats::DEFENSE]+6
      when :spa then atk = attacker.spatk; atkstage = attacker.stages[PBStats::SPATK]+6
      when :spd then atk = attacker.pbSpecialDefense(unaware: true); atkstage = attacker.stages[PBStats::SPDEF]+6
      when :spe then atk = attacker.pbSpeed; atkstage = attacker.stages[PBStats::SPEED]+6
      when :opphp then atk = opponent.hp
      when :oppatk then atk = opponent.attack; atkstage = opponent.stages[PBStats::ATTACK]+6
      when :oppdef then atk = opponent.pbDefense(unaware: true, moldBrokenArray: moldBrokenArray); atkstage = opponent.stages[PBStats::DEFENSE]+6
      when :oppspa then atk = opponent.spatk; atkstage = opponent.stages[PBStats::SPATK]+6
      when :oppspd then atk = opponent.pbSpecialDefense(unaware: true, moldBrokenArray: moldBrokenArray); atkstage = opponent.stages[PBStats::SPDEF]+6
      when :oppspe then atk = opponent.pbSpeed; atkstage = opponent.stages[PBStats::SPEED]+6
    end if m.is_a? Symbol
  } }")

# attacking stat modifier (ai)
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "EVENT_LISTENERS.each { |_, method| method.bind(attacker).(:move_stat_override, attacker, opponent, move) { |m|
    m = [:hp, :atk, :def, :spa, :spd, :spe][m] if m.is_a? Integer
    case m.downcase
      when :hp then atk = attacker.hp
      when :atk then atk = attacker.attack; atkstage = attacker.stages[PBStats::ATTACK]+6
      when :def then atk = attacker.pbDefense(unaware: true); atkstage = attacker.stages[PBStats::DEFENSE]+6
      when :spa then atk = attacker.spatk; atkstage = attacker.stages[PBStats::SPATK]+6
      when :spd then atk = attacker.pbSpecialDefense(unaware: true); atkstage = attacker.stages[PBStats::SPDEF]+6
      when :spe then atk = attacker.pbSpeed; atkstage = attacker.stages[PBStats::SPEED]+6
      when :opphp then atk = opponent.hp
      when :oppatk then atk = opponent.attack; atkstage = opponent.stages[PBStats::ATTACK]+6
      when :oppdef then atk = opponent.pbDefense(unaware: true, moldBrokenArray: moldBrokenArray); atkstage = opponent.stages[PBStats::DEFENSE]+6
      when :oppspa then atk = opponent.spatk; atkstage = opponent.stages[PBStats::SPATK]+6
      when :oppspd then atk = opponent.pbSpecialDefense(unaware: true, moldBrokenArray: moldBrokenArray); atkstage = opponent.stages[PBStats::SPDEF]+6
      when :oppspe then atk = opponent.pbSpeed; atkstage = opponent.stages[PBStats::SPEED]+6
    end if m.is_a? Symbol
  } }")

# effect initialization event
UniLib.insert_in_method(:PokeBattle_Battler, :pbInitEffects, :TAIL,
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:effects_init, self, self.battle, self.effects, oldeffects, fakebattler) {} }")

UniLib.insert_in_method_before(:PokeBattle_Battler, Rejuv ? :__blessings_onSwitchIn : :pbAbilitiesOnSwitchIn, "return if @hp <= 0",
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:battle_entry, self, self.battle, index) {} }")

# move attempted events
UniLib.insert_in_method_before(:PokeBattle_Battler, Rejuv ? :__blessings_tryUseMove : :pbTryUseMove, "pbCheckStance(basemove) if self.ability == :STANCECHANGE",
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:try_move, self, basemove) {} }")

UniLib.insert_in_method_before(:PokeBattle_Battler, Rejuv ? :__blessings_resolveMoveEffects : :pbResolveMoveEffects, "basemove.pbEffect(user, targets, hitcount)",
  "targets.each { |target| EVENT_LISTENERS.each { |_, method| method.bind(user).(:move_effect, user, target, hitcount, basemove) {} } }")

UniLib.insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "basemove.pbEffectTarget(user, opponent, 0, [opponent])",
  "targets.each { |target| EVENT_LISTENERS.each { |_, method| method.bind(user).(:move_effect, user, opponent, 1, basemove) {} } }")

# after move effect events
UniLib.insert_in_method(:PokeBattle_Battler, Rejuv ? :__blessings_resolveMoveEffects : :pbResolveMoveEffects, "basemove.pbEffect(user, targets, hitcount)",
  "targets.each { |target| EVENT_LISTENERS.each { |_, method| method.bind(user).(:after_move_effect, user, target, hitcount, basemove) {} } }")

UniLib.insert_in_method(:PokeBattle_Battler, :pbUseMove, "basemove.pbEffect(user, [opponent])",
  "targets.each { |target| EVENT_LISTENERS.each { |_, method| method.bind(user).(:after_move_effect, user, opponent, 1, basemove) {} } }")

# after move attempt events
UniLib.insert_in_method(:PokeBattle_Battler, :applyPostMoveEffects, :TAIL,
  "targets.each { |target| EVENT_LISTENERS.each { |_, method| method.bind(self).(:after_move_attempt, self, target, basemove) {} } }")

# switch out events
UniLib.insert_in_method_before(:PokeBattle_Battler, Rejuv ? :__rejuv_pbInitialize : :pbInitialize, "pbInitPokemon(pkmn, index)",
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:switch_out, self) {} } unless self.isFainted?")

# damage taken/dealt events
UniLib.insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?",
  "EVENT_LISTENERS.each { |_, method| method.bind(user).(:damage_dealt, user, target, move, damage) {} }
  EVENT_LISTENERS.each { |_, method| method.bind(target).(:damage_taken, target, user, move, damage) {} } if damage > 0")

# ko events
UniLib.insert_in_method(:PokeBattle_Battler, :pbOnKillEffects, :TAIL,
  "EVENT_LISTENERS.each { |_, method| method.bind(self).(:on_ko, self, targets, basemove) {} }")

# turn end event handler
UniLib.insert_in_method(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "priority.each { |i| i.pbCheckFormRoundEnd unless i.isFainted? }",
  "priority.each { |i| EVENT_LISTENERS.each { |_, method| method.bind(i).(:turn_end, i) {} } }")

# form change handler
UniLib.insert_in_method(:PokeBattle_Battler, :pbCheckFormRoundEnd, :TAIL,
  "transformed = false
  EVENT_LISTENERS.each { |_, method| method.bind(self).(:form_change, self, nil) { |m| transformed = !(self.form = m).nil? } } unless self.isFainted?
  if transformed
    @battle.scene.pbChangePokemon(self,@pokemon)
    @battle.pbDisplay(_INTL(\"{1} transformed!\",pbThis))
  end")
UniLib.insert_in_method(:PokeBattle_Battler, Rejuv ? :__blessings_tryUseMove : :pbTryUseMove, "pbCheckStance(basemove) if self.ability == :STANCECHANGE",
  "transformed = false
  EVENT_LISTENERS.each { |_, method| method.bind(self).(:form_change, self, basemove) { |m| transformed = !(self.form = m).nil? } } unless self.isFainted?
  if transformed
    @battle.scene.pbChangePokemon(self,@pokemon)
    @battle.pbDisplay(_INTL(\"{1} transformed!\",pbThis))
  end")

# field set
UniLib.insert_in_method(:PokeBattle_Battle, :setField, :TAIL,
  "setSpeedOrder.each { |battler| EVENT_LISTENERS.each { |_, method| method.bind(battler).(:field_set, battler, oldfield) } }")

# field end (break)
UniLib.insert_in_method(:PokeBattle_Battle, :breakField, :TAIL,
  "setSpeedOrder.each { |battler| EVENT_LISTENERS.each { |_, method| method.bind(battler).(:field_end, battler, oldfield, true) } }")

# field end (temp)
UniLib.insert_in_method(:PokeBattle_Battle, :endTempField, :TAIL,
  "setSpeedOrder.each { |battler| EVENT_LISTENERS.each { |_, method| method.bind(battler).(:field_end, battler, oldfield, false) } }")

# switch in score
UniLib.insert_in_method(:PokeBattle_AI, :getSwitchInScoresParty, "monscore += otherscore",
  "EVENT_LISTENERS.each { |_, method| method.bind(i).(:switch_in_score, self, i) { |m| monscore += m } }")

# move scores
UniLib.insert_in_method_before(:PokeBattle_AI, :getMoveScore, "case @move.function",
  "EVENT_LISTENERS.each { |_, method| method.bind(@attacker).(:move_score, self, @attacker, @opponent, @move) { |m| return -1 if m == -1; miniscore *= m } }
  EVENT_LISTENERS.each { |_, method| method.bind(@opponent).(:targeted_by_move, self, @opponent, @attacker, @move) { |m| return -1 if m == -1; miniscore *= m } }")

# should switch score
UniLib.insert_in_method_before(:PokeBattle_AI, :shouldSwitch?, "switchscore = statusscore + statscore + healscore + forcedscore + typescore + specialscore",
  "EVENT_LISTENERS.each { |_, method| method.bind(@attacker).(:should_switch_score, self, @attacker, @opponent) { |m| specialscore += m } }")

# role provider
UniLib.insert_in_method_before(:PokeBattle_AI, :pbGetMonRoles, "allMonRoles.push(monRoles)",
  "(mon.is_a?(PokeBattle_Pokemon) ? PokeBattle_Pokemon::EVENT_LISTENERS : EVENT_LISTENERS).each { |_, method| method.bind(mon).(:roles, self, mon) { |m| (m.is_a?(Array) ? monRoles += m : monRoles.push(m)) if m } }")