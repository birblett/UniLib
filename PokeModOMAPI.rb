# ==================================================================================================================== #
# =================================================== DEPENDENCIES =================================================== #
# ==================================================================================================================== #

verify_version(0.4, File.basename(__FILE__).gsub!(".rb", ""))

# ==================================================================================================================== #
# ==================================================== PUBLIC API ==================================================== #
# ==================================================================================================================== #

<<-DOC
@param item - an item id
@param type - a type id
>> adds an custom item-type mapping
DOC
def add_custom_plate(item, type)
  CUSTOM_PLATE_MAP[item] = type
end

<<-DOC
>> builder class for applying smogon om-style modifications to pokemon - overlaid on base PokeModifier as an extension
DOC
class PokeModifier

  <<-DOC
  >> allows the pokemon to choose almost any ability with an ability capsule, with a configurable banlist
  DOC
  def set_aaa
    @aaa = true
    self
  end

  <<-DOC
  >> allows the pokemon to choose almost any stab move when learning, with a configurable banlist
  DOC
  def set_stab
    @stab = true
    self
  end

  <<-DOC
  @param plates - single item or list of items corresponding to an arceus plate.
  >> allows specified pokemon to change their secondary type while holding a valid plate
  DOC
  def set_plates(plates)
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
  def set_camo
    @camo = true
  end

end