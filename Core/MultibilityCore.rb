# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  MULTIBILITY_HANDLERS = {}

end

class PokeBattle_Battler

  def ability=(other)
    @ability = other.is_a?(AbilityContainer) ? other.copy : AbilityContainer.new(self, other)
  end

end

class AbilityContainer

  attr_accessor(:ctx)

  def initialize(pkmn, ability)
    @pokemon = pkmn.is_a?(PokeBattle_Battler) ? pkmn.pokemon : pkmn
    @abilities = ability.is_a?(Array) ? ability.dup : [ability]
    @ctx = ability
    key = [pkmn.species, pkmn.form]
    UniLib::MULTIBILITY_HANDLERS[key].each do |handler|
      extra = handler.call(@pokemon, @abilities)
      @abilities += (extra.is_a?(Array) ? extra : [extra]) - @abilities unless extra.nil?
    end unless UniLib::MULTIBILITY_HANDLERS[key].nil?
  end

  def ==(other)
    out = @abilities.include?(other)
    @ctx = other if out
    out
  end

  def copy
    AbilityContainer.new(@pokemon, @abilities)
  end

end unless UniLib.lib_loaded(__FILE__)

class Symbol

  alias __shadow_multibility_eq ===
  def ===(other)
    other.is_a?(AbilityContainer) ? other == self : __shadow_multibility_eq(other)
  end

end unless UniLib.lib_loaded(__FILE__)

module Ability_Cache

  def [](key)
    super key.is_a?(AbilityContainer) ? key.ctx : key
  end

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

$cache.abil.extend(Ability_Cache)

UniLib.replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@ability      = pkmn.ability", "@ability = AbilityContainer.new(pkmn, pkmn.ability)")

UniLib.replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@backupability= pkmn.ability", "@backupability = @ability.copy")

UniLib.replace_in_method(:PokeBattle_Battler, :pbUpdate, "@ability = @pokemon.ability if !@ability.nil? && !((@crested == :SILVALLY || @crested == :ZOROARK))", "@ability = AbilityContainer.new(@pokemon, @pokemon.ability) if !@ability.nil? && !((@crested == :SILVALLY || @crested == :ZOROARK))")

UniLib.insert_in_function(:getAbilityName, :HEAD, "abil = abil.ctx.nil? ? abil.abilities[0] : abil.ctx if abil.is_a? AbilityContainer")

UniLib.replace_in_function(:pbShowBattleStats, "report.push(_INTL(\"Ability: {1}\",pkmn.ability.nil? ? \"Ability Negated\" : getAbilityName(shownmon.ability)))",
  "if pkmn.ability == nil
    report.push(_INTL(\"Ability: Ability Negated\"))
  elsif shownmon.ability.is_multiple?
    report.push(_INTL(\"Abilities: \"))
    shownmon.ability.abilities.each { |ability| report.push(_INTL(\"- {1}\", getAbilityName(ability))) }
  else
    report.push(_INTL(\"Ability: {1}\", getAbilityName(shownmon.ability.abilities[0])))
  end")
