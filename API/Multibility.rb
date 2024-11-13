# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

class AbilityContainer

  def set(abilities)
    @abilities = abilities.is_a?(Array) ? abilities : [abilities]
  end

  def add(ability)
    ability = [ability] unless ability.is_a? Array
    @abilities += ability
  end

  def self.add_handler(species, handler, form=0, condition=nil)
    key = [species, form]
    UniLib::MULTIBILITY_HANDLERS[key] = [] if UniLib::MULTIBILITY_HANDLERS[key].nil?
    UniLib::MULTIBILITY_HANDLERS[key].push([handler, condition])
  end

  def abilities
    @abilities
  end

  def is_multiple?
    @abilities.length > 1
  end

end

class PokeModifier

  def multibility_handler(handler)
    AbilityContainer.add_handler(@species, handler, @form)
  end

end