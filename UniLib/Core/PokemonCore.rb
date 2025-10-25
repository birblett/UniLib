# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  unless UniLib.lib_loaded(__FILE__)

    POKEMON_DATA = load_data("Data/mons.dat") if !defined? POKEMON_DATA or POKEMON_DATA.nil?
    STAT_INDEX = {:HP => 0, :ATK => 1, :DEF => 2, :SPA => 3, :SPD => 4, :SPE => 5}
    HIDDEN_ABILITY_SYM = Reborn ? :HiddenAbility : :HiddenAbilities

    def self.get_form_number(holder, form)
      return [form, FORM_MAP[holder][form]] if form.is_a? Integer
      form_str = nil
      if form.is_a? String
        tmp = FORM_MAP[holder][form_str = form + " Form"]
        tmp = FORM_MAP[holder][form_str = form + " Forme"] if tmp.nil?
        tmp = FORM_MAP[holder][form_str = form + " Rotom"] if tmp.nil?
        tmp = FORM_MAP[holder][form_str = form + " Mode"] if tmp.nil?
        tmp = FORM_MAP[holder][form_str = form] if tmp.nil?
        form_str = form if tmp.nil?
        form = tmp
      end
      [form, form_str]
    end

    def self.add_form(species, form_str)
      if FORM_MAP[species][form_str]
        p $cache.pkmn[species] if species == :BASCULEGION
        $cache.pkmn[species].forms[FORM_MAP[species].keys.index(form_str) / 2] = form_str
        p $cache.pkmn[species] if species == :BASCULEGION
        return FORM_MAP[species][form_str]
      end
      form = FORM_MAP[species].keys.max_by { |k| k.is_a?(Numeric) ? k : -1 } + 1
      FORM_MAP[species][form] = form_str
      FORM_MAP[species][form_str] = form
      $cache.pkmn[species].pokemonData[$cache.pkmn[species].forms[form] = form_str] = MonData.new(species, {})
      form
    end

    def self.form_by(holder, form_str) = FORM_MAP[holder][form_str] rescue 0

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

  unless UniLib.cached(UniLib::POKEMON)

    MODIFIED_POKEMON = {}
    CUSTOM_TYPE1_PROVIDERS = {}
    CUSTOM_TYPE2_PROVIDERS = {}
    END_OF_BATTLE_RESET = {}
    EVO_OVERRIDES = {}

    FORM_MAP = {}
    POKEMON_DATA.each do |species, mondata|
      mondata.forms.each do |index, form|
        FORM_MAP[species] = {} if FORM_MAP[species].nil?
        FORM_MAP[species][form] = index
        FORM_MAP[species][index] = form
      end
    end

  end

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
    attr_accessor(:end_of_battle_reset)
    attr_accessor(:target_dex_num)

    def initialize(species, form, form_str)
      return self if UniLib.cached(POKEMON)
      @species = species
      @form = form
      @form_str = form_str
      @stats = []
      @types = {}
      @abilities = {}
      @removed_learnset = []
      @base_learnset = []
      @learnset = []
      @removed_compatible = []
      @base_egg_moves = []
      @egg_moves = []
      @base_compatible_moves = []
      @compatible_moves = []
      @megas = {}
      @learnset_overwrite = false
      @eggs_overwrite = false
      @moves_overwrite = false
      @base_data = nil
      @end_of_battle_reset = nil
      @target_dex_num = -1
      EVENT_POKEMODIFIER_INIT.each { |event| event.call(self) }
    end

    def set_new(name, target_dex_num)
      @new_flag = true
      @target_dex_num = target_dex_num
      @name = name
      @learnset_overwrite = @eggs_overwrite = @moves_overwrite = true
      @ev = [0, 0, 0, 0, 0, 0]
      @gender_ratio = :FemHalf
      @happiness = 70
      @egg_steps = 1
      @egg_groups = [:Undiscovered]
      $cache.pkmn[@species] = MonWrapper.new(@species, { 0 => {} })
    end

    def set_form
      @form_flag = true
    end

    def mon_data
      if Reborn
        @base_data = $cache.pkmn[@species].pokemonData[$cache.pkmn[@species].forms[@form]] if @base_data.nil?
      else
        @base_data = @form == 0 ? $cache.pkmn[@species] : $cache.pkmn[@species].formData[$cache.pkmn[@species].forms[@form]] if @base_data.nil?
      end
      @base_data = MonData.new(@species, {}) if @base_data.nil?
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

    def get_data(sym, default = nil)
      begin
        if @form == 0 || Reborn
          data = mon_data.instance_variable_get(("@" + sym.to_s).to_sym)
          data = $cache.pkmn[@species].pokemonData[POKEMON_DATA[@species].forms[0]].instance_variable_get(("@" + sym.to_s).to_sym) if data.nil? and Reborn
          data
        else
          mon_data[sym].nil? ? mon_data.instance_variable_get(("@" + sym.to_s).to_sym) : mon_data[sym]
        end
      rescue
        default
      end
    end

    def get_form_data(sym)
      if Reborn
        mon_data.instance_variable_get(("@" + sym.to_s).to_sym)
      else
        mon_data[sym]
      end
    end

    def set_data(sym, data)
      @form == 0 || Reborn ? mon_data.instance_variable_set(("@" + String(sym)).to_sym, data) : mon_data[sym] = data
    end

    def set_megas_internal
      megas = get_data(:MegaEvolutions, [])
      megas = megas.nil? ? {} : megas.dup
      @megas.each { |k, v| megas[k] = v }
      set_data(:MegaEvolutions, @megas)
    end

    def set_stats_internal
      base_stats = get_data(:BaseStats, [100, 100, 100, 100, 100, 100]).dup
      @stats.each_with_index { |s, i| base_stats[i] = s if s }
      set_data(:BaseStats, base_stats)
    end

    def set_abilities_internal
      @abilities.each do |index, ability|
        next if index > 2 or index < 0
        if Reborn
          if index == 2
            set_data(HIDDEN_ABILITY_SYM, ability)
          else
            (abils = get_data(:Abilities, []).dup)[index] = ability
            set_data(:Abilities, abils)
          end
        else
          if index == 2 and @form == 0
            ha = get_data(:flags, {})
            ha[HIDDEN_ABILITY_SYM] = ability
          else
            data = get_data(:Abilities, []).dup
            data[index] = ability
            set_data(:Abilities, data)
          end
        end
      end
      a = get_data(:Abilities, [])
      a.reject! {|ab| ab.nil? } if a.is_a?(Array)
    end

    def set_types_internal
      @types.each { |slot, type| set_data(slot, type) }
    end

    def set_level_moves_internal(sort=false)
      @base_learnset += get_base_data(:Moveset, []) unless @learnset_overwrite
      @base_learnset.reject! { |a| @removed_learnset.include?(a[1]) }
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
      d = get_base_data(:EggMoves, []) unless @eggs_overwrite
      @base_egg_moves += d if d
      @base_egg_moves.reject! { |a| @removed_compatible.include?(a) }
      @egg_moves.each { |move| @base_egg_moves.push(move) unless @base_egg_moves.include?(move) }
      set_data(:EggMoves, @base_egg_moves)
    end

    def set_compatible_moves_internal
      @base_compatible_moves += get_base_data(:compatiblemoves, []) unless @moves_overwrite
      @compatible_moves.reject! { |a| @removed_compatible.include?(a) }
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

    def new_pkmn_error(set) = print("PokeModifier: #{set} must be set for new Pokemon #{@species}")

    def build
      if @new_flag
        return new_pkmn_error("name") unless @name
        return new_pkmn_error("dex entry") unless @dex_entry
        return new_pkmn_error("base stats") if @stats.empty?
        return new_pkmn_error("types") if @types.empty?
        return new_pkmn_error("abilities") if @abilities.empty?
        return new_pkmn_error("growth rate") unless @growth_rate
        return new_pkmn_error("base EXP") unless @base_exp
        return new_pkmn_error("catch rate") unless @catch_rate
        return new_pkmn_error("color") unless @color
        return new_pkmn_error("height") unless @height
        return new_pkmn_error("weight") unless @weight
        return new_pkmn_error("kind") unless @kind
      end
      EVENT_POKEMODIFIER_PRE_BUILD.each { |event| event.call(self) }
      set_megas_internal unless @megas.empty?
      set_stats_internal unless @stats.empty?
      set_types_internal unless @types.empty?
      set_abilities_internal unless @abilities.empty?
      @base_learnset = [] if @learnset_overwrite
      @base_egg_moves = [] if @eggs_overwrite
      @base_compatible_moves = [] if @moves_overwrite
      set_level_moves_internal(true) unless @learnset.empty? and @removed_learnset.empty?
      set_egg_moves_internal unless @egg_moves.empty? and @removed_compatible.empty?
      set_compatible_moves_internal unless @compatible_moves.empty? and @removed_compatible.empty?
      set_data(:name, @name) if @name
      set_data(:dexnum, @target_dex_num) if @target_dex_num >= 0
      set_data(:EVs, @ev) if @ev
      set_data(:GrowthRate, @growth_rate) if @growth_rate
      set_data(:GenderRatio, @gender_ratio) if @gender_ratio
      set_data(:BaseEXP, @base_exp) if @base_exp
      set_data(:CatchRate, @catch_rate) if @catch_rate
      set_data(:Happiness, @happiness) if @happiness
      set_data(:EggSteps, @egg_steps) if @egg_steps
      set_data(:Color, @color) if @color
      set_data(:Habitat, @habitat) if @habitat
      set_data(:EggGroups, @egg_groups) if @egg_groups
      set_data(:Height, @height) if @height
      set_data(:Weight, @weight) if @weight
      set_data(:kind, @kind) if @kind
      set_data(:dexentry, @dex_entry) if @dex_entry
      set_data(:BattlerPlayerY, @battler_player_y) if @battler_player_y
      set_data(:BattlerEnemyY, @battler_enemy_y) if @battler_enemy_y
      set_data(:BattlerAltitude, @battler_altitude) if @battler_altitude
      set_data(:BattlerShadow, @battler_shadow) if @battler_shadow
      set_data(:preevo, @preevo) if @preevo
      set_data(:evolutions, @evolutions) if @evolutions
      EVO_OVERRIDES[[@species, @form]] = @evo_overrides if @evo_overrides
      FORM_PROVIDERS[@species] = @form_overrides if @form_overrides
      END_OF_BATTLE_RESET[[@species, @form]] = @end_of_battle_reset if @end_of_battle_reset
      EVENT_POKEMODIFIER_POST_BUILD.each { |event| event.call(self) }
    end

  end

end

class PokeBattle_Battler

  def unilib_flags = @pokemon.unilib_flags

end

class PokeBattle_Pokemon

  attr_accessor(:permanent_battle_effects)

  def unilib_flags = @unilib_flags ||= {}

  def permanent_battle_effects
    @permanent_battle_effects = {} unless @permanent_battle_effects
    @permanent_battle_effects
  end

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def register_pokemon
  keys = UniLib::MODIFIED_POKEMON.keys.sort_by!.with_index { |k, idx, m = UniLib::MODIFIED_POKEMON[k]| [m[m.keys[0]].target_dex_num, idx] }
  keys.each { |k| UniLib::MODIFIED_POKEMON[k].each { |_, builder| builder.build } }
end

def pokemon_datafixer
  $Trainer.party.each do |pokemon|
    pokemon.bossId = nil if Rejuv
    pokemon.isbossmon = false
    pokemon.calcStats
    pokemon.permanent_battle_effects.clear if pokemon.permanent_battle_effects
  end
  $PokemonStorage.boxes.each do |box|
    box.pokemon.each do |pokemon|
      next unless pokemon
      pokemon.bossId = nil if Rejuv
      pokemon.isbossmon = false
      pokemon.calcStats
      pokemon.permanent_battle_effects.clear if pokemon.permanent_battle_effects
    end
  end
end

UniLib.add_init_event(:register_pokemon)
UniLib.add_play_event(:pokemon_datafixer)

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

UniLib.insert_in_function(:getEvolutionForm, :HEAD,
  "UniLib::EVO_OVERRIDES[[mon.species, mon.form]].each { |override, m = nil| return m if (m = override.call(mon, item)) } if UniLib::EVO_OVERRIDES[[mon.species, mon.form]]")

target = Reborn ? "if Rejuv" : "i.rampCrestUsed = false"
index = Reborn ? 2 : 0
UniLib.insert_in_method_before(:PokeBattle_Battle, :pbEndOfBattle, target,
  "i.permanent_battle_effects = {}
  k = [i.species, i.form]
  i.form = UniLib::END_OF_BATTLE_RESET[k] if UniLib::END_OF_BATTLE_RESET[k]", index)

UniLib.insert_in_method(:PokeBattle_BattleCommon, :pbStorePokemon, :HEAD, "pokemon.permanent_battle_effects = {}; pokemon.bossId = nil if Rejuv; pokemon.isbossmon = false")