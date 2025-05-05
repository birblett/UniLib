# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Helper"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  unless UniLib.lib_loaded(__FILE__)

    POKEMON_DATA = load_data("Data/mons.dat") if !defined? POKEMON_DATA or POKEMON_DATA.nil?
    STAT_INDEX = {:HP => 0, :ATK => 1, :DEF => 2, :SPA => 3, :SPD => 4, :SPE => 5}
    FORM_MAP = {}
    POKEMON_DATA.each do |species, mondata|
      mondata.forms.each do |index, form|
        FORM_MAP[species] = {} if FORM_MAP[species].nil?
        FORM_MAP[species][form] = index
        FORM_MAP[species][index] = form
      end
    end

    def self.add_type1_provider(species, form, provider)
      key = [species, form]
      CUSTOM_TYPE1_PROVIDERS[key] = [] if CUSTOM_TYPE1_PROVIDERS[key].nil?
      CUSTOM_TYPE1_PROVIDERS[key].push(provider) unless CUSTOM_TYPE1_PROVIDERS[key].include?(provider)
    end

    def self.add_type2_provider(species, form, provider)
      key = [species, form]
      CUSTOM_TYPE2_PROVIDERS[key] = [] if CUSTOM_TYPE2_PROVIDERS[key].nil?
      CUSTOM_TYPE2_PROVIDERS[key].push(provider) unless CUSTOM_TYPE2_PROVIDERS[key].include?(provider)
    end

  end

  MODIFIED_POKEMON = {}
  CUSTOM_TYPE1_PROVIDERS = {}
  CUSTOM_TYPE2_PROVIDERS = {}
  LEARN_OVERRIDES = {}
  LEARN_IGNORE_OVERRIDES = {}
  $force_refresh_abilities = false

end

class PokeModifier

  include UniLib

  EVENT_POKEMODIFIER_INIT = []
  EVENT_POKEMODIFIER_PRE_BUILD = []
  EVENT_POKEMODIFIER_POST_BUILD = []

  unless UniLib.lib_loaded(__FILE__)

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
      @stats = get_base_data(:BaseStats)
      @types = { :Type1 => get_base_data(:Type1), :Type2 => get_base_data(:Type2)}
      abil2 = get_base_data(:Abilities)[2]
      @abilities = { 0 => get_base_data(:Abilities)[0], 1 => get_base_data(:Abilities)[1], 2 => abil2.nil? ? get_base_data(:HiddenAbilities) : abil2}
      @base_learnset = get_base_data(:Moveset)
      @base_learnset = [] if @base_learnset.nil?
      @learnset = []
      @base_egg_moves = get_base_data(:EggMoves)
      @base_egg_moves = [] if @base_egg_moves.nil?
      @egg_moves = []
      @base_compatible_moves = get_base_data(:compatiblemoves)
      @base_compatible_moves = [] if @base_compatible_moves.nil?
      @compatible_moves = []
      @learnset_overwrite = false
      @eggs_overwrite = false
      @moves_overwrite = false
      @base_data = nil
      EVENT_POKEMODIFIER_INIT.each { |event| event.call(self) }
    end

    def mon_data
      if Reborn
        @base_data = $cache.pkmn[@species].pokemonData[$cache.pkmn[@species].forms[@form]] if @base_data.nil?
      else
        @base_data = @form == 0 ? $cache.pkmn[@species] : $cache.pkmn[@species].formData[$cache.pkmn[@species].forms[@form]] if @base_data.nil?
      end
      @base_data
    end

    def get_base_data(sym, default=nil)
      if Reborn
        ret = POKEMON_DATA[@species].pokemonData[@form_str].instance_variable_get(("@" + sym.to_s).to_sym) if ret.nil? rescue nil
        ret = POKEMON_DATA[@species].pokemonData[POKEMON_DATA[@species].forms[0]].instance_variable_get(("@" + sym.to_s).to_sym) if ret.nil? rescue nil
        ret = POKEMON_DATA[@species].flags[sym] if ret.nil? rescue nil
      else
        ret = POKEMON_DATA[@species].formData[@form_str][sym] if ret.nil? rescue nil
        ret = POKEMON_DATA[@species].flags[sym] if ret.nil? rescue nil
        ret = POKEMON_DATA[@species].instance_variable_get(("@" + sym.to_s).to_sym) if ret.nil? rescue nil
      end
      ret.nil? ? default : ret.dup
    end

    def get_data(sym)
      if @form == 0 || Reborn
        mon_data.instance_variable_get(("@" + sym.to_s).to_sym)
      else
        mon_data[sym].nil? ? mon_data.instance_variable_get(("@" + sym.to_s).to_sym) : mon_data[sym]
      end
    end

    def set_data(sym, data)
      @form == 0 || Reborn ? mon_data.instance_variable_set(("@" + String(sym)).to_sym, data) : mon_data[sym] = data
    end

    def set_stats_internal
      set_data(:BaseStats, @stats)
    end

    def set_abilities_internal
      @abilities.each do |index, ability|
        next if index > 2 or index < 0
        if index == 2 and @form == 0
          ha = get_data(:flags)
          ha[:HiddenAbilities] = ability
        else
          data = get_data(:Abilities)
          set_data(:Abilities, [data]) unless data.class == Array
          get_data(:Abilities)[index] = ability
        end
      end
      a = get_data(:Abilities)
      a.reject! {|ab| ab.nil? } if a.is_a?(Array)
    end

    def set_types_internal
      @types.each { |slot, type| set_data(slot, type) }
    end

    def set_level_moves_internal(sort=false)
      @learnset.sort_by!{ |a| a[0] } if sort
      @learnset.each do |move|
        add = true
        @base_learnset.each { |learned| add = false if (move <=> learned) == 0 }
        @base_learnset.push(move) if add
      end
      @learnset.clear
      @base_learnset.sort_by! { |a| a[0] } if sort
      set_data(:Moveset, @base_learnset)
    end

    def set_egg_moves_internal
      @egg_moves.each { |move| @base_egg_moves.push(move) unless @base_egg_moves.include?(move) }
      set_data(:EggMoves, @base_egg_moves)
    end

    def set_compatible_moves_internal
      @compatible_moves.each { |move| @base_compatible_moves.push(move) unless @base_compatible_moves.include?(move) }
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
      UniLib.dev_log(mon_data) if @species == :ROWLET
      set_stats_internal unless @stats.empty?
      set_types_internal unless @types.empty?
      set_abilities_internal unless @abilities.empty?
      @base_learnset = [] if @learnset_overwrite
      @base_egg_moves = [] if @eggs_overwrite
      @base_compatible_moves = [] if @moves_overwrite
      set_level_moves_internal(true) unless @learnset.empty?
      set_egg_moves_internal unless @egg_moves.empty?
      set_compatible_moves_internal unless @compatible_moves.empty?
      EVENT_POKEMODIFIER_POST_BUILD.each { |event| event.call(self) }
    end

  end

end

class PokeBattle_Pokemon

  attr_accessor(:permanent_battle_effects)

  def permanent_battle_effects
    @permanent_battle_effects = {} unless @permanent_battle_effects
    @permanent_battle_effects
  end

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

unless UniLib.lib_loaded(__FILE__)

  def is_valid_for_ability_override(pokemon)
    return false if pokemon.nil?
    return false unless UniLib::MODIFIED_POKEMON.include?(pokemon::species) and UniLib::MODIFIED_POKEMON[pokemon::species].include?(pokemon::form)
    UniLib::MODIFIED_POKEMON[pokemon::species][pokemon::form].ability_override and pokemon..include?(pokemon::ability)
  end

  def register_modified_pokemon
    UniLib::MODIFIED_POKEMON.each do |_, forms|
      forms.each do |_, builder|
        builder.build
      end
    end
    $Trainer.party.each do |pokemon|
      pokemon.bossId = nil if Rejuv
      pokemon.isbossmon = false
      pokemon.calcStats
      pokemon.permanent_battle_effects.clear if pokemon.permanent_battle_effects
      pokemon.initAbility if $force_refresh_abilities and is_valid_for_ability_override(pokemon)
    end
    $PokemonStorage.boxes.each do |box|
      box.pokemon.each do |pokemon|
        next unless pokemon
        pokemon.bossId = nil if Rejuv
        pokemon.isbossmon = false
        pokemon.calcStats
        pokemon.permanent_battle_effects.clear if pokemon.permanent_battle_effects
        pokemon.initAbility if $force_refresh_abilities and is_valid_for_ability_override(pokemon)
      end
    end
    UniLib::MODIFIED_POKEMON.clear
  end

end

UniLib.add_play_event(:register_modified_pokemon)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method(:PokeBattle_Pokemon, :type1, :HEAD,
 "providers = UniLib::CUSTOM_TYPE1_PROVIDERS[[@species, @form]]
  providers.each do |provider|
    ret = provider.call(self)
    return ret unless ret.nil?
  end unless providers.nil?")

UniLib.insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
 "providers = UniLib::CUSTOM_TYPE2_PROVIDERS[[@species, @form]]
  providers.each do |provider|
    ret = provider.call(self)
    next if ret == type1
    return ret unless ret.nil?
  end unless providers.nil?")

if Rejuv
  UniLib.insert_in_method(:PokeBattle_Battle, :pbEndOfBattle, "i.rampCrestUsed = false", "i.permanent_battle_effects = {}")
end

UniLib.insert_in_method(:PokeBattle_BattleCommon, :pbStorePokemon, :HEAD, "pokemon.permanent_battle_effects = {}; pokemon.bossId = nil if Rejuv; pokemon.isbossmon = false")