# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)
unilib_include "NumberContainer"
unilib_include "Multibility"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

ABILITY_DATA = load_data("Data/abil.dat") unless defined? ABILITY_DATA
CUSTOM_ABILITIES = {}

class AbilityModifier

  attr_accessor(:secondary)
  attr_accessor(:stab_overrides)
  attr_accessor(:resistance_fakes)
  attr_accessor(:weakness_fakes)
  attr_accessor(:forced_resistances)
  attr_accessor(:battle_stat_modifiers)
  attr_accessor(:damage_modifiers)
  attr_accessor(:accuracy_modifiers)
  attr_accessor(:priority_modifiers)
  attr_accessor(:hit_number_modifiers)
  attr_accessor(:type_modifiers)
  attr_accessor(:move_type_overrides)
  attr_accessor(:move_stat_overrides)
  attr_accessor(:on_battle_entry_events)
  attr_accessor(:on_dealt_damage_events)
  attr_accessor(:on_damage_events)
  attr_accessor(:on_turn_end_events)

  def initialize(symbol, name=nil, desc=nil, fulldesc=nil)
    @sym = symbol
    @name = name
    @full_name = nil
    @desc = desc
    @full_desc = fulldesc.nil? ? desc : fulldesc
    @secondary = nil
    @resistance_fakes = []
    @stab_overrides = []
    @weakness_fakes = []
    @forced_resistances = {}
    @battle_stat_modifiers = []
    @damage_modifiers = []
    @accuracy_modifiers = []
    @priority_modifiers = []
    @hit_number_modifiers = []
    @type_modifiers = []
    @move_type_overrides = []
    @move_stat_overrides = []
    @on_battle_entry_events = []
    @on_dealt_damage_events = []
    @on_damage_events = []
    @on_turn_end_events = []
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

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def add_abilities
  $cache.abil.each { |ab, _| $cache.abil.delete(ab) if ABILITY_DATA[ab].nil? and CUSTOM_ABILITIES[ab].nil? }
  CUSTOM_ABILITIES.each { |_, ability_builder| ability_builder.build }
end

add_play_event(:add_abilities, 1001)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, "if opponent.crested",
  "opponent.ability.abilities.each do |ability|
    if CUSTOM_ABILITIES[ability]
      typemod = CUSTOM_ABILITIES[ability].forced_resistances[type] if (b = !CUSTOM_ABILITIES[ability].forced_resistances[type].nil?)
      typemod /= 2 if (b = check_type(type, CUSTOM_ABILITIES[ability].weakness_fakes, TYPE_WEAKNESS_MAP)) unless b
      typemod /= 2 if check_type(type, CUSTOM_ABILITIES[ability].resistance_fakes, TYPE_RESISTANCE_MAP) unless b
    end
  end")

insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false",
  "attacker.ability.abilities.each { |ability| basemult *= 1.5 if !CUSTOM_ABILITIES[ability].nil? and CUSTOM_ABILITIES[ability].stab_overrides == type }")

insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "attacker.ability.abilities.each { |ability| basemult *= 1.5 if !CUSTOM_ABILITIES[ability].nil? and CUSTOM_ABILITIES[ability].stab_overrides == type }", 1)

insert_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "crestStats if @crested",
  "@ability.abilities.each do |ability|
    if CUSTOM_ABILITIES[ability]
      stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
      CUSTOM_ABILITIES[ability].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
      @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
    end
  end")

insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "@ability.abilities.each do |ability|
    if CUSTOM_ABILITIES[ability]
      stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
      CUSTOM_ABILITIES[ability].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
      @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
    end
  end")

insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "attacker.ability.abilities.each do |ability|
    CUSTOM_ABILITIES[ability].damage_modifiers.each do |mod|
      modifier = mod.call(attacker, opponent, self, self.pbNumHits, true)
      basemult *= modifier unless modifier.nil?
    end unless CUSTOM_ABILITIES[ability].nil?
  end", 1)

insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability",
  "attacker.ability.abilities.each do |ability|
    CUSTOM_ABILITIES[ability].damage_modifiers.each do |mod|
      modifier = mod.call(attacker, opponent, self, hitnum, false)
      basemult *= modifier unless modifier.nil?
    end unless CUSTOM_ABILITIES[ability].nil?
  end")

insert_in_method_before(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)",
  "attacker.ability.abilities.each do |ability|
    CUSTOM_ABILITIES[ability].accuracy_modifiers.each do |mod|
      modified = mod.call(attacker, self, baseaccuracy, accuracy, evasion)
      baseaccuracy, accuracy, evasion = *modified unless modified.nil?
    end unless CUSTOM_ABILITIES[ability].nil?
  end")

insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER",
  "attacker.ability.abilities.each do |ability|
    CUSTOM_ABILITIES[ability].priority_modifiers.each do |mod|
      modifier = mod.call(attacker, self)
      pri += modifier unless modifier.nil?
    end unless CUSTOM_ABILITIES[ability].nil?
  end if attacker.ability.is_a?(AbilityContainer)")

insert_in_method(:PokeBattle_Battle, :pbPriority, "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)",
  "attacker, move = @battlers[i], @choices[i][2]
  attacker.ability.abilities.each do |ability|
    CUSTOM_ABILITIES[ability].priority_modifiers.each do |mod|
      modifier = mod.call(attacker, move)
      pri += modifier unless modifier.nil?
    end unless CUSTOM_ABILITIES[ability].nil?
  end if attacker.ability.is_a?(AbilityContainer)")

insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "target.damagestate.reset",
  "CUSTOM_ABILITIES[@ability].hit_number_modifiers.each do |mod|
    modifier = mod.call(self, target, basemove)
    numhits += modifier unless modifier.nil?
  end unless CUSTOM_ABILITIES[@ability].nil?")

insert_in_method(:PokeBattle_Move, :pbType, :HEAD,
  "attacker.ability.abilities.each do |ability|
    CUSTOM_ABILITIES[ability].move_type_overrides.each do |mod|
      tmp = mod.call(attacker, self, type)
      type = tmp unless tmp.nil?
    end unless CUSTOM_ABILITIES[ability].nil?
  end")

insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "if attacker.ability == :HUSTLE && pbIsPhysical?(type)",
  "attacker.ability.abilities.each do |ability|
    CUSTOM_ABILITIES[ability].move_stat_overrides.each do |mod|
      tmp = mod.call(attacker, opponent, self)
      tmp = [:hp, :atk, :def, :spa, :spd, :spe][tmp] if tmp.is_a? Integer
      case tmp.downcase
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
      end if tmp.is_a? Symbol
    end unless CUSTOM_ABILITIES[ability].nil?
  end")

insert_in_method_before(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "if self.ability == :INTIMIDATE && onactive",
  "self.ability.abilities.each { |ability| CUSTOM_ABILITIES[ability].on_battle_entry_events.each { |event| event.call(self, self.battle, index) } unless CUSTOM_ABILITIES[ability].nil? } if onactive")

insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?",
  "user.ability.abilities.each { |ability| CUSTOM_ABILITIES[ability].on_dealt_damage_events.each { |event| event.call(user, target, move, damage) } unless CUSTOM_ABILITIES[ability].nil? }
  target.ability.abilities.each { |ability| CUSTOM_ABILITIES[ability].on_damage_events.each { |event| event.call(user, target, move, damage) } unless CUSTOM_ABILITIES[ability].nil? }")

insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase,
  "if i.crested == :VESPIQUEN", "i.ability.abilities.each { |ability| CUSTOM_ABILITIES[ability].on_turn_end_events.each { |event| event.call(i) } unless CUSTOM_ABILITIES[ability].nil? }")

insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return mod1*mod2",
  "attacker.ability.abilities.each do |ability|
    CUSTOM_ABILITIES[ability].type_modifiers.each do |mod|
      modifiers = mod.call(attacker, opponent, atype, mod1, mod2)
      mod1, mod2 = modifiers[0], modifiers[1] unless modifiers.nil?
    end unless CUSTOM_ABILITIES[ability].nil?
  end")

