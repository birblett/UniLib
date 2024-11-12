# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

class EventProvider

  <<-DOC
  >> injects a block of code after the specified target in the target move.
  DOC
  def insert_in_move(id, method, target, proc, index=0, priority=1000)
    return self if UniLib.has_valid_cache
    clazz = ("PokeBattle_Move_" + id.to_s).to_sym
    UniLib::PENDING_INSERTIONS.push([clazz, method, target, proc, index, false, priority])
    self
  end

  <<-DOC
  >> injects a block of code before the specified target in the target move.
  DOC
  def insert_in_move_before(id, method, target, proc, index=0, priority=1000)
    return self if UniLib.has_valid_cache
    clazz = ("PokeBattle_Move_" + id.to_s).to_sym
    UniLib::PENDING_INSERTIONS.push([clazz, method, target, proc, index, true, priority])
    self
  end

  <<-DOC
  >> replaces a target line in the target move. 
  DOC
  def replace_in_move(id, method, target, proc, index=0, priority=1000)
    return self if UniLib.has_valid_cache
    clazz = ("PokeBattle_Move_" + id.to_s).to_sym
    insert_in_move_before(id, method, target, proc, index, priority)
    UniLib.delete_in_method(clazz, method, target, index, priority)
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> equivalent to weakness_override + secondary_type
  DOC
  def secondary_no_weakness(type)
    weakness_fake(type)
    secondary_type(type)
    self
  end

  <<-DOC
  @param type - type id, or array of type ids
  >> gives user STAB and resistances of the given type(s)
  DOC
  def type_fake(type)
    stab_override(type)
    resistance_fake(type)
  end

  <<-DOC
  @param type - type id
  >> sets the user's primary type.
  DOC
  def primary_type(type)
    @event_hash[:primary_type] = type
    self
  end

  <<-DOC
  @param type - type id
  >> sets the user's secondary type.
  DOC
  def secondary_type(type)
    @event_hash[:secondary_type] = type
    self
  end

  <<-DOC
  @param proc - a proc returning a symbol
  >> conditional proc to set the user's type in battle. accepts 2 arguments, the user (PokeBattle_Battler) and whether the context is on
     switch-in or not; returns a type symbol.
  DOC
  def primary_type_battle(proc)
    @event_hash[:primary_type_battle] = [] unless @event_hash[:primary_type_battle]
    @event_hash[:primary_type_battle].push(proc)
    self
  end

  <<-DOC
  @param proc - a proc returning a symbol
  >> conditional proc to set the user's type in battle. accepts 2 arguments, the user (PokeBattle_Battler) and whether the context is on
     switch-in or not; returns a type symbol.
  DOC
  def secondary_type_battle(proc)
    @event_hash[:secondary_type_battle] = [] unless @event_hash[:secondary_type_battle]
    @event_hash[:secondary_type_battle].push(proc)
    self
  end

  <<-DOC
  @param type - type id
  >> allows the user to receive STAB-bonuses from the given type.
  DOC
  def stab_override(type)
    @event_hash[:stab_type] = [] unless @event_hash[:stab_type]
    @event_hash[:stab_type] += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  @param resistance_level - the amount to resist by (4 => neutral, 2 => 2x resist, 1 => 4x resist)
  >> forces the user resist the given type(s).
  DOC
  def force_resistance(type, resistance_level=2)
    @event_hash[:forced_resistance] = {} unless @event_hash[:forced_resistance]
    @event_hash[:forced_resistance][type] = resistance_level
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> allows the user to lose the weaknesses of the given type.
  DOC
  def weakness_fake(type)
    @event_hash[:fake_reduce_weakness] = [] unless @event_hash[:fake_reduce_weakness]
    @event_hash[:fake_reduce_weakness] += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> allows the user to gain the resistances of the given type. 
  DOC
  def resistance_fake(type)
    @event_hash[:fake_resistance] = [] unless @event_hash[:fake_resistance]
    @event_hash[:fake_resistance] += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param proc - a function returning a numeric multiplier
  >> adds a conditional type effectiveness provider. accepts 3 arguments, defender (PokeBattle_Battler), attack type (symbol), and whether
     messages should be sent in the current context (boolean).
  DOC
  def type_effectiveness_mod_simple(proc)
    @event_hash[:type_effectiveness_simple] = [] unless @event_hash[:type_effectiveness_simple]
    @event_hash[:type_effectiveness_simple].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an array of two type modifiers
  >> adds a conditional type effectiveness setter. accepts 5 arguments, the attacker (PokeBattle_Battler), the target 
     (PokeBattle_Battler), the move (PokeBattle_Move), and the two current type modifiers. if not nil, both values in return array
     must be numeric. the type modifiers will be set to the two given values.
  DOC
  def type_effectiveness_mod(proc)
    @event_hash[:type_effectiveness] = [] unless @event_hash[:type_effectiveness]
    @event_hash[:type_effectiveness].push(proc)
    self
  end

  <<-DOC
  @param proc - a void function
  >> adds a conditional stat modifier. accepts 2 arguments, the pokemon (PokeBattle_Battler) and an array of 6 NumberContainers
     corresponding to hp, atk, def, spa, spd, spe. use the NumberContainers to perform in-place modifications to stats.
  DOC
  def battle_stat_mods(proc)
    UniLib.include "NumberContainer"
    @event_hash[:battle_stat_calc] = [] unless @event_hash[:battle_stat_calc]
    @event_hash[:battle_stat_calc].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a damage multiplier
  >> adds a conditional damage multiplier. accepts 5 arguments, attacker (PokeBattle_Battler), target (PokeBattle_Battler), the move used 
     (PokeBattle_Move), the hit number (or total hit count if being used by battle AI), and whether the move is being used in a battle AI 
     calculation. should return a single numeric damage multiplier.
  DOC
  def damage_mod(proc)
    @event_hash[:damage_mod] = [] unless @event_hash[:damage_mod]
    @event_hash[:damage_mod].push(proc)
    self
  end

  <<-DOC
  @param proc - a void
  >> adds a conditional accuracy modifier. accepts 5 arguments, user (PokeBattle_Battler), move used (PokeBattle_Move), base accuracy 
     (NumberContainer), accuracy modifier (NumberContainer), and evasion (NumberContainer). modifications performed using
     NumberContainers; return any non-falsy value for the move to always hit.
  DOC
  def accuracy_mod(proc)
    @event_hash[:accuracy_mod] = [] unless @event_hash[:accuracy_mod]
    @event_hash[:accuracy_mod].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an additive priority modifier
  >> adds a conditional damage multiplier. accepts 2 arguments, the user (PokeBattle_Battler) and the move used (PokeBattle_Move). should
     return a single numeric priority modifier.
  DOC
  def priority_mod(proc)
    @event_hash[:move_priority] = [] unless @event_hash[:move_priority]
    @event_hash[:move_priority].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an integer adder
  >> adds a conditional crit modifier. accepts 3 arguments, attacker (PokeBattle_Battler), target (PokeBattle_Pokemon), and move used 
     (PokeBattle_Move). return a critical hit modifier. final modifier is clamped to [-1, 3].
  DOC
  def crit_mod(proc)
    @event_hash[:crit_mod] = [] unless @event_hash[:crit_mod]
    @event_hash[:crit_mod].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an additive hit count modifier
  >> adds a conditional hit count modifier. accepts 3 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), and the 
     move used (PokeBattle_Move). should return an additive hit number modifier.
  DOC
  def hit_count_mod(proc)
    @event_hash[:hit_count_mod] = [] unless @event_hash[:hit_count_mod]
    @event_hash[:hit_count_mod].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a type.
  >> adds a conditional move type override. accepts 3 arguments, the user (PokeBattle_Battler), the move (PokeBattle_Move), and the type.
     should return another type.
  DOC
  def move_type_override(proc)
    @event_hash[:move_type_override] = [] unless @event_hash[:move_type_override]
    @event_hash[:move_type_override].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning one of :HP, :ATK, :DEF, :SPA, :SPD, :SPE as well as prefixed by opp (i.e. :OPPHP) for the opponent stat
                or the lowercase equivalents. can also return an integer corresponding to a stat index.
  >> adds a conditional move stat override. accepts 3 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), the move
     (PokeBattle_Move), and returns a stat symbol. invalid symbols will be ignored.
  DOC
  def move_stat_override(proc)
    @event_hash[:move_stat_override] = [] unless @event_hash[:move_stat_override]
    @event_hash[:move_stat_override].push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon enters the field. accepts 4 arguments, the pokemon (PokeBattle_Battler), the battle 
     (PokeBattle_Battle), persistent effects (Hash), and whether the caller is the battle AI or not (boolean).
  DOC
  def on_effects_init(proc)
    @event_hash[:effects_init] = [] unless @event_hash[:effects_init]
    @event_hash[:effects_init].push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon enters the field. accepts 3 arguments, the pokemon (PokeBattle_Battler), the battle 
     (PokeBattle_Battle), and the index of the pokemon entering.
  DOC
  def on_battle_entry(proc)
    @event_hash[:battle_entry] = [] unless @event_hash[:battle_entry]
    @event_hash[:battle_entry].push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook called when a move is attempted but not yet used. accepts 2 arguments, the pokemon (PokeBattle_Battler) and the move 
     (PokeBattle_Move)
  DOC
  def on_move_attempt(proc)
    @event_hash[:try_move] = [] unless @event_hash[:try_move]
    @event_hash[:try_move].push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook called when a effect is applied. accepts 4 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), the
     hit number, and the move (PokeBattle_Move)
  DOC
  def move_effect(proc)
    @event_hash[:move_effect] = [] unless @event_hash[:move_effect]
    @event_hash[:move_effect].push(proc)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook called after a move effect is applied. accepts 4 arguments, the user (PokeBattle_Battler), the target 
     (PokeBattle_Battler), the hit number, and the move (PokeBattle_Move)
  DOC
  def after_move_effect(proc)
    @event_hash[:after_move_effect] = [] unless @event_hash[:after_move_effect]
    @event_hash[:after_move_effect].push(proc)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon deals damage in battle. accepts 4 arguments, the attacker (PokeBattle_Battler), the target 
     (PokeBattle_Battler), the move used (PokeBattle_Move), and the numeric damage value. this is called even if a move fails. 
  DOC
  def on_damage_dealt(proc)
    @event_hash[:damage_dealt] = [] unless @event_hash[:damage_dealt]
    @event_hash[:damage_dealt].push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon is damaged in battle. accepts 4 arguments, the attacker (PokeBattle_Battler), the target
     (PokeBattle_Battler), the move used (PokeBattle_Move), and the numeric damage value.
  DOC
  def on_damage_taken(proc)
    @event_hash[:damage_taken] = [] unless @event_hash[:damage_taken]
    @event_hash[:damage_taken].push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a the current turn ends. accepts a single PokeBattle_Battler argument.
  DOC
  def on_turn_end(proc)
    @event_hash[:turn_end] = [] unless @event_hash[:turn_end]
    @event_hash[:turn_end].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an integer.
  >> a conditional form provider, accepts 2 arguments, the user (PokeBattle_Pokemon) and nullable move (PokeBattle_Move); returns an integer
     corresponding to the form.
  DOC
  def form_change(proc)
    @event_hash[:form_change] = [] unless @event_hash[:form_change]
    @event_hash[:form_change].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an integer adder.
  >> a conditional form provider, accepts 3 arguments, the calling AI instance (PokeBattle_AI), the calling pokemon (PokeBattle_Pokemon) and 
     weather effect (Symbol); returns an added weather score modifier corresponding to the ability - see PokeBattle_AI$getSwitchInScoresParty
  DOC
  def weather_score(proc)
    @event_hash[:weather_score] = [] unless @event_hash[:weather_score]
    @event_hash[:weather_score].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an integer adder.
  >> a conditional form provider, accepts 3 arguments, the calling AI instance (PokeBattle_AI), the calling pokemon (PokeBattle_Pokemon) and 
     field effect (Symbol); returns an added field score modifier corresponding to the ability - see PokeBattle_AI$getSwitchInScoresParty
  DOC
  def field_score(proc)
    @event_hash[:field_score] = [] unless @event_hash[:field_score]
    @event_hash[:field_score].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a float multiplier.
  >> a conditional form provider, accepts 4 arguments, the calling AI instance (PokeBattle_AI), the attacker (PokeBattle_Pokemon, 
     the defender (PokeBattle_Pokemon), and the move (PokeBattle_Move); returns a move score modifier.
  DOC
  def move_score(proc)
    @event_hash[:move_score] = [] unless @event_hash[:move_score]
    @event_hash[:move_score].push(proc)
  end

end