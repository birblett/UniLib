# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
>> builder class for explicitly creating new items
DOC
module ItemBuilder

  <<-DOC
  @param symbol - id to register under
  @param name - item name, string
  @param desc - item description, string
  @param price - item price, number, optional
  >> creates a new item builder unless it already exists for the specified item type; otherwise overwrites existing 
     traits if specified
  DOC
  def self.add(symbol, name, desc, price=0)
    name = "Dummy Item" if name.nil?
    desc = "Dummy Description" if desc.nil?
    ItemModifier.add(symbol)
                .name(name)
                .desc(desc)
                .price(price)
  end

end

<<-DOC
>> modifier class for modifying items
DOC
class ItemModifier

  <<-DOC
  @param symbol - id to register under
  @param hash - hash with relevant item data, same format as ITEMHASH
  >> creates a new item builder unless it already exists for the specified item type; otherwise overwrites existing 
     traits if specified
  DOC
  def self.add(symbol, hash={})
    CUSTOM_ITEMS[symbol] = ItemModifier.new(symbol, hash) if CUSTOM_ITEMS[symbol].nil?
    CUSTOM_ITEMS[symbol]
  end

  <<-DOC
  @param name - item name as a string
  >> sets the name of an item.
  DOC
  def name(name)
    @data[:name] = name
    self
  end

  <<-DOC
  @param desc - item description as a string
  >> sets the description of an item.
  DOC
  def desc(desc)
    @data[:desc] = desc
    self
  end

  <<-DOC
  @param price - a numeric price
  >> sets the shop price of an item.
  DOC
  def price(price)
    @data[:price] = price
    self
  end

  <<-DOC
  >> makes an item a battle item
  DOC
  def battle_hold
    @data[:battlehold] = true
    self
  end

  <<-DOC
  >> makes an item a berry
  DOC
  def berry
    @data[:berry] = true
    self
  end

  <<-DOC
  >> makes an item a consumable held item
  DOC
  def consume_hold
    @data[:consumehold] = true
    self
  end

  <<-DOC
  >> makes an item a crest
  DOC
  def crest
    @data[:crest] = true
    self
  end

  <<-DOC
  >> makes an item a crystal
  DOC
  def crystal
    @data[:crystal] = true
    self
  end

  <<-DOC
  >> makes an item an evo item
  DOC
  def evo_item
    @data[:evoitem] = true
    self
  end

  <<-DOC
  >> makes an item a fossil
  DOC
  def fossil
    @data[:fossil] = true
    self
  end

  <<-DOC
  >> makes an item a key item
  DOC
  def key_item
    @data[:keyitem] = true
    self
  end

  <<-DOC
  >> makes an item a level up item
  DOC
  def level_up
    @data[:levelup] = true
    self
  end

  <<-DOC
  >> makes an item an overworld item
  DOC
  def overworld
    @data[:overworld] = true
    self
  end

  <<-DOC
  >> makes an item a medicinal item
  DOC
  def medicine
    @data[:medicine] = true
    self
  end

  <<-DOC
  >> makes an item have no use in battle
  DOC
  def no_use_in_battle
    @data[:noUseInBattle] = true
    self
  end

  <<-DOC
  >> makes an item have no use
  DOC
  def no_use
    @data[:noUse] = true
    self
  end

  <<-DOC
  >> makes an item a resist berry
  DOC
  def resist_berry
    @data[:resistberry] = true
    berry
  end

  <<-DOC
  >> makes an item a status item
  DOC
  def status
    @data[:status] = true
    medicine
  end

  <<-DOC
  @param move - a move id 
  >> makes an item a tm
  DOC
  def tm(move)
    @data[:tm] = move
    self
  end

  <<-DOC
  @param type_boost - a type id of the type to be boosted
  >> makes an item a type boosting item
  DOC
  def type_boost(type_boost)
    @data[:typeBoost] = type_boost
    self
  end

  <<-DOC
  >> makes an item a z crystal
  DOC
  def z_crystal
    @data[:zcrystal] = true
    crystal
  end

  <<-DOC
  @param holder - pokemon id
  @param form - form string or number
  >> allows battle items to be proc'd with this pokemon
  DOC
  def add_receiver(holder, form = 0)
    if form.class == String
      tmp = FORM_MAP[holder][form + " Form"]
      tmp = FORM_MAP[holder][form + " Forme"] if tmp.nil?
      tmp = FORM_MAP[holder][form + " Rotom"] if tmp.nil?
      tmp = FORM_MAP[holder][form] if tmp.nil?
      form = tmp
    end
    @species.push([holder, form]) unless @species.include? [holder, form]
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
  >> allows the user to receive STAB-bonuses from the given type
  DOC
  def stab_override(type)
    @has_event = true
    @stab_overrides += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> allows the user to lose the weaknesses of the given type.
  DOC
  def weakness_fake(type)
    @has_event = true
    @weakness_fakes += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> allows the user to gain the resistances of the given type. 
  DOC
  def resistance_fake(type)
    @has_event = true
    @resistance_fakes += type.is_a?(Array) ? type : [type]
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  @param resistance_level - the amount to resist by (4 => neutral, 2 => 2x resist, 1 => 4x resist)
  >> forces the user resist the given type(s).
  DOC
  def force_resistance(type, resistance_level=2)
    @has_event = true
    @forced_resistances[type] = resistance_level
  end

  <<-DOC
  @param proc - a void function
  >> adds a conditional base stat modifier. accepts 2 arguments; the holder (PokeBattle_Pokemon) and an array of 6 NumberContainers
     corresponding to hp, atk, def, spa, spd, spe. use the NumberContainers to perform in-place modifications to stats.
  DOC
  def base_stat_mods(proc)
    @has_event = true
    @base_stat_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a void function
  >> adds a conditional stat modifier. accepts 2 arguments, the holder (PokeBattle_Battler), and an array of 6 NumberContainers
     corresponding to hp, atk, def, spa, spd, spe. use the NumberContainers to perform in-place modifications to stats.
  DOC
  def battle_stat_mods(proc)
    @has_event = true
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
    @has_event = true
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
    @has_event = true
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
    @has_event = true
    @type_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an additive priority modifier
  >> adds a conditional damage multiplier. accepts 2 arguments, the user (PokeBattle_Battler) and the move used (PokeBattle_Move). should
     return a single numeric priority modifier.
  DOC
  def priority_mod(proc)
    @has_event = true
    @priority_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an additive hit count modifier
  >> adds a conditional hit count modifier. accepts 3 arguments, the user (PokeBattle_Battler), the target (PokeBattle_Battler), and the 
     move used (PokeBattle_Move). should return an additive hit number modifier.
  DOC
  def hit_count_mod(proc)
    @has_event = true
    @hit_number_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a type.
  >> adds a conditional move type override. accepts 3 arguments, the user (PokeBattle_Battler), the move (PokeBattle_Move), and the type.
     should return another type.
  DOC
  def move_type_override(proc)
    @has_event = true
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
    @has_event = true
    @move_stat_overrides.push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a pokemon enters the field. accepts 3 arguments, the pokemon (PokeBattle_Battler), the battle 
     (PokeBattle_Battle), and the index of the pokemon entering.
  DOC
  def on_battle_entry(proc)
    @has_event = true
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
    @has_event = true
    @on_damage_events.push(proc)
    self
  end

  <<-DOC
  @param proc - a void function.
  >> an event hook for when a the current turn ends. accepts a single PokeBattle_Battler argument.
  DOC
  def on_turn_end(proc)
    @has_event = true
    @on_turn_end_events.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning an ability symbol (or array of them).
  >> a conditional ability provider. accepts 2 arguments, the user (PokeBattle_Pokemon) and its current abilities (array of symbols).
     return an ability symbol or array of them; nil return values are ignored. the user will act as if it also has the returned ability(s).
  DOC
  def ability_provider(proc)
    @has_event = true
    @ability_providers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a boolean.
  >> a conditional event provider, accepts 1 argument, the user (PokeBattle_Pokemon); should return a boolean value.
  DOC
  def event_proc_condition(proc)
    @has_event = true
    @event_conditions.push(proc)
  end

end