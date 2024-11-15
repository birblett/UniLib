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
  >> equivalent to weakness_override + secondary_type, always active
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
  @param proc - a proc returning a symbol, or a symbol
  >> conditional proc to set the user's base primary type. accepts 1 argument, the user (PokeBattle_Pokemon); returns a type symbol.
  DOC
  def primary_type(proc=nil, &block)
    add_or_create_event(:primary_type, proc.is_a?(Symbol) ? Proc.new { |_| proc } : proc, block)
  end

  <<-DOC
  @param proc - a proc returning a symbol, or a symbol
  >> conditional proc to set the user's base secondary type. accepts 1 argument, the user (PokeBattle_Pokemon); returns a type symbol.
  DOC
  def secondary_type(proc=nil, &block)
    add_or_create_event(:secondary_type, proc.is_a?(Symbol) ? Proc.new { |_| proc } : proc, block)
  end

  <<-DOC
  @param proc - a proc returning a symbol
  >> conditional proc to set the user's type in battle. accepts 2 arguments, the user (PokeBattle_Battler) and whether the context is on
     switch-in or not; returns a type symbol.
  DOC
  def primary_type_battle(proc=nil, &block)
    add_or_create_event(:primary_type_battle, proc, block)
  end

  <<-DOC
  @param proc - a proc returning a symbol
  >> conditional proc to set the user's type in battle. accepts 2 arguments, the user (PokeBattle_Battler) and whether the context is on
     switch-in or not; returns a type symbol.
  DOC
  def secondary_type_battle(proc=nil, &block)
    add_or_create_event(:secondary_type_battle, proc, block)
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
  def type_effectiveness_mod_simple(proc=nil, &block)
    add_or_create_event(:type_effectiveness_simple, proc, block)
  end

  <<-DOC
  @param proc - a function returning an array of two type modifiers
  >> adds a conditional type effectiveness setter. accepts 5 arguments, the attacker (PokeBattle_Battler), the target 
     (PokeBattle_Battler), the move (PokeBattle_Move), and the two current type modifiers. if not nil, both values in return array
     must be numeric. the type modifiers will be set to the two given values.
  DOC
  def type_effectiveness_mod(proc=nil, &block)
    add_or_create_event(:type_effectiveness, proc, block)
  end

  <<-DOC
  @param proc - a void function
  >> adds a conditional stat modifier. accepts 2 arguments, the pokemon (PokeBattle_Battler) and an array of 6 NumberContainers
     corresponding to hp, atk, def, spa, spd, spe. use the NumberContainers to perform in-place modifications to stats.
  DOC
  def battle_stat_mods(proc=nil, &block)
    UniLib.include "NumberContainer"
    add_or_create_event(:battle_stat_calc, proc, block)
  end

  <<-DOC
  @param proc - a function returning a speed multiple
  >> adds a conditional stat modifier. accepts 1 argument, the pokemon (PokeBattle_Battler). return a float multiplier to speed based on
     current battle conditions.
  DOC
  def battle_speed_mods(proc=nil, &block)
    add_or_create_event(:battle_speed_calc, proc, block)
  end

  <<-DOC
  @param proc - a function returning a damage multiplier
  >> adds a conditional damage multiplier. accepts 5 arguments, attacker (PokeBattle_Battler), target (PokeBattle_Battler), the move used 
     (PokeBattle_Move), the hit number (or total hit count if being used by battle AI), and battle AI (PokeBattle_AI) if being used in 
     AI damage calcs. should return a single numeric damage multiplier.
  DOC
  def damage_mod(proc=nil, &block)
    add_or_create_event(:damage_mod, proc, block)
  end

  <<-DOC
  @param proc - a function returning a damage multiplier
  >> adds a conditional damage multiplier. accepts 5 arguments, the defender (PokeBattle_Battler), attacker (PokeBattle_Battler), the move 
     used (PokeBattle_Move), the hit number (or total hit count if being used by battle AI), and whether the move is being used in a battle 
     AI calculation. should return a single numeric damage multiplier.
  DOC
  def damage_taken_mod(proc=nil, &block)
    add_or_create_event(:damage_taken_mod, proc, block)
  end

  <<-DOC
  @param proc - a void
  >> adds a conditional accuracy modifier. accepts 5 arguments, user (PokeBattle_Battler), move used (PokeBattle_Move), base accuracy 
     (NumberContainer), accuracy modifier (NumberContainer), and evasion (NumberContainer). modifications performed using
     NumberContainers; return any non-falsy value for the move to always hit.
  DOC
  def accuracy_mod(proc=nil, &block)
    add_or_create_event(:accuracy_mod, proc, block)
  end

  <<-DOC
  @param proc - a function returning an additive priority modifier
  >> adds a conditional damage multiplier. accepts 2 arguments, the user (PokeBattle_Battler) and the move used (PokeBattle_Move). should
     return a single numeric priority modifier.
  DOC
  def priority_mod(proc=nil, &block)
    add_or_create_event(:move_priority, proc, block)
  end

  <<-DOC
  @param proc - a function returning an integer adder
  >> adds a conditional crit modifier. accepts 3 arguments, attacker (PokeBattle_Battler), target (PokeBattle_Pokemon), and move used 
     (PokeBattle_Move). return a critical hit modifier. final modifier is clamped to [-1, 3].
  DOC
  def crit_mod(proc=nil, &block)
    add_or_create_event(:crit_mod, proc, block)
  end

  <<-DOC
  @param proc - a function returning an additive hit count modifier
  >> adds a conditional hit count modifier. accepts 3 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), and the 
     move used (PokeBattle_Move). should return an additive hit number modifier.
  DOC
  def hit_count_mod(proc=nil, &block)
    add_or_create_event(:hit_count_mod, proc, block)
  end

  <<-DOC
  @param proc - a function returning a type.
  >> adds a conditional move type override. accepts 3 arguments, the user (PokeBattle_Battler), the move (PokeBattle_Move), and the type.
     should return a type symbol.
  DOC
  def move_type_override(proc=nil, &block)
    add_or_create_event(:move_type_override, proc, block)
  end

  <<-DOC
  @param proc - a function returning a type.
  >> adds a conditional move subtype provider. accepts 2 arguments, the user (PokeBattle_Battler) and the move (PokeBattle_Move). should 
     return a type symbol.
  DOC
  def move_subtype(proc=nil, &block)
    add_or_create_event(:move_subtype, proc, block)
  end

  <<-DOC
  @param proc - a function returning one of :HP, :ATK, :DEF, :SPA, :SPD, :SPE as well as prefixed by opp (i.e. :OPPHP) for the opponent stat
                or the lowercase equivalents. can also return an integer corresponding to a stat index.
  >> adds a conditional move stat override. accepts 3 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), the move
     (PokeBattle_Move), and returns a stat symbol. invalid symbols will be ignored.
  DOC
  def move_stat_override(proc=nil, &block)
    add_or_create_event(:move_stat_override, proc, block)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon's effects are initialized. accepts 4 arguments, the pokemon (PokeBattle_Battler), the battle 
     (PokeBattle_Battle), persistent effects (Hash), and whether the caller is the battle AI or not (boolean).
  DOC
  def on_effects_init(proc=nil, &block)
    add_or_create_event(:effects_init, proc, block)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon enters the field. accepts 3 arguments, the pokemon (PokeBattle_Battler), the battle 
     (PokeBattle_Battle), and the index of the pokemon entering.
  DOC
  def on_battle_entry(proc=nil, &block)
    add_or_create_event(:battle_entry, proc, block)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook called when a move is attempted but not yet used. accepts 2 arguments, the pokemon (PokeBattle_Battler) and the move 
     (PokeBattle_Move)
  DOC
  def on_move_attempt(proc=nil, &block)
    add_or_create_event(:try_move, proc, block)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook called before the main pbEffect call. accepts 4 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), 
     the hit number, and the move (PokeBattle_Move)
  DOC
  def move_effect(proc=nil, &block)
    add_or_create_event(:move_effect, proc, block)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook called after the main pbEffect call. accepts 4 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), 
     the hit number, and the move (PokeBattle_Move)
  DOC
  def after_move_effect(proc=nil, &block)
    add_or_create_event(:after_move_effect, proc, block)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon deals damage in battle. accepts 4 arguments, the attacker (PokeBattle_Battler), the target 
     (PokeBattle_Battler), the move used (PokeBattle_Move), and the numeric damage value. this is called even if a move fails. 
  DOC
  def on_damage_dealt(proc=nil, &block)
    add_or_create_event(:damage_dealt, proc, block)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon is damaged in battle. accepts 4 arguments, the defender (PokeBattle_Battler), the attacker
     (PokeBattle_Battler), the move used (PokeBattle_Move), and the numeric damage value.
  DOC
  def on_damage_taken(proc=nil, &block)
    add_or_create_event(:damage_taken, proc, block)
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a the current turn ends. accepts a single PokeBattle_Battler argument.
  DOC
  def on_turn_end(proc=nil, &block)
    add_or_create_event(:turn_end, proc, block)
  end

  <<-DOC
  @param proc - a function returning an integer.
  >> a conditional form provider, accepts 2 arguments, the user (PokeBattle_Pokemon) and nullable move (PokeBattle_Move); returns an integer
     corresponding to the form.
  DOC
  def form_change(proc=nil, &block)
    add_or_create_event(:form_change, proc, block)
  end

  <<-DOC
  @param proc - a function returning an integer adder.
  >> a conditional score modifier, accepts 3 arguments, the calling AI instance (PokeBattle_AI) and possible switch (PokeBattle_Pokemon).
     return an additive score modifier.
  DOC
  def switch_in_score(proc=nil, &block)
    add_or_create_event(:switch_in_score, proc, block)
  end

  <<-DOC
  @param proc - a function returning a float multiplier.
  >> a conditional score modifier, accepts 4 arguments, the calling AI instance (PokeBattle_AI), the attacker (PokeBattle_Pokemon, 
     the defender (PokeBattle_Pokemon), and the move (PokeBattle_Move); returns a move score modifier.
  DOC
  def move_score(proc=nil, &block)
    add_or_create_event(:move_score, proc, block)
  end

  <<-DOC
  @param proc - a function returning a numeric adder.
  >> a conditional score modifier, accepts 3 arguments, the calling AI instance (PokeBattle_AI), the attacker (PokeBattle_Pokemon, 
     and the defender (PokeBattle_Pokemon); returns a move score modifier (added).
  DOC
  def should_switch_score(proc=nil, &block)
    add_or_create_event(:should_switch_score, proc, block)
  end

end