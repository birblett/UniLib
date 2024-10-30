# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
>> builder class for creating new crests.
DOC
class CrestBuilder

  <<-DOC
  @param species - base species id for the crest
  @param form - the form number or name, optional
  @param desc - crest description
  >> creates a new crest builder unless an existing item exists that is already a crest corresponding to :SPECIES_CREST
  DOC
  def self.add(species, desc, form=0, name=nil)
    sym = (species.to_s + "CREST").to_sym
    form_str = nil
    if form.class == String
      tmp = FORM_MAP[species][(form_str = form + " Form")]
      tmp = FORM_MAP[species][(form_str = form + " Forme")] if tmp.nil?
      tmp = FORM_MAP[species][(form_str = form + " Rotom")] if tmp.nil?
      tmp = FORM_MAP[species][(form_str = form)] if tmp.nil?
      form = tmp
    end
    CUSTOM_ITEMS[sym] = ItemBuilder.add(sym, {
      :name => name.nil? ? (POKEMON_DATA[species].name + " Crest#{form_str.nil? ? "" : " (" + form_str + ")"}") : name,
      :desc => desc,
      :crest => true
    }).no_use.no_use_in_battle if CUSTOM_ITEMS[sym].nil?
    CUSTOM_CRESTS[sym] = CrestBuilder.new(sym, species, form) if CUSTOM_CRESTS[sym].nil?
    CUSTOM_CRESTS[sym]
  end


  <<-DOC
  @param item - crest item
  @param species - base species id for the crest
  @param form - the form number or name, optional
  >> attaches a crestbuilder instance to an existing item; can be used to modify existing crests or to attach special effects to non-crest
     items.
  DOC
  def self.add_existing(item, species, form=0)
    if form.class == String
      tmp = FORM_MAP[species][form + " Form"]
      tmp = FORM_MAP[species][form + " Forme"] if tmp.nil?
      tmp = FORM_MAP[species][form + " Rotom"] if tmp.nil?
      tmp = FORM_MAP[species][form] if tmp.nil?
      form = tmp
    end
    CUSTOM_CRESTS[item] = CrestBuilder.new(item, species, form) if CUSTOM_CRESTS[item].nil?
    CUSTOM_CRESTS[item]
  end

  <<-DOC
  @param species - pokemon species id
  @form form - a form number or name.
  >> registers another user of the given crest
  DOC
  def add_receiver(species, form=0)
    if form.class == String
      tmp = FORM_MAP[species][form + " Form"]
      tmp = FORM_MAP[species][form + " Forme"] if tmp.nil?
      tmp = FORM_MAP[species][form + " Rotom"] if tmp.nil?
      tmp = FORM_MAP[species][form] if tmp.nil?
      form = tmp
    end
    @species.push([species, form]) unless @species.include? [species, form]
    self
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
  @param tier - tier at which the crest begins appearing. must be 1-4.
  @param price - price, in red essence, of the crest
  >> adds the crest to cairo's shop, at the specified tier and price
  DOC
  def cairo(tier, price)
    @tier = tier
    @essence = price
    self
  end

  <<-DOC
  @param proc - a void function
  >> adds a conditional base stat modifier. accepts 2 arguments; the crest holder (PokeBattle_Pokemon) and an array of 6 NumberContainers
     corresponding to hp, atk, def, spa, spd, spe. use the NumberContainers to perform in-place modifications to stats.
  DOC
  def base_stat_mods(proc)
    @base_stat_modifiers.push(proc)
    self
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

class NumberContainer

  def set(other)
    @number = other
  end

  def +(other)
    @number + other
  end

  def -(other)
    @number - other
  end

  def *(other)
    @number * other
  end

  def /(other)
    @number / other
  end

  def add(other)
    @number += other
  end

  def sub(other)
    @number -= other
  end

  def mul(other)
    @number *= other
  end

  def div(other)
    @number /= other
  end

  def ==(other)
    @number == other
  end

  def >=(other)
    @number >= other
  end

  def <=(other)
    @number <= other
  end

  def >(other)
    @number > other
  end

  def <(other)
    @number < other
  end

  def value
    @number
  end

end