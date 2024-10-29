MULTIBILITY_HANDLERS = {}

class PokeBattle_Battler

  def ability=(other)
    @ability = other.is_a?(AbilityContainer) ? other.copy : AbilityContainer.new(self, other)
  end

end

class AbilityContainer

  attr_accessor(:ctx)

  def initialize(pkmn, ability)
    @pokemon = pkmn
    @abilities = ability.is_a?(Array) ? ability.dup : [ability]
    @ctx = ability
    MULTIBILITY_HANDLERS[pkmn.species].each do |handler|
      extra = handler.call(@pokemon, @abilities)
      @abilities += extra.is_a?(Array) ? extra : [extra]
    end unless MULTIBILITY_HANDLERS[pkmn.species].nil?
  end

  def ==(other)
    out = @abilities.include?(other)
    @ctx = other if out
    out
  end

  def copy
    AbilityContainer.new(@pokemon, @abilities)
  end

end

class Symbol

  def ===(other)
    other.is_a?(AbilityContainer) ? other == self : self == other
  end

end

replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@ability      = pkmn.ability", "@ability = AbilityContainer.new(pkmn, pkmn.ability)")

replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@backupability      = pkmn.ability", "@backupability = @ability.copy")

replace_in_method(:PokeBattle_Battler, :pbUpdate, "@ability = @pokemon.ability if !@ability.nil? && !((@crested == :SILVALLY || @crested == :ZOROARK))", proc do
  @ability = AbilityContainer.new(@pokemon, @pokemon.ability) if !@ability.nil? && !((@crested == :SILVALLY || @crested == :ZOROARK))
end)

insert_in_function(:getAbilityName, :HEAD, "abil = abil.ctx.nil? ? abil.abilities[0] : abil.ctx if abil.is_a?(AbilityContainer)")

replace_in_function(:pbShowBattleStats, "report.push(_INTL(\"Ability: {1}\",pkmn.ability.nil? ? \"Ability Negated\" : getAbilityName(shownmon.ability)))", proc do |report, pkmn, shownmon|
  if pkmn.ability == nil
    report.push(_INTL("Ability: Ability Negated"))
  elsif shownmon.ability.is_multiple?
    report.push(_INTL("Abilities:"))
    shownmon.ability.abilities.each { |ability| report.push(_INTL("- {1}", getAbilityName(ability))) }
  else
    report.push(_INTL("Ability: {1}", getAbilityName(shownmon.ability.abilities[0])))
  end
end)