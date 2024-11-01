# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.5, __FILE__)

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
    name = POKEMON_DATA[species].name + " Crest#{form_str.nil? ? "" : " (" + form_str + ")"}" if name.nil?
    CUSTOM_ITEMS[sym] = CrestBuilder.new(sym, { :name => name, :desc => desc }).crest.no_use.no_use_in_battle.add_receiver(species, form) if CUSTOM_ITEMS[sym].nil?
    CUSTOM_ITEMS[sym]
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