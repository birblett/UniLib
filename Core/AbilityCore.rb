# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Multibility"
UniLib.include "Constants"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  ABILITY_DATA = load_data("Data/abil.dat") unless defined? ABILITY_DATA
  CUSTOM_ABILITIES = {}
  POKEMON_ABILITY_CACHE = {}

end

class AbilityModifier

  attr_accessor(:name)
  attr_accessor(:primary)
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
  attr_accessor(:type_effectiveness_modifiers)
  attr_accessor(:type_modifiers)
  attr_accessor(:move_type_overrides)
  attr_accessor(:move_stat_overrides)
  attr_accessor(:on_battle_entry_events)
  attr_accessor(:on_move_attempt_events)
  attr_accessor(:on_dealt_damage_events)
  attr_accessor(:on_damage_events)
  attr_accessor(:on_turn_end_events)
  attr_accessor(:form_changes)
  attr_accessor(:disrupt_modifiers)
  attr_accessor(:weather_scores)
  attr_accessor(:ability_scores)
  attr_accessor(:field_scores)
  attr_accessor(:has_event)

  def initialize(symbol, name=nil, desc=nil, fulldesc=nil)
    @sym = symbol
    @name = name
    @full_name = nil
    @desc = desc
    @full_desc = fulldesc.nil? ? desc : fulldesc
    @primary = nil
    @secondary = nil
    @resistance_fakes = []
    @type_effectiveness_modifiers = []
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
    @on_move_attempt_events = []
    @on_dealt_damage_events = []
    @on_damage_events = []
    @on_turn_end_events = []
    @form_changes = []
    @disrupt_modifiers = []
    @weather_scores = []
    @ability_scores = []
    @field_scores = []
    @has_event = {}
  end

  def self.has_event?(ability, id)
    !UniLib::CUSTOM_ABILITIES[ability].nil? and UniLib::CUSTOM_ABILITIES[ability].has_event[id]
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

end unless UniLib.lib_loaded(__FILE__)

module PokeBattle_Pokemon_Ability

  attr_accessor(:base)

end

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

# type1 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type1, :HEAD,
  "unless UniLib::POKEMON_ABILITY_CACHE[self] and UniLib::POKEMON_ABILITY_CACHE[self].base == self.ability
    UniLib::POKEMON_ABILITY_CACHE[self] = AbilityContainer.new(self, self.ability)
    UniLib::POKEMON_ABILITY_CACHE[self].extend PokeBattle_Pokemon_Ability
    UniLib::POKEMON_ABILITY_CACHE[self].base = self.ability
  end
  UniLib::POKEMON_ABILITY_CACHE[self].abilities.each do |ability|
    return UniLib::CUSTOM_ABILITIES[ability].primary if AbilityModifier.has_event?(ability, :primary_type)
  end")

# type2 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
  "t1 = type1
  UniLib::POKEMON_ABILITY_CACHE[self].abilities.each do |ability|
    return UniLib::CUSTOM_ABILITIES[ability].secondary if AbilityModifier.has_event?(ability, :secondary_type) and UniLib::CUSTOM_ABILITIES[ability].secondary != t1
  end")

# resistance modifiers and overrides
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, "if opponent.crested",
  "opponent.ability.abilities.each do |ability|
    if AbilityModifier.has_event?(ability, :type_effectiveness_simple)
      typemod = UniLib::CUSTOM_ABILITIES[ability].forced_resistances[type] if (b = !UniLib::CUSTOM_ABILITIES[ability].forced_resistances[type].nil?)
      typemod /= 2 if (b = check_type(type, UniLib::CUSTOM_ABILITIES[ability].weakness_fakes, UniLib::TYPE_WEAKNESS_MAP)) unless b
      typemod /= 2 if check_type(type, UniLib::CUSTOM_ABILITIES[ability].resistance_fakes, UniLib::TYPE_RESISTANCE_MAP) unless b
      UniLib::CUSTOM_ABILITIES[ability].type_effectiveness_modifiers.each { |provider| typemod *= provider.call(opponent, type) unless provider.call(opponent, type).nil? }
    end
  end", 0, 1001)

# resistance modifiers and overrides
UniLib.insert_in_method_before(:PokeBattle_AI, :pbTypeModNoMessages, "case opponent.crested",
  "opponent.ability.abilities.each do |ability|
    if AbilityModifier.has_event?(ability, :type_effectiveness_simple)
      typemod = UniLib::CUSTOM_ABILITIES[ability].forced_resistances[type] if (b = !UniLib::CUSTOM_ABILITIES[ability].forced_resistances[type].nil?)
      typemod /= 2 if (b = check_type(type, UniLib::CUSTOM_ABILITIES[ability].weakness_fakes, UniLib::TYPE_WEAKNESS_MAP)) unless b
      typemod /= 2 if check_type(type, UniLib::CUSTOM_ABILITIES[ability].resistance_fakes, UniLib::TYPE_RESISTANCE_MAP) unless b
      UniLib::CUSTOM_ABILITIES[ability].type_effectiveness_modifiers.each { |provider| typemod *= provider.call(opponent, type) unless provider.call(opponent, type).nil? }
    end if opponent.ability.is_a?(AbilityContainer)
  end", 1, 1001)

# move type effectiveness modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return mod1*mod2",
  "attacker.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].type_modifiers.each do |mod|
      modifiers = mod.call(attacker, opponent, atype, mod1, mod2)
      mod1, mod2 = modifiers[0], modifiers[1] unless modifiers.nil?
    end if AbilityModifier.has_event?(ability, :type_effectiveness)
  end", 0, 1001)

# move stab override
UniLib.insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false",
  "attacker.ability.abilities.each { |ability| basemult *= 1.5 if AbilityModifier.has_event?(ability, :stab_type) and UniLib::CUSTOM_ABILITIES[ability].stab_overrides == type }", 0, 1001)

# move stab override
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "attacker.ability.abilities.each { |ability| basemult *= 1.5 if AbilityModifier.has_event?(ability, :stab_type) and UniLib::CUSTOM_ABILITIES[ability].stab_overrides == type }", 1, 1001)

# battle stat modifier
UniLib.insert_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "crestStats if @crested",
  "@ability.abilities.each do |ability|
    if AbilityModifier.has_event?(ability, :battle_stat_calc)
      stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
      UniLib::CUSTOM_ABILITIES[ability].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
      @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
    end
  end", 0, 1001)

# battle stat modifier
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "@ability.abilities.each do |ability|
    if AbilityModifier.has_event?(ability, :battle_stat_calc)
      stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
      UniLib::CUSTOM_ABILITIES[ability].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
      @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
    end
  end", 0, 1001)

# move damage modifier
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "attacker.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].damage_modifiers.each do |mod|
      modifier = mod.call(attacker, opponent, move, move.pbNumHits(attacker), true)
      damage *= modifier unless modifier.nil?
    end if AbilityModifier.has_event?(ability, :damage_mod)
  end if attacker.ability.is_a?(AbilityContainer)", 1, 1001)

# move damage modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability",
  "attacker.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].damage_modifiers.each do |mod|
      modifier = mod.call(attacker, opponent, self, hitnum, false)
      basemult *= modifier unless modifier.nil?
    end if AbilityModifier.has_event?(ability, :damage_mod)
  end", 0, 1001)

# move accuracy modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)",
  "attacker.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].accuracy_modifiers.each do |mod|
      modified = mod.call(attacker, self, baseaccuracy, accuracy, evasion)
      baseaccuracy, accuracy, evasion = *modified unless modified.nil?
      return true if baseaccuracy == 0
    end if AbilityModifier.has_event?(ability, :move_accuracy)
  end", 0, 1001)

# move priority modifier
UniLib.insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER",
  "attacker.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].priority_modifiers.each do |mod|
      modifier = mod.call(attacker, self)
      pri += modifier unless modifier.nil?
    end  if AbilityModifier.has_event?(ability, :move_priority)
  end if attacker.ability.is_a?(AbilityContainer)", 0, 1001)

# move priority modifier
UniLib.insert_in_method(:PokeBattle_Battle, :pbPriority, "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)",
  "attacker, move = @battlers[i], @choices[i][2]
  attacker.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].priority_modifiers.each do |mod|
      modifier = mod.call(attacker, move)
      pri += modifier unless modifier.nil?
    end if AbilityModifier.has_event?(ability, :move_priority)
  end if attacker.ability.is_a?(AbilityContainer)", 0, 1001)

# hit number modifier
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "target.damagestate.reset",
  "@ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].hit_number_modifiers.each do |mod|
      modifier = mod.call(self, target, basemove)
      numhits += modifier unless modifier.nil?
    end if AbilityModifier.has_event?(ability, :move_hit_count)
    self.effects[:Multihit] = numhits > 1
  end", 0, 1001)

# move type override
UniLib.insert_in_method(:PokeBattle_Move, :pbType, :HEAD,
  "attacker.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].move_type_overrides.each do |mod|
      tmp = mod.call(attacker, self, type)
      type = tmp unless tmp.nil?
    end if AbilityModifier.has_event?(ability, :move_type)
  end", 0, 1001)

# attacking stat modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "if attacker.ability == :HUSTLE && pbIsPhysical?(type)",
  "attacker.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].move_stat_overrides.each do |mod|
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
    end if AbilityModifier.has_event?(ability, :move_stat)
  end", 0, 1001)

# switch in event
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "if self.ability == :INTIMIDATE && onactive",
  "self.ability.abilities.each { |ability| UniLib::CUSTOM_ABILITIES[ability].on_battle_entry_events.each { |event| event.call(self, self.battle, index) } if AbilityModifier.has_event?(ability, :battle_entry) } if onactive", 0, 1001)

# move attempted events
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbTryUseMove, "protype=basemove.pbType(self,basemove.type)",
  "self.ability.abilities.each { |ability| UniLib::CUSTOM_ABILITIES[ability].on_move_attempt_events.each { |event| event.call(self, basemove) } if AbilityModifier.has_event?(ability, :try_move) }", 0, 1001)

# damage taken/dealt events
UniLib.insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?",
  "user.ability.abilities.each { |ability| UniLib::CUSTOM_ABILITIES[ability].on_dealt_damage_events.each { |event| event.call(user, target, move, damage) } if AbilityModifier.has_event?(ability, :damage_dealt) }
  target.ability.abilities.each { |ability| UniLib::CUSTOM_ABILITIES[ability].on_damage_events.each { |event| event.call(user, target, move, damage) } if AbilityModifier.has_event?(ability, :damage_taken) }", 0, 1001)

# turn end event handler
UniLib.insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "if i.crested == :VESPIQUEN",
  "i.ability.abilities.each { |ability| UniLib::CUSTOM_ABILITIES[ability].on_turn_end_events.each { |event| event.call(i) } if AbilityModifier.has_event?(ability, :turn_end) }", 0, 1001)

# form change handler
UniLib.insert_in_method(:PokeBattle_Battler, :pbCheckForm, "transformed=false",
  "self.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].form_changes.each do |mod|
      unless (f = mod.call(self, basemove)).nil?
        self.form = f
        transformed=true
      end
    end if AbilityModifier.has_event?(ability, :form_change)
  end if self.ability.is_a? AbilityContainer", 0, 1001)

# ability disrupt score
UniLib.insert_in_method_before(:PokeBattle_AI, :getAbilityDisruptScore, "case opponent.ability",
  "opponent.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].disrupt_modifiers.each do |mod|
      abilityscore *= mod unless (mod = mod.call(self, attacker, opponent)).nil?
    end if AbilityModifier.has_event?(ability, :disrupt_modifier)
  end if opponent.ability.is_a? AbilityContainer")

# ability weather score
UniLib.insert_in_method_before(:PokeBattle_AI, :getSwitchInScoresParty, "case @battle.weather",
  "i.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].weather_scores.each do |mod|
      weatherscore += mod unless (mod = mod.call(self, i, @battle.weather)).nil?
    end if AbilityModifier.has_event?(ability, :weather_score)
  end if i.ability.is_a? AbilityContainer")

# ability score
UniLib.insert_in_method_before(:PokeBattle_AI, :getSwitchInScoresParty, "case i.ability",
  "i.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].ability_scores.each do |mod|
      abilityscore += mod unless (mod = mod.call(self, i)).nil?
    end if AbilityModifier.has_event?(ability, :ability_score)
  end if i.ability.is_a? AbilityContainer")

# ability field score
UniLib.insert_in_method_before(:PokeBattle_AI, :getSwitchInScoresParty, "case @battle.FE",
  "i.ability.abilities.each do |ability|
    UniLib::CUSTOM_ABILITIES[ability].field_scores.each do |mod|
      fieldscore += mod unless (mod = mod.call(self, i, @battle.FE)).nil?
    end if AbilityModifier.has_event?(ability, :field_score)
  end if i.ability.is_a? AbilityContainer")