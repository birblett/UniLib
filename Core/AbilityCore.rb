# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Multibility"
UniLib.include "Constants"
UniLib.include "Events"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  ABILITY_DATA = load_data("Data/abil.dat") unless defined? ABILITY_DATA
  CUSTOM_ABILITIES = {}

end

class AbilityModifier < EventProvider

  include UniLib

  attr_accessor(:name)
  attr_accessor(:full_name)
  attr_accessor(:desc)
  attr_accessor(:full_desc)

  def initialize(symbol, name=nil, desc=nil, fulldesc=nil)
    @sym = symbol
    @name = name
    @full_name = nil
    @desc = desc
    @full_desc = fulldesc.nil? ? desc : fulldesc
    super()
  end

  def build
    a = $cache.abil[@sym]
    if a.nil? or (!@name.nil? and a.name != @name) or (!@full_name.nil? and a.fullName != @full_name) or (!@desc.nil? and a.desc != @desc) or (!@full_desc.nil? and a.fullDesc != @fullDesc)
      unless a.nil?
        @name = a.name if @name.nil?
        @full_name = a.fullName if @full_name.nil?
        @desc = a.desc if @desc.nil?
        @full_desc = a.fullDesc if @full_desc.nil?
      end
      $cache.abil[@sym] = AbilityData.new(@sym, { :name => @name, :fullName => @full_name, :desc => @desc, :fullDesc => @full_desc })
    end
  end

  def self.has_event?(ability, id)
    !CUSTOM_ABILITIES[ability].nil? and CUSTOM_ABILITIES[ability].event_hash[id]
  end

  def self.get_event(ability, id)
    CUSTOM_ABILITIES[ability].event_hash[id]
  end

end unless UniLib.lib_loaded(__FILE__)

class PokeBattle_Pokemon_Ability < AbilityContainer

  attr_accessor(:base)
  def initialize(pkmn, ability)
    super
    @base = ability
  end

end unless UniLib.lib_loaded(__FILE__)

class PokeBattle_Pokemon

  def update_ability
    @abil_cache = PokeBattle_Pokemon_Ability.new(self, self.ability) unless @abil_cache and @abil_cache.base == self.ability
  end unless UniLib.lib_loaded(__FILE__)

  def ability_event_value(event)
    update_ability
    return unless @abil_cache.is_a? AbilityContainer
    @abil_cache.abilities.each do |ability|
      next unless AbilityModifier.has_event?(ability, event)
      out = AbilityModifier.get_event(ability, event)
      yield(out) unless out.nil?
    end
  end unless UniLib.lib_loaded(__FILE__)

  def apply_ability_event(event, *args)
    update_ability
    return unless @abil_cache.is_a? AbilityContainer
    @abil_cache.abilities.each do |ability|
      next unless AbilityModifier.has_event?(ability, event)
      AbilityModifier.get_event(ability, event).each { |e, out = e.(*args)| yield(out) unless out.nil? }
    end
  end unless UniLib.lib_loaded(__FILE__)

end

class PokeBattle_Battler

  def ability_event_value(event)
    return unless self.ability.is_a? AbilityContainer
    self.ability.abilities.each do |ability|
      next unless AbilityModifier.has_event?(ability, event)
      out = AbilityModifier.get_event(ability, event)
      yield(out) unless out.nil?
    end
  end

  def apply_ability_event(event, *args)
    return unless self.ability.is_a? AbilityContainer
    self.ability.abilities.each do |ability|
      next unless AbilityModifier.has_event?(ability, event)
      AbilityModifier.get_event(ability, event).each { |e, out = e.(*args)| yield(out) unless out.nil? }
    end
  end

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def add_abilities
  $cache.abil.each { |ab, _| $cache.abil.delete(ab) if UniLib::ABILITY_DATA[ab].nil? and UniLib::CUSTOM_ABILITIES[ab].nil? }
  UniLib::CUSTOM_ABILITIES.each { |_, ability_builder| ability_builder.build }
end unless UniLib.lib_loaded(__FILE__)

UniLib.add_play_event(:add_abilities, 1001)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.with_priority(1001) {

# type1 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type1, :HEAD,
  "self.apply_ability_event(:primary_type, self) { |m| return m }")

# type2 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
  "t1 = type1
  self.apply_ability_event(:secondary_type, self) { |m| return m if m != t1 }")

# type modifiers (in battle, on switch in)
UniLib.insert_in_method(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, :TAIL,
  "self.apply_ability_event(:primary_type_battle, self, true) { |m| @type1 = m }
  self.apply_ability_event(:secondary_type_battle, self, true) { |m| @type2 = (m == @type1 ? nil : m) }")

# type modifiers (in battle, on update)
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "self.apply_ability_event(:primary_type_battle, self, false) { |m| @type1 = m }
  self.apply_ability_event(:secondary_type_battle, self, false) { |m| @type2 = (m == @type1 ? nil : m) }")

# resistance modifiers and overrides
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, "if opponent.crested",
  "opponent.ability_event_value(:forced_resistance) { |forced| typemod = forced[type] unless forced[type].nil? }
  opponent.ability_event_value(:fake_reduce_weakness) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_WEAKNESS_MAP) }
  opponent.ability_event_value(:fake_resistance) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_RESISTANCE_MAP) }
  opponent.apply_ability_event(:type_effectiveness_simple, opponent, type, true) { |m| typemod *= m }
  return 0 if typemod <= 0")

# resistance modifiers and overrides (ai)
UniLib.insert_in_method_before(:PokeBattle_AI, :pbTypeModNoMessages, "case opponent.crested",
  "opponent.ability_event_value(:forced_resistance) { |forced| typemod = forced[type] unless forced[type].nil? }
  opponent.ability_event_value(:fake_reduce_weakness) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_WEAKNESS_MAP) }
  opponent.ability_event_value(:fake_resistance) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_RESISTANCE_MAP) }
  opponent.apply_ability_event(:type_effectiveness_simple, opponent, type, true) { |m| typemod *= m }
  return 0 if typemod <= 0", 1)

# move type effectiveness modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return mod1*mod2",
  "attacker.apply_ability_event(:type_effectiveness, attacker, opponent, self, mod1, mod2) { |mod| mod1, mod2 = mod[0], mod[1] }")

# move stab override
UniLib.insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false",
  "attacker.ability_event_value(:stab_type) { |types| typecrest = true if types.include?(type) }")

# move stab override (ai)
UniLib.insert_in_method(:PokeBattle_AI, :pbRoughDamage, "typecrest = false",
  "attacker.ability_event_value(:stab_type) { |types| typecrest = true if types.include?(type) }", 1)

# battle stat modifier (on initialize)
UniLib.insert_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "crestStats if @crested",
  "stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
  self.apply_ability_event(:battle_stat_calc, self, stats) { |_| }
  @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }")

# battle stat modifier (on update)
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
  self.apply_ability_event(:battle_stat_calc, self, stats) { |_| }
  @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }")

# battle speed modifier (on calculation)
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbSpeed, "speed = 1 if speed <= 1",
  "self.apply_ability_event(:battle_speed_calc, self) { |m| speed *= m }")

# move damage/damage taken modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability",
  "attacker.apply_ability_event(:damage_mod, attacker, opponent, self, hitnum, false) { |m| basemult *= m }
  opponent.apply_ability_event(:damage_taken_mod, opponent, attacker, self, hitnum, false) { |m| basemult *= m }")

# move damage/damage taken modifier (ai)
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "typecrest = false",
  "attacker.apply_ability_event(:damage_mod, attacker, opponent, move, move.pbNumHits(attacker), true) { |m| damage *= m }
  opponent.apply_ability_event(:damage_taken_mod, opponent, attacker, move, move.pbNumHits(attacker), true) { |m| damage *= m }")

# move accuracy modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)",
  "base, acc, eva = NumberContainer.of(baseaccuracy, accuracy, evasion)
  attacker.apply_ability_event(:accuracy_mod, attacker, self, base, acc, eva) { |m| return true if m }
  baseaccuracy, accuracy, evasion = base.value, acc.value, eva.value")

# move priority modifier
UniLib.insert_in_method(:PokeBattle_Battle, :pbPriority, "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)",
  "@battlers[i].apply_ability_event(:move_priority, @battlers[i], @choices[i][2]) { |m| pri += m }")

# move priority modifier (check only)
UniLib.insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER",
  "attacker.apply_ability_event(:move_priority, attacker, self) { |m| pri += m }")

# move crit rate modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCritRate?, "c=3 if c>3",
  "attacker.apply_ability_event(:crit_mod, attacker, opponent, self) { |m| c += m }")

# hit number modifier
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "target.damagestate.reset",
  "self.apply_ability_event(:hit_count_mod, self, target, basemove) { |m| self.effects[:Multihit] = (numhits += m) > 1 }")

# move type override
UniLib.insert_in_method(:PokeBattle_Move, :pbType, :HEAD,
  "attacker.apply_ability_event(:move_type_override, attacker, self, type) { |m| type = m }")

# attacking stat modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "if opponent.ability != :UNAWARE || opponent.moldbroken",
  "attacker.apply_ability_event(:move_stat_override, attacker, opponent, self) { |m|
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
  "attacker.apply_ability_event(:move_stat_override, attacker, opponent, move) { |m|
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
  "self.apply_ability_event(:effects_init, self, self.battle, self.effects, oldeffects, fakebattler) { |_| }")

# switch in event
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "if self.ability == :INTIMIDATE && onactive",
  "self.apply_ability_event(:battle_entry, self, self.battle, index) { |_| } if onactive")

# move attempted events
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbTryUseMove, "protype=basemove.pbType(self,basemove.type)",
  "self.apply_ability_event(:try_move, self, basemove) { |_| }")

# move effect events
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbProcessMoveAgainstTarget, "damage = basemove.pbEffect(user,target,i,alltargets,showanimation)",
  "user.apply_ability_event(:move_effect, user, target, i, basemove) { |_| }")

# after move effect events
UniLib.insert_in_method(:PokeBattle_Battler, :pbProcessMoveAgainstTarget, "damage = basemove.pbEffect(user,target,i,alltargets,showanimation)",
  "user.apply_ability_event(:after_move_effect, user, target, i, basemove) { |_| }")

# damage taken/dealt events
UniLib.insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?",
  "user.apply_ability_event(:damage_dealt, user, target, move, damage) { |_| }
  target.apply_ability_event(:damage_taken, target, user, move, damage) { |_| } if damage > 0")

# turn end event handler
UniLib.insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "if i.crested == :VESPIQUEN",
  "i.apply_ability_event(:turn_end, i) { |_| }")

# form change handler
UniLib.insert_in_method(:PokeBattle_Battler, :pbCheckForm, "transformed=false",
  "self.apply_ability_event(:form_change, self, basemove) { |m| transformed = !(self.form = m).nil? } unless self.isFainted?")

# switch in score
UniLib.insert_in_method(:PokeBattle_AI, :getSwitchInScoresParty, "monscore += otherscore",
  "i.apply_item_event(:switch_in_score, self, i) { |m| monscore += m }")

# move score
UniLib.insert_in_method_before(:PokeBattle_AI, :getMoveScore, "case @move.function",
  "@attacker.apply_ability_event(:move_score, self, @attacker, @opponent, @move) { |m| miniscore *= m }")

# should switch score
UniLib.insert_in_method_before(:PokeBattle_AI, :shouldSwitch?, "switchscore = statusscore + statscore + healscore + forcedscore + typescore + specialscore",
  "@attacker.apply_ability_event(:should_switch_score, self, @attacker, @opponent) { |m| specialscore += m }")

# ========= ability only ========= #

# ability score
UniLib.insert_in_method_before(:PokeBattle_AI, :getSwitchInScoresParty, "case i.ability",
  "i.apply_ability_event(:weather_score, self, i) { |m| abilityscore += mod }")

# ability disrupt score
UniLib.insert_in_method_before(:PokeBattle_AI, :getAbilityDisruptScore, "case opponent.ability",
  "opponent.apply_ability_event(:disrupt_score, self, attacker, opponent) { |m| abilityscore *= mod }")

}