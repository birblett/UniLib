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
class CrestBuilder < ItemBuilder

  <<-DOC
  @param species - base species id for the crest
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
    if CUSTOM_ITEMS[sym].nil? or !CUSTOM_ITEMS[sym].is_a? CrestBuilder
      CUSTOM_ITEMS[sym] = CrestBuilder.new(species, form, {
        :name => name.nil? ? (POKEMON_DATA[species].name + " Crest#{form_str.nil? ? "" : " (" + form_str + ")"}") : name,
        :desc => desc,
        :crest => true
      }).no_use.no_use_in_battle
    else
      CUSTOM_ITEMS[sym].data[:desc] = CUSTOM_ITEMS[sym].data[:desc] + desc
    end
    CUSTOM_ITEMS[sym]
  end

  <<-DOC
  @param species - pokemon species id (or list of)
  >> registers another user of the given crest
  DOC
  def add_receiver(species)
    if species.is_a? Array
      species.each { |specie| @species.push(specie) unless @species.include? specie }
    else
      @species.push(species) unless @species.include? species
    end
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
    resistance_override(type)
  end

  <<-DOC
  @param type - type id
  >> allows the user to receive STAB-bonuses from the given type
  DOC
  def stab_override(type)
    @stab_override = type
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> allows the user to no longer be weak to the given type. if an array of types is given, uses those as resistances instead.
  DOC
  def weakness_override(type)
    @weakness_override = type
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> allows the user to gain the resistances of the given type. if an array of types is given, uses those as resistances instead.
  DOC
  def resistance_override(type)
    @resistance_override = type
    self
  end

  <<-DOC
  @param type - type id (or array of type ids)
  >> forces the user resist the given type(s).
  DOC
  def force_resistance(type)
    @force_resistance = type
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
  @param proc - a function returning a base stat array.
  >> adds a conditional base stat modifier. accepts 2 arguments; the crest holder (PokeBattle_Pokemon) and a 6-number stat array
     corresponding to the pokemon's current stats in the order hp, atk, def, spa, spd, spe. in-place modifications not recommended - should 
     return a modified stat array.
  DOC
  def base_stat_mods(proc)
    @base_stat_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a hash of stat modifiers
  >> adds a conditional stat modifier. accepts 1 argument, the crest holder (PokeBattle_Battler). should return a dictionary with symbolic 
     keys corresponding to numeric stat boosts; the keys are :atk, :def, :spa, :spd, :acc, :eva, and :spe.
  DOC
  def battle_stat_boosts(proc)
    @battle_stat_modifiers.push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a damage multiplier
  >> adds a conditional damage multiplier. accepts 4 arguments, user (PokeBattle_Battler), the move used (PokeBattle_Move), the hit number, 
     and whether the move is being used in a battle AI calculation. should return a single numeric damage multiplier.
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