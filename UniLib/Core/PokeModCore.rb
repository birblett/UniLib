# ==================================================================================================================== #
# =================================================== DEPENDENCIES =================================================== #
# ==================================================================================================================== #

verify_version(0.3, File.basename(__FILE__).gsub!(".rb", ""))
require "Scripts/Rejuv/montext"

# ==================================================================================================================== #
# ================================================== INTERNAL/CORE =================================================== #
# ==================================================================================================================== #

TYPES = [:NORMAL, :FIGHTING, :FLYING, :GROUND, :POISON, :ROCK, :BUG, :GHOST, :STEEL, :QMARKS, :FIRE, :WATER, :GRASS,
         :ELECTRIC, :PSYCHIC, :ICE, :DRAGON, :DARK, :FAIRY]
STAT_INDEX = {:HP => 0, :ATK => 1, :DEF => 2, :SPA => 3, :SPD => 4, :SPE => 5}

FORM_MAP = {}
R_FORM_MAP = {}
MODIFIED_POKEMON = {}
CUSTOM_TYPE1_PROVIDERS = {}
CUSTOM_TYPE2_PROVIDERS = {}
LEARN_OVERRIDES = {}
LEARN_IGNORE_OVERRIDES = {}

$force_refresh_abilities = false

MONHASH.each do |species, data|
  data.keys.each_with_index do |form, index|
    FORM_MAP[species] = {} if FORM_MAP[species].nil?
    FORM_MAP[species][form] = index
    FORM_MAP[species][index] = form
  end
end

$pokemon_api_loaded = false

#noinspection RubyTooManyInstanceVariablesInspection
class PokeModifier

  EVENT_POKEMODIFIER_INIT = []
  EVENT_POKEMODIFIER_PRE_BUILD = []
  EVENT_POKEMODIFIER_POST_BUILD = []

  attr_accessor(:species)
  attr_accessor(:form)
  attr_accessor(:stats)
  attr_accessor(:types)
  attr_accessor(:abilities)
  attr_accessor(:base_learnset)
  attr_accessor(:learnset)
  attr_accessor(:base_egg_moves)
  attr_accessor(:egg_moves)
  attr_accessor(:base_compatible_moves)
  attr_accessor(:compatible_moves)
  attr_accessor(:learnset_overwrite)
  attr_accessor(:eggs_overwrite)
  attr_accessor(:moves_overwrite)

  def initialize(species, form, form_str)
    @species = species
    @form = form
    @form_str = form_str
    @stats = get_hash_data(:BaseStats)
    @types = {:Type1 => get_hash_data(:Type1), :Type2 => get_hash_data(:Type2)}
    abil2 = get_hash_data(:Abilities)[2]
    @abilities = {0 => get_hash_data(:Abilities)[0], 1 =>  get_hash_data(:Abilities)[1], 2 => abil2.nil? ? get_hash_data(:HiddenAbilities) : abil2}
    @base_learnset = get_hash_data(:Moveset)
    @base_learnset = [] if @base_learnset.nil?
    @learnset = []
    @base_egg_moves = get_hash_data(:EggMoves)
    @base_egg_moves = [] if @base_egg_moves.nil?
    @egg_moves = []
    @base_compatible_moves = get_hash_data(:compatiblemoves)
    @base_compatible_moves = [] if @base_compatible_moves.nil?
    @compatible_moves = []
    @learnset_overwrite = false
    @eggs_overwrite = false
    @moves_overwrite = false
    EVENT_POKEMODIFIER_INIT.each { |event| event.call(self) }
  end

  def mon_data
    if @form == 0
      $cache.pkmn[@species]
    else
      $cache.pkmn[@species].formData[$cache.pkmn[@species].forms[@form]]
    end
  end

  def get_hash_data(sym, default=nil)
    ret = MONHASH[@species][FORM_MAP[@species][@form]][sym] if ret.nil? rescue nil
    ret = MONHASH[@species][FORM_MAP[@species][0]][sym] if ret.nil? rescue nil
    ret.nil? ? default : ret.dup
  end

  def get_data(sym)
    if @form == 0
      mon_data.instance_variable_get(("@" + String(sym)).to_sym)
    else
      mon_data[sym].nil? ? mon_data.instance_variable_get(("@" + String(sym)).to_sym) : mon_data[sym]
    end
  end

  def set_data(sym, data)
    if @form == 0
      mon_data.instance_variable_set(("@" + String(sym)).to_sym, data)
    else
      mon_data[sym] = data
    end
  end

  def set_stats_internal(stats)
    set_data(:BaseStats, stats)
  end

  def set_abilities_internal(abilities)
    abilities.each do |index, ability|
      next if index > 2 or index < 0 or ability.nil?
      if index == 2 and @form == 0
        ha = get_data(:flags)
        (ha.nil? or ha[:HiddenAbilities].nil?) ? set_data(:HiddenAbilities, ability) : ha[:HiddenAbilities] = ability
        a = get_data(:Abilities)
        set_data(:Abilities, [a]) unless a.class == Array
        get_data(:Abilities)[2] = ability unless get_data(:Abilities)[1].nil?
        get_data(:Abilities)[1] = ability if get_data(:Abilities)[1] == get_data(:HiddenAbilities)
      else
        ha = get_data(:flags)
        if ha.nil? or ha[:HiddenAbilities].nil?
          set_data(:HiddenAbilities, ability) if index == 1 and get_data(:Abilities)[1] == get_data(:HiddenAbilities)
        else
          ha[:HiddenAbilities] = ability if index == 1 and get_data(:Abilities)[1] == ha[:HiddenAbilities]
        end
        set_data(:Abilities, [get_data(:Abilities)]) unless get_data(:Abilities).class == Array
        get_data(:Abilities)[index] = ability
      end
    end
  end

  def set_types_internal(types)
    types.each do |slot, type|
      set_data(slot, type)
    end
  end

  def set_level_moves_internal(sort=false)
    @learnset.sort_by!{ |a| a[0] }
    @learnset.each do |move|
      add = true
      @base_learnset.each do |learned|
        add = false if (move <=> learned) == 0
      end
      @base_learnset.push(move) if add
    end
    @base_learnset.sort_by!{ |a| a[0] } if sort
    set_data(:Moveset, @base_learnset)
  end

  def set_egg_moves_internal
    @egg_moves.each do |move|
      @base_egg_moves.push(move) unless @base_egg_moves.include?(move)
    end
    set_data(:EggMoves, @base_egg_moves)
  end

  def set_compatible_moves_internal
    @compatible_moves.each do |move|
      @base_compatible_moves.push(move) unless @base_compatible_moves.include?(move)
    end
    set_data(:compatiblemoves, @base_compatible_moves)
  end

  def clear_learnset_internal
    get_data(:Moveset).clear rescue nil
  end

  def clear_eggs_internal
    get_data(:EggMoves).clear rescue nil
  end

  def clear_moves_internal
    get_data(:compatiblemoves).clear rescue nil
  end

  def build
    EVENT_POKEMODIFIER_PRE_BUILD.each { |event| event.call(self) }
    set_stats_internal(@stats) unless @stats.empty?
    set_types_internal(@types) unless @types.empty?
    set_abilities_internal(@abilities) unless @abilities.empty?
    @base_learnset = [] if @learnset_overwrite
    @base_egg_moves = [] if @eggs_overwrite
    @base_compatible_moves = [] if @moves_overwrite
    set_level_moves_internal(true) unless @learnset.empty?
    set_egg_moves_internal unless @egg_moves.empty?
    set_compatible_moves_internal unless @compatible_moves.empty?
    EVENT_POKEMODIFIER_POST_BUILD.each { |event| event.call(self) }
  end
end

# ==================================================================================================================== #
# ====================================================== EVENTS ====================================================== #
# ==================================================================================================================== #

def is_valid_for_ability_override(pokemon)
  return false if pokemon.nil?
  return false unless MODIFIED_POKEMON.include?(pokemon::species) and MODIFIED_POKEMON[pokemon::species].include?(pokemon::form)
  MODIFIED_POKEMON[pokemon::species][pokemon::form].ability_override and pokemon.getAbilityList.include?(pokemon::ability)
end

def register_modified_pokemon
  MODIFIED_POKEMON.each do |_, forms|
    forms.each do |_, builder|
      builder.build
    end
  end
  $Trainer.party.each do |pokemon|
    pokemon.calcStats
    pokemon.initAbility if $force_refresh_abilities and is_valid_for_ability_override(pokemon)
  end
  $PokemonStorage.boxes.each do |box|
    box.pokemon.each do |pokemon|
      pokemon.calcStats unless pokemon.nil?
      pokemon.initAbility if $force_refresh_abilities and is_valid_for_ability_override(pokemon)
    end
  end
  MODIFIED_POKEMON.clear
end

add_play_event(:register_modified_pokemon)

insert_in_method(:PokeBattle_Pokemon, :type1, :HEAD, proc do
  provider = CUSTOM_TYPE1_PROVIDERS[@species]
  unless provider.nil?
    ret = provider.call(self)
    return ret unless ret.nil?
  end
end)

insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD, proc do
  provider = CUSTOM_TYPE2_PROVIDERS[@species]
  unless provider.nil?
    ret = provider.call(self)
    return nil if ret == type1
    return ret unless ret.nil?
  end
end)