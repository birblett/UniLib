# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
forcibly refreshes abilities on load. ability capsules will be overridden if replacing an existing ability.
DOC
def force_refresh_abilities
  $force_refresh_abilities = true
end

<<-DOC
>> builder class for modifying pokemon
DOC
#noinspection RubyTooManyInstanceVariablesInspection
class PokeModifier
  <<-DOC
  @param species - pokemon symbolic constant (i.e. :NINETALES)
  @param form - a form, in string representation (i.e. "Alolan", "Mega") - default 0
  @param force - if true, replaces the existing entry if it exists - default false
  >> returns an existing pokemodifier entry, or creates one if it doesn't exist
  DOC
  def self.add(species, form=0, force=false)
    initial_form = form
    form_str = nil
    if form.class == String
      tmp = FORM_MAP[species][(form_str = form + " Form")]
      tmp = FORM_MAP[species][(form_str = form + " Forme")] if tmp.nil?
      tmp = FORM_MAP[species][(form_str = form + " Rotom")] if tmp.nil?
      tmp = FORM_MAP[species][(form_str = form)] if tmp.nil?
      form = tmp
    end
    if form.nil?
      Kernel.pbMessage("Failed to register PokeModifer for species #{species}#{initial_form != 0 ? " with form #{initial_form}." : ""}")
      exit
    end
    MODIFIED_POKEMON[species] = {} if MODIFIED_POKEMON[species].nil?
    MODIFIED_POKEMON[species][form] = PokeModifier.new(species, form, form_str) if MODIFIED_POKEMON[species][form].nil? or force
    MODIFIED_POKEMON[species][form]
  end

  <<-DOC
  @param stats - stat input in the form of a 6-number array, in the form [hp, atk, def, spa, spd, spe]
  >> overwrites a pokemon's existing stats with the provided array
  DOC
  def stats(stats)
    @stats = stats
    self
  end

  <<-DOC
  @param index - index/name of stat to be overwritten - :HP/:ATK/:DEF/:SPA/:SPD/:SPE as well as numbers 0-5 are valid
  @param value - new value for base stat
  >> overwrites an existing stat for a pokemon
  DOC
  def stat(index, value)
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
    i1 = stat1.class == Symbol ? STAT_INDEX[stat1] : stat1
    i2 = stat2.class == Symbol ? STAT_INDEX[stat2] : stat2
    @stats[i1], @stats[i2] = @stats[i2], @stats[i1]
    self
  end

  <<-DOC
  @param types - type input in the form of a hash, with :Type1/:Type2 as indices (i.e. {:Type1 => PBTypes::FIRE, 
                 :Type2 => PBTypes::WATER})
  >> overwrites existing typings
  DOC
  def types(types)
    @types = types
    self
  end

  <<-DOC
  @param type - numerical type id or PBTypes constant (i.e. PBTypes::FIRE)
  >> sets primary type
  DOC
  def type1(type)
    @types[:Type1] = type
    self
  end

  <<-DOC
  @param type - numerical type id or PBTypes constant (i.e. PBTypes::FIRE)
  >> sets secondary type
  DOC
  def type2(type)
    @types[:Type2] = type
    self
  end

  <<-DOC
  @param proc - a conditional Proc with one PokeBattle_Pokemon argument
  >> sets a custom primary type based on a condition. proc should return nil if no changes are required.
  DOC
  def type1_provider(proc)
    CUSTOM_TYPE1_PROVIDERS[@species] = proc
  end

  <<-DOC
  @param proc - a conditional Proc with one PokeBattle_Pokemon argument
  >> sets a custom secondary type based on a condition. proc should return nil if no changes are required.
  DOC
  def type2_provider(proc)
    CUSTOM_TYPE2_PROVIDERS[@species] = proc
  end

  <<-DOC
  @param abilities - ability input in the form of a hash, with keys as indices 0-2 (i.e. {1 => :STENCH, 2 => :ILLUMINATE}. index 2 will 
                     always replace the hidden ability.)
  >> replaces the abilities at the provided indices
  DOC
  def abilities(abilities)
    abilities.each { |slot, ability| @abilities[slot] = ability}
    self
  end

  <<-DOC
  @param moves - tuple with a level and move id (or array of them) (i.e. [[50, :SUNSTEELSTRIKE], [60, :MOONGEISTBEAM])
  >> adds level-up moves at the given levels
  DOC
  def level_moves(moves, override=true)
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
  @param moves - move constant (or array of them) (i.e. [:SUNSTEELSTRIKE, :MOONGEISTBEAM])
  >> adds the given egg moves
  DOC
  def egg_moves(moves, override=true)
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
    @learnset_overwrite = overwrite
    self
  end

  <<-DOC
  >> indicates that egg moves should be entirely replaced
  DOC
  def egg_moves_overwrite(overwrite=true)
    @eggs_overwrite = overwrite
    self
  end

  <<-DOC
  >> indicates that compatible moves should be entirely replaced
  DOC
  def compatible_moves_overwrite(overwrite=true)
    @moves_overwrite = overwrite
    self
  end

  <<-DOC
  >> if enabled, the selected species will not be affected by the ability override - for overriding modules only
  DOC
  def ability_override
    true
  end

end