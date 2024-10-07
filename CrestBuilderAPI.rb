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
    base_form = FORM_MAP[species][0]
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

end