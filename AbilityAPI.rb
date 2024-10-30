# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

class AbilityModifier

  def self.add(symbol, name, desc, fulldesc=nil)
    CUSTOM_ABILITIES[symbol] = AbilityModifier.new(symbol, name, desc, fulldesc) if CUSTOM_ABILITIES[symbol].nil?
    CUSTOM_ABILITIES[symbol]
  end

  <<-DOC
  @param type - type id
  >> gives the users the secondary type while holding the crest.
  DOC
  def crest_secondary_type(type)
    @secondary = type
    self
  end

  <<-DOC
  @param type - type id
  >> gives user STAB and resistances of the given type
  DOC
  def type_fake(type)
    if type.class == Symbol
      stab_override(type)
    end
    resistance_fake(type)
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> equivalent to weakness_override + crest_secondary_type
  DOC
  def secondary_no_weakness(type)
    weakness_fake(type)
    crest_secondary_type(type)
    self
  end

  <<-DOC
  @param type - type id
  >> allows the user to receive STAB-bonuses from the given type
  DOC
  def stab_override(type)
    @stab_overrides += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> allows the user to lose the weaknesses of the given type.
  DOC
  def weakness_fake(type)
    @weakness_fakes += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> allows the user to gain the resistances of the given type. 
  DOC
  def resistance_fake(type)
    @resistance_fakes += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  @param resistance_level - the amount to resist by (4 => neutral, 2 => 2x resist, 1 => 4x resist)
  >> forces the user resist the given type(s).
  DOC
  def force_resistance(type, resistance_level=2)
    @forced_resistances[type] = resistance_level
  end

  <<-DOC
  @param proc - a void function
  >> adds a conditional stat modifier. accepts 2 arguments, the crest holder (PokeBattle_Battler), and an array of 6 NumberContainers
     corresponding to hp, atk, def, spa, spd, spe. use the NumberContainers to perform in-place modifications to stats.
  DOC
  def battle_stat_mods(proc)
    @battle_stat_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a damage multiplier
  >> adds a conditional damage multiplier. accepts 5 arguments, attacker (PokeBattle_Battler), target (PokeBattle_Battler), the move used 
     (PokeBattle_Move), the hit number (or total hit count if being used by battle AI), and whether the move is being used in a battle AI 
     calculation. should return a single numeric damage multiplier.
  DOC
  def damage_mod(proc)
    @damage_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a numeric accuracy
  >> adds a conditional accuracy modifier. accepts 5 arguments, user (PokeBattle_Battler), move used (PokeBattle_Move), base accuracy, 
     accuracy modifier, and evasion (all as numbers 0-100). return an array of 3 values corresponding to the base accuracy, modifier, and
     evasion respectively, or nil if no change.
  DOC
  def accuracy_mod(proc)
    @accuracy_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an array of two type modifiers
  >> adds a conditional type effectiveness setter. accepts 5 arguments, the attacker (PokeBattle_Battler), the target 
     (PokeBattle_Battler), the move type (Symbol), and the two current type modifiers. if not returning nil, both values in return array
     must be numeric. the type modifiers will be set to the two given values.
  DOC
  def type_effectiveness_mod(proc)
    @type_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an additive priority modifier
  >> adds a conditional damage multiplier. accepts 2 arguments, the user (PokeBattle_Battler) and the move used (PokeBattle_Move). should
     return a single numeric priority modifier.
  DOC
  def priority_mod(proc)
    @priority_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an additive hit count modifier
  >> adds a conditional hit count modifier. accepts 3 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), and the 
     move used (PokeBattle_Move). should return an additive hit number modifier.
  DOC
  def hit_count_mod(proc)
    @hit_number_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a type.
  >> adds a conditional move type override. accepts 3 arguments, the user (PokeBattle_Battler), the move (PokeBattle_Move), and the type.
     should return another type.
  DOC
  def move_type_override(proc)
    @move_type_overrides.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning one of :HP, :ATK, :DEF, :SPA, :SPD, :SPE as well as prefixed by opp (i.e. :OPPHP) for the opponent stat
                or the lowercase equivalents. can also return an integer corresponding to a stat index.
  >> adds a conditional move stat override. accepts 3 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), the move
     (PokeBattle_Move), and returns a stat symbol. invalid symbols will be ignored.
  DOC
  def move_stat_override(proc)
    @move_stat_overrides.push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon enters the field. accepts 3 arguments, the pokemon (PokeBattle_Battler), the battle 
     (PokeBattle_Battle), and the index of the pokemon entering.
  DOC
  def on_battle_entry(proc)
    @on_battle_entry_events.push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon deals damage in battle. accepts 4 arguments, the attacker (PokeBattle_Battler), the target 
     (PokeBattle_Battler), the move used (PokeBattle_Move), and the numeric damage value. return values are ignored. 
  DOC
  def on_damage_dealt(proc)
    @on_dealt_damage_events.push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon is damaged in battle. accepts 4 arguments, the attacker (PokeBattle_Battler), the target
     (PokeBattle_Battler), the move used (PokeBattle_Move), and the numeric damage value. return values are ignored. 
  DOC
  def on_damage_taken(proc)
    @on_damage_events.push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a the current turn ends. accepts a single PokeBattle_Battler argument.
  DOC
  def on_turn_end(proc)
    @on_turn_end.push(proc)
    self
  end

end