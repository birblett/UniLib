# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module UniLib

  <<-DOC
  @param item - an item id
  @param type - a type id
  >> adds an custom item-type mapping
  DOC
  def self.add_custom_plate(item, type)
    return if UniLib.cached(UniLib::POKEMON_OM)
    CUSTOM_PLATE_MAP[item] = type
  end

end

<<-DOC
>> builder class for applying smogon om-style modifications to pokemon - overlaid on base PokeModifier as an extension
DOC
class PokeModifier

  <<-DOC
  >> allows the pokemon to choose almost any ability with an ability capsule, with a configurable banlist
  DOC
  def set_aaa
    return self if UniLib.cached(UniLib::POKEMON_OM)
    @aaa = true
    self
  end

  <<-DOC
  >> allows ability bans to be configured.
  DOC
  def self.add_bans(*args)
    CUSTOM_ABILITY_BANS.push(*args)
  end

  <<-DOC
  >> allows the pokemon to choose almost any stab move when learning, with a configurable banlist
  DOC
  def set_stab
    return self if UniLib.cached(UniLib::POKEMON_OM)
    @stab = true
    self
  end

  <<-DOC
  @param stab - varargs for multiple type symbols
  >> add additional types to get stab from.
  DOC
  def add_stab_types(*types)
    return self if UniLib.cached(UniLib::POKEMON_OM)
    @stab = true
    @stab_types += types
    self
  end

  <<-DOC
  @param plates - single item or list of items corresponding to an arceus plate.
  >> allows specified pokemon to change their secondary type while holding a valid plate
  DOC
  def set_plates(plates)
    return self if UniLib.cached(UniLib::POKEMON_OM)
    if plates == :ALL
      @plates = :ALL
    else
      if plates.is_a? Array
        @plates += plates
      else
        @plates.push(plates)
      end
    end
    self
  end

  <<-DOC
  >> makes the pokemon's types match that of its first two moves.
  DOC
  def set_camo(value = 2)
    return self if UniLib.cached(UniLib::POKEMON_OM)
    @camo = value
    self
  end

  <<-DOC
  @param letter - a-z letter
  >> allows a pokemon to learn all moves starting with the given letter via the move relearner
  DOC
  def set_alphabet(letter)
    return self if UniLib.cached(UniLib::POKEMON_OM)
    if letter.is_a? Array
      @alphabet |= letter
    else
      @alphabet |= [letter]
    end
    self
  end

  <<-DOC
  >> when set, all the pokemon's abilities will be active at once
  DOC
  def set_pokebilities(value = 2)
    return self if UniLib.cached(UniLib::POKEMON_OM)
    multibility_handler(UniLib::POKEBILITY_PROC)
    @pokebilities = value
    self
  end

end