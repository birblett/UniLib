# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

class PokeBuilder

  include UniLib

  <<-DOC
  @param species - pokemon symbolic constant (i.e. :NINETALES)
  @param form - a form, in string or integer representation (i.e. "Alolan", "Mega") - default 0
  @param force - if true, replaces the existing entry if it exists - default false
  >> returns an existing pokemodifier entry, or creates one if it doesn't exist
  DOC
  def self.add(species, name, target_dex_num, form_str = "Normal Form")
    MODIFIED_POKEMON[species] ||= {}
    p = MODIFIED_POKEMON[species][0] = PokeModifier.new(species, 0, form_str)
    p.set_new(name, target_dex_num)
    FORM_MAP[species] ||= {}
    FORM_MAP[species][form_str] = 0
    FORM_MAP[species][0] = form_str
    p
  end

end

<<-DOC
>> class for modifying pokemon
DOC
#noinspection RubyTooManyInstanceVariablesInspection
class PokeModifier

  <<-DOC
  @param species - pokemon symbolic constant (i.e. :NINETALES)
  @param form - a form, in string or integer representation (i.e. "Alolan", "Mega") - default 0
  @param force - if true, replaces the existing entry if it exists - default false
  >> returns an existing pokemodifier entry, or creates one if it doesn't exist
  DOC
  def self.add(species, form=0, force=false)
    initial_form = form
    if POKEMON_DATA[species].nil?
      Kernel.pbMessage("Failed to register PokeModifer for species #{species}#{initial_form != 0 ? " with form #{initial_form}." : ""}")
      exit
    end
    form, form_str = UniLib.get_form_number(species, form)
    if form.nil?
      Kernel.pbMessage("Failed to register PokeModifer for species #{species}#{initial_form != 0 ? " with form #{initial_form}." : ""}")
      exit
    end
    MODIFIED_POKEMON[species] = {} if MODIFIED_POKEMON[species].nil?
    MODIFIED_POKEMON[species][form] = PokeModifier.new(species, form, form_str) if MODIFIED_POKEMON[species][form].nil? or force
    MODIFIED_POKEMON[species][form]
  end

  <<-DOC
  @param species - pokemon symbolic constant (i.e. :NINETALES)
  @param form_str - a form, in string representation (i.e. "Alolan", "Mega")
  DOC
  def self.add_form(species, form_str)
    form = UniLib.add_form(species, form_str)
    MODIFIED_POKEMON[species] = {} if MODIFIED_POKEMON[species].nil?
    MODIFIED_POKEMON[species][form] = PokeModifier.new(species, form, form_str) if MODIFIED_POKEMON[species][form].nil?
    MODIFIED_POKEMON[species][form]
  end

  <<-DOC
  @param stone - stone item id
  @param form_str - a form in string representation only
  DOC
  def add_mega(stone, form_str)
    return self if UniLib.cached(POKEMON)
    @megas[stone] = form_str
    self
  end

  <<-DOC
  @param types - type input in the form of a hash, with :Type1/:Type2 as indices (i.e. {:Type1 => PBTypes::FIRE, 
                 :Type2 => PBTypes::WATER})
  >> overwrites existing typings
  DOC
  def types(types)
    return self if UniLib.cached(POKEMON)
    @types = types
    self
  end

  <<-DOC
  @param type - numerical type id or PBTypes constant (i.e. PBTypes::FIRE)
  >> sets primary type
  DOC
  def type1(type)
    return self if UniLib.cached(POKEMON)
    @types[:Type1] = type
    self
  end

  <<-DOC
  @param type - numerical type id or PBTypes constant (i.e. PBTypes::FIRE)
  >> sets secondary type
  DOC
  def type2(type)
    return self if UniLib.cached(POKEMON)
    @types[:Type2] = type
    self
  end

  <<-DOC
  @param hp - hp stat, or a 6-number array
  @param atk - attack stat
  @param defe - defense stat
  @param spa - special attack stat
  @param spd - special defense stat
  @param spe - speed stat
  >> overwrites a pokemon's existing stats with the provided stats
  DOC
  def stats(hp = 0, attack = 0, defense = 0, spa = 0, spd = 0, spe = 0)
    return self if UniLib.cached(POKEMON)
    @stats = get_base_data(:BaseStats) unless @stats
    stats = hp.is_a?(Array) ? hp : [hp, attack, defense, spa, spd, spe]
    if stats.length != 6
      print("PokeModifer for species #{@species} of form #{@form} failed: stat array requires length 6, got #{stats.length}")
      exit
    end
    stats.each_with_index { |stat, i| @stats[i] = stat unless stat.nil? or stat == 0 }
    self
  end

  <<-DOC
  @param index - index/name of stat to be overwritten - :HP/:ATK/:DEF/:SPA/:SPD/:SPE as well as numbers 0-5 are valid
  @param value - new value for base stat
  >> overwrites an existing stat for a pokemon
  DOC
  def stat(index, value)
    return self if UniLib.cached(POKEMON)
    @stats = get_base_data(:BaseStats) unless @stats
    if index.class == Symbol
      @stats[STAT_INDEX[index]] = value
    else
      @stats[index] = value
    end
    self
  end

  <<-DOC
  @param index1 @param index2 - indices/names of stats to be swapped - :HP/:ATK/:DEF/:SPA/:SPD/:SPE as well as numbers 0-5 are valid
  >> swaps the values of two stats - respects previously changed stats
  DOC
  def swap(stat1, stat2)
    return self if UniLib.cached(POKEMON)
    @stats = get_base_data(:BaseStats) unless @stats
    i1 = stat1.class == Symbol ? STAT_INDEX[stat1] : stat1
    i2 = stat2.class == Symbol ? STAT_INDEX[stat2] : stat2
    @stats[i1], @stats[i2] = @stats[i2], @stats[i1]
    self
  end

  <<-DOC
  @param proc - a conditional Proc with one PokeBattle_Pokemon argument
  >> sets a custom primary type based on a condition. proc should return nil if no changes are required.
  DOC
  def type1_provider(proc)
    return self if UniLib.cached(POKEMON)
    UniLib.add_type1_provider(@species, @form, proc)
  end

  <<-DOC
  @param proc - a conditional Proc with one PokeBattle_Pokemon argument
  >> sets a custom secondary type based on a condition. proc should return nil if no changes are required.
  DOC
  def type2_provider(proc)
    return self if UniLib.cached(POKEMON)
    UniLib.add_type2_provider(@species, @form, proc)
  end

  <<-DOC
  @param abilities - ability input in the form of a hash, with keys as indices 0-2 (i.e. {1 => :STENCH, 2 => :ILLUMINATE}. index 2 will 
                     always replace the hidden ability.)
  >> replaces the abilities at the provided indices
  DOC
  def abilities(abilities)
    return self if UniLib.cached(POKEMON)
    abilities.each { |slot, ability| @abilities[slot] = ability}
    self
  end

  <<-DOC
  @param slot - index of the ability slot
  @param ability - ability input as a symbol
  >> replaces the ability at the target index
  DOC
  def ability(slot, ability)
    return self if UniLib.cached(POKEMON)
    @abilities[slot] = ability
    self
  end

  <<-DOC
  @param moves - move id, or array of them.
  >> removes moves from the learnset. applies before level-up moves are added.
  DOC
  def remove_level_moves(moves)
    return self if UniLib.cached(POKEMON)
    if moves.class == Array
      @removed_learnset += moves
    else
      @removed_learnset.push(moves)
    end
    self
  end

  <<-DOC
  @param moves - tuple with a level and move id (or array of them) (i.e. [[50, :SUNSTEELSTRIKE], [60, :MOONGEISTBEAM])
  >> adds level-up moves at the given levels
  DOC
  def level_moves(moves, override=true)
    return self if UniLib.cached(POKEMON)
    if moves[0].class == Array
      @learnset += moves
      moves.each { |move| @compatible_moves.push(move[1]) if override }
    else
      @learnset.push(moves)
      @compatible_moves.push(moves[1]) if override
    end
    self
  end

  <<-DOC
  @param moves - move id, or array of them.
  >> removes moves from the egg and compatible movesets. applies before egg moves and compatible moves are added.
  DOC
  def remove_compatible_moves(moves)
    return self if UniLib.cached(POKEMON)
    if moves.class == Array
      @removed_compatible += moves
    else
      @removed_compatible.push(moves)
    end
    self
  end

  <<-DOC
  @param moves - move constant (or array of them) (i.e. [:SUNSTEELSTRIKE, :MOONGEISTBEAM])
  >> adds the given egg moves
  DOC
  def egg_moves(moves, override=true)
    return self if UniLib.cached(POKEMON)
    if moves.class == Array
      @egg_moves += moves
      @compatible_moves += moves if override
    else
      @egg_moves.push(moves)
      @compatible_moves.push(moves) if override
    end
    self
  end

  <<-DOC
  @param moves - move constant (or array of them) (i.e. [:SUNSTEELSTRIKE, :MOONGEISTBEAM])
  >> allows the given moves to be learned via tm or tutor
  DOC
  def compatible_moves(moves)
    return self if UniLib.cached(POKEMON)
    if moves.class == Array
      @compatible_moves += moves
    else
      @compatible_moves.push(moves)
    end
    self
  end

  <<-DOC
  >> indicates that the learnset should be entirely replaced
  DOC
  def level_moves_overwrite(overwrite=true)
    return self if UniLib.cached(POKEMON)
    @learnset_overwrite = overwrite
    self
  end

  <<-DOC
  >> indicates that egg moves should be entirely replaced
  DOC
  def egg_moves_overwrite(overwrite=true)
    return self if UniLib.cached(POKEMON)
    @eggs_overwrite = overwrite
    self
  end

  <<-DOC
  >> indicates that compatible moves should be entirely replaced
  DOC
  def compatible_moves_overwrite(overwrite=true)
    return self if UniLib.cached(POKEMON)
    @moves_overwrite = overwrite
    self
  end

  # ========== SIMPLE SETTERS ========== #

  <<-DOC
  >> string, name
  DOC
  def set_name(val)
    return self if UniLib.cached(POKEMON)
    @name = val
    self
  end

  <<-DOC
  >> array, ev gain
  DOC
  def set_ev(val)
    return self if UniLib.cached(POKEMON)
    @ev = val
    self
  end

  <<-DOC
  >> symbol, exp gain rate
  DOC
  def set_growth_rate(val)
    return self if UniLib.cached(POKEMON)
    @growth_rate = val
    self
  end

  <<-DOC
  >> symbol, one of several fixed gender ratios
  DOC
  def set_gender_ratio(val)
    return self if UniLib.cached(POKEMON)
    @gender_ratio = val
    self
  end

  <<-DOC
  >> int, base exp amount granted on ko
  DOC
  def set_base_exp(val)
    return self if UniLib.cached(POKEMON)
    @base_exp = val
    self
  end

  <<-DOC
  >> int, 0-255 catchrate
  DOC
  def set_catch_rate(val)
    return self if UniLib.cached(POKEMON)
    @catch_rate = val
    self
  end

  <<-DOC
  >> int, in-battle y-offset (player)
  DOC
  def set_happiness(val)
    return self if UniLib.cached(POKEMON)
    @happiness = val
    self
  end

  <<-DOC
  >> int, number of steps before eggs hatch
  DOC
  def set_egg_steps(val)
    return self if UniLib.cached(POKEMON)
    @egg_steps = val
    self
  end

  <<-DOC
  >> string, color (mainly for dex purposes)
  DOC
  def set_color(val)
    return self if UniLib.cached(POKEMON)
    @color = val
    self
  end

  <<-DOC
  >> string, idk what this is for lol
  DOC
  def set_habitat(val)
    return self if UniLib.cached(POKEMON)
    @habitat = val
    self
  end

  <<-DOC
  >> array, overrides existing egg groups
  DOC
  def set_egg_groups(val)
    return self if UniLib.cached(POKEMON)
    @egg_groups = val
    self
  end

  <<-DOC
  >> int, height in meters * 10
  DOC
  def set_height(val)
    return self if UniLib.cached(POKEMON)
    @height = val
    self
  end

  <<-DOC
  >> double, weight in kg
  DOC
  def set_weight(val)
    return self if UniLib.cached(POKEMON)
    @weight = val
    self
  end

  <<-DOC
  >> string, pokemon type i.e. butterfree, the *Butterfly* pokemon
  DOC
  def set_kind(val)
    return self if UniLib.cached(POKEMON)
    @kind = val
    self
  end

  <<-DOC
  >> string, dex entry
  DOC
  def set_dex_entry(val)
    return self if UniLib.cached(POKEMON)
    @dex_entry = val
    self
  end

  <<-DOC
  >> int, in-battle y-offset (player)
  DOC
  def set_battler_player_y(val)
    return self if UniLib.cached(POKEMON)
    @battler_player_y = val
    self
  end

  <<-DOC
  >> int, in-battle y-offset (opponent)
  DOC
  def set_battler_enemy_y(val)
    return self if UniLib.cached(POKEMON)
    @battler_enemy_y = val
    self
  end

  <<-DOC
  >> int, battle altitude (opponents only)
  DOC
  def set_battler_altitude(val)
    return self if UniLib.cached(POKEMON)
    @battler_altitude = val
    self
  end

  <<-DOC
  >> battler shadow display
  DOC
  def set_battler_shadow(val)
    return self if UniLib.cached(POKEMON)
    @battler_shadow = val
    self
  end

  <<-DOC
  >> hash with :species and :form set, overrides existing data
  DOC
  def set_preevo(val)
    return self if UniLib.cached(POKEMON)
    @preevo = val
    self
  end

  <<-DOC
  >> hash, uses reborn 19.5 montext format, overrides existing data
  DOC
  def add_evolution(val)
    return self if UniLib.cached(POKEMON)
    val = [val[:species], val[:method], val[:parameters]] if Rejuv
    (@evolutions ||= get_base_data(:evolutions, [])).push(val)
    self
  end

  <<-DOC
  >> array, uses reborn 19.5 montext format, overrides existing data
  DOC
  def set_evolutions(val)
    return self if UniLib.cached(POKEMON)
    if Rejuv
      temp = {}
      val.each { |v| temp.push([v[:species], v[:method], v[:parameters]]) }
      val = temp
    end
    @evolutions = val
    self
  end

  # ======== END SIMPLE SETTERS ======== #

  <<-DOC
  >> proc/block, accepts 2 arguments: pokemon (PokeBattle_Pokemon), and item (symbol). returns a form if form should be overridden.
  DOC
  def add_evo_override(proc = nil, &block)
    return self if UniLib.cached(POKEMON)
    (@evo_overrides ||= []).push(block ? block : proc)
    self
  end

  <<-DOC
  >> sets a map encounter form override by map id
  DOC
  def encounter_form_override(map_id, form)
    return self if UniLib.cached(POKEMON)
    (@form_overrides ||= {})[map_id] = form
    self
  end

  <<-DOC
  >> if enabled, the current form will always be set to the specified number at the end of a battle
  DOC
  def end_of_battle_reset(form)
    return self if UniLib.cached(POKEMON)
    @end_of_battle_reset = form
    self
  end

  <<-DOC
  @param asset - string representing a path relative to the Mods folder
  >> overrides the existing asset with the given one
  DOC
  def asset_override(asset: nil, asset_f: nil, asset_egg: nil, asset_egg_f: nil, icon: nil, icon_f: nil, icon_egg: nil, icon_egg_f: nil, cry: nil, form: nil)
    UniLib.include "Asset"
    Assets.redirect_pkmn_detailed(@species, form ? form : @form, asset, asset_f, asset_egg, asset_egg_f)
    Assets.redirect_pkmn_icon(@species, form ? form : @form, icon, icon_f, icon_egg, icon_egg_f)
    Assets.redirect_pkmn_cry(@species, form ? form : @form, cry) unless cry.nil?
    self
  end

  <<-DOC
  >> returns the form number
  DOC
  def get_form
    @form
  end

end

class PokeBattle_Battler

  <<-DOC
  >> apply a persistently tracked effect, similar to rampardos crest
  DOC
  def set_permanent_effect(symbol, value)
    self.pokemon.permanent_battle_effects[symbol] = value
  end

  <<-DOC
  >> get the current value of a permanent effect
  DOC
  def permanent_effect(symbol)
    self.pokemon.permanent_battle_effects[symbol]
  end

end