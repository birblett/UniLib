class AbilityContainer

  def add(ability)
    ability = [ability] unless ability.is_a? Array
    @abilities += ability
  end

  def self.add_handler(species, handler)
    MULTIBILITY_HANDLERS[species] = [] if MULTIBILITY_HANDLERS[species].nil?
    MULTIBILITY_HANDLERS[species].push(handler)
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
    AbilityContainer.add_handler(@species, handler)
  end

end