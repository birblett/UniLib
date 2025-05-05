# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

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
    form = UniLib.get_form_number(species, form)[0]
    if Reborn
      name = POKEMON_DATA[species].pokemonData[POKEMON_DATA[species].forms[0]].name + " Crest#{form_str.nil? ? "" : " (" + form_str + ")"}" if name.nil?
    else
      name = POKEMON_DATA[species].name + " Crest#{form_str.nil? ? "" : " (" + form_str + ")"}" if name.nil?
    end
    CUSTOM_ITEMS[sym] = CrestBuilder.new(sym, { :name => name, :desc => desc }).crest.no_use.no_use_in_battle.add_receiver(species, form) if CUSTOM_ITEMS[sym].nil?
    CUSTOM_ITEMS[sym]
  end

  <<-DOC
  @param item - item id
  >> add an existing item as a crestbuilder. can be used to convert existing non-crests into crests or adding effects to crests.
  DOC
  def self.add_existing(item)
    CUSTOM_ITEMS[item] = CrestBuilder.new(item, {}) if CUSTOM_ITEMS[item].nil?
    CUSTOM_ITEMS[item]
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

end