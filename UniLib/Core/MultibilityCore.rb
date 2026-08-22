# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  MULTIBILITY_HANDLERS = {} unless UniLib.cached(UniLib::MULTIBILITY)

end

class PokeBattle_Battler

  def ability=(other)
    @ability = other.is_a?(AbilityContainer) ? other.copy : AbilityContainer.new(self, other, [], true)
  end

  def ability
    @ability = AbilityContainer.new(self, nil) if @ability.nil?
    @ability = AbilityContainer.new(self, @ability) unless @ability.is_a? AbilityContainer
    @ability
  end

end

class AbilityContainer

  attr_accessor(:ctx)
  attr_accessor(:added_abilities)

  def initialize(pkmn, ability, added_abilities=[], ignore=false)
    @pokemon = pkmn.is_a?(PokeBattle_Battler) ? pkmn.pokemon : pkmn
    if ability.is_a?(AbilityContainer)
      @abilities, @added_abilities = ability.abilities | ability.added_abilities, ability.added_abilities
    else
      @abilities = (ability.is_a?(Array) ? ability : [ability]) | added_abilities
      @added_abilities = added_abilities
    end
    @ctx = ability
    key = [pkmn.species, pkmn.form]
    UniLib::MULTIBILITY_HANDLERS[key].each do |handler, condition|
      next if condition and !condition.call(pkmn)
      extra = handler.call(pkmn, @abilities)
      @abilities |= (extra.is_a?(Array) ? extra : [extra]) unless extra.nil?
    end unless UniLib::MULTIBILITY_HANDLERS[key].nil? or ignore
  end

  def ==(other)
    return false if !other.nil? and @abilities.include?(nil)
    out = @abilities.include?(other)
    @ctx = other if out
    out
  end

  def +(other)
    other = other.is_a?(Array) ? other : [other]
    AbilityContainer.new(@pokemon, @abilities + other, @added_abilities + other)
  end

  def copy
    AbilityContainer.new(@pokemon, @abilities, @added_abilities)
  end

  def each
    return if @abilities == nil or !@abilities.is_a? Array
    @abilities.each { |a| yield(a) }
  end

  def capitalize
    @ctx ? @ctx.capitalize : @abilities[0].capitalize
  end

  def multiple?
    @abilities ? @abilities.length > 1 : @abilities
  end

  def suppressed?
    (@abilities ? @abilities[0] : @abilities).nil?
  end

  def handle_trace(new)
    if (i = @abilities.index(:TRACE))
      @abilities.delete_at(i)
      if new.is_a? Symbol
        @abilities.insert(i, new)
      else
        new.abilities.reverse.each { |abil| @abilities.insert(i, abil) }
      end
    end
  end

  def self.multibility_case(clazz, method, case_statement, tail, ending, idx=0, idx2=0, before=false)
    s = case_statement.sub("case ", "") + ".each " + (ending == "}" ? "{" : "do") + " |abill| case abill"
    UniLib.replace_in_method(clazz, method, case_statement, s, idx)
    target = "#{case_statement.sub("case ", "")}"
    real_ending = ending + " if #{target}.is_a? AbilityContainer and !#{target}.nil?"
    ending == "}" || before ? UniLib.insert_in_method_before(clazz, method, tail, real_ending, idx2) : UniLib.insert_in_method(clazz, method, tail, real_ending, idx2)
  end

  def to_s
    "#{@abilities} + #{@added_abilities} / last checked: #{@ctx.nil? ? "none" : (@ctx.is_a?(AbilityContainer) ?  @ctx.abilities : @ctx)}"
  end

end unless UniLib.lib_loaded(__FILE__)

class Symbol

  alias __shadow_multibility_eq ===
  def ===(other)
    other.is_a?(AbilityContainer) ? other == self : __shadow_multibility_eq(other)
  end

end unless UniLib.lib_loaded(__FILE__)

class Array

  ARR_INC = Array.instance_method(:include?) unless defined? ARR_INC
  def include?(other)
    if other.is_a?(AbilityContainer)
      other.abilities.each { |ability| (other.ctx = ability; return true) if ARR_INC.bind(self).call(ability) }
      return false
    end
    ARR_INC.bind(self).call(other)
  end

end

module Ability_Cache

  def [](key)
    super key.is_a?(AbilityContainer) ? key.ctx : key
  end

end

class PokeBattle_Pokemon

  def ability(multi=false)
    is_called = !caller[0]["pbGenerateEncounter"].nil? || !caller[0]["pbGenerateWildPokemon"].nil?
    if multi or is_called
      AbilityContainer.new(self, @ability)
    else
      @ability
    end
  end

end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #


class Cache_Game

  def cacheAbilities
    if Reborn && Gen >= 9
      compileAbilitiesGen9(@directory) if !fileExists?(@directory + "/abil_modern.dat")
      @abil = load_data(@directory + "/abil_modern.dat")
    else
      compileAbilities(@directory) if !fileExists?(@directory + "/abil.dat")
      @abil = load_data(@directory + "/abil.dat")
    end
    @abil.extend(Ability_Cache)
  end

end

UniLib.insert_in_method(:PokeBattle_Battler, :crestStats, :TAIL, "self.ability = @ability if @ability.is_a? Symbol") if Rejuv

UniLib.replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@ability      = pkmn.ability", "@ability = AbilityContainer.new(pkmn, pkmn.ability, @ability.added_abilities)")

UniLib.replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@backupability = pkmn.ability", "@backupability = @ability.copy")

UniLib.insert_in_method_before(:PokeBattle_Battler, :changeAbility, :HEAD,
  "newAbility = AbilityContainer.new(@pokemon, newability) unless newability.nil?")

UniLib.insert_in_function(:getAbilityName, :HEAD, "
  if abil.is_a? AbilityContainer
    return \"abilities\" if abil.multiple?
    abil = abil.ctx.nil? ? abil.abilities[0] : abil.ctx
  end")

UniLib.replace_in_function(:pbShowBattleStats, "report.push(_INTL(\"Ability: {1}\", pkmn.ability.nil? ? \"Ability Negated\" : getAbilityName(pkmn.ability)))",
  "if pkmn.ability == nil
    report.push(_INTL(\"Ability: Ability Negated\"))
  elsif shownmon.ability.is_multiple?
    report.push(_INTL(\"Abilities: \"))
    shownmon.ability.abilities.each { |ability| report.push(_INTL(\"- {1}\", getAbilityName(ability))) }
  else
    report.push(_INTL(\"Ability: {1}\", getAbilityName(pkmn.ability.abilities[0])))
  end")

# getMoveScore

AbilityContainer.multibility_case(:PokeBattle_AI, :getMoveScore, "case @opponent.ability", "contactscore *= mummyscore", "end")

# entraincode

AbilityContainer.multibility_case(:PokeBattle_AI, :entraincode, "case @attacker.ability", "when :SPEEDBOOST  then score += 25", "end")

AbilityContainer.multibility_case(:PokeBattle_AI, :entraincode, "case @opponent.ability", "when :SLOWSTART  then score += 50", "end")

# electricterraincode

AbilityContainer.multibility_case(:PokeBattle_AI, :electricterraincode, "case @attacker.pbPartner.ability", "when :QUARKDRIVE  then miniscore *= dynamicspeedcode(:ProtoDrivePartner, 1.5) if @attacker.pbPartner.effects[:Quarkdrive] == 0 && @attacker.pbPartner.getHighestStatWithStages == PBStats::SPEED", "end")

# pbTypeModNoMessages

AbilityContainer.multibility_case(:PokeBattle_AI, :pbTypeModNoMessages, "case opponent.ability", "when :GOODASGOLD then return Typemod.zero if move.pbIsStatus? && attacker != opponent", "end")

# getAbilityDisruptScore

AbilityContainer.multibility_case(:PokeBattle_AI, :getAbilityDisruptScore, "case opponent.ability", "abilityscore *= 0.01", "}")

# getSwitchInScoresParty

AbilityContainer.multibility_case(:PokeBattle_AI, :getSwitchInScoresParty, "case i.ability", "if [:IRONBARBS, :ROUGHSKIN].include?(i.ability) || i.item == :ROCKYHELMET", "}")

AbilityContainer.multibility_case(:PokeBattle_AI, :getSwitchInScoresParty, "case i.ability", "if [:IRONBARBS, :ROUGHSKIN].include?(i.ability) || i.item == :ROCKYHELMET", "}", 1, 1)

AbilityContainer.multibility_case(:PokeBattle_AI, :getSwitchInScoresParty, "case i.ability", "if transformed", "end", 2, 0, true)

# pbStatChangingSwitchOpponent

AbilityContainer.multibility_case(:PokeBattle_AI, :pbStatChangingSwitchOpponent, "case opponent.ability", "else opponent.stages[stat] -= 1", "end")

AbilityContainer.multibility_case(:PokeBattle_AI, :pbStatChangingSwitchOpponent, "case opponent.ability", "when :COMPETITIVE then opponent.stages[PBStats::SPATK] += 2", "end", 1)

# pbRoughDamage

AbilityContainer.multibility_case(:PokeBattle_AI, :pbRoughDamage, "case attacker.ability", "when :SUPREMEOVERLORD then basemult.append(1 + 0.1 * attacker.effects[:SupremeOverlord])", "end")

AbilityContainer.multibility_case(:PokeBattle_AI, :pbRoughDamage, "case opponent.ability", "when :DRYSKIN     then basemult.append(1.25) if type == :FIRE", "end")

AbilityContainer.multibility_case(:PokeBattle_AI, :pbRoughDamage, "case attacker.ability", "when :PURIFYINGSALT then atkmult.append(1.5) if @battle.FE == :HOLY", "end", 1)

AbilityContainer.multibility_case(:PokeBattle_AI, :pbRoughDamage, "case opponent.ability", "when :ICESCALES then defmult.append(2.0) if move.pbIsSpecial?(attacker, type)", "end", 1)

AbilityContainer.multibility_case(:PokeBattle_Move, :pbAbilityMoveTypeChange, "case ability", "return field == :ICY ? :ICE : :WATER if $cache.moves[move]&.checkFlag?(:soundmove)", "end")

# pbCalcDamage

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", "when :SUPREMEOVERLORD then basemult.append(1 + 0.1 * attacker.effects[:SupremeOverlord])", "end")

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case opponent.ability", "when :DRYSKIN     then basemult.append(1.25) if type == :FIRE", "end")

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case opponent.ability", "when :ICESCALES then defmult.append(2.0) if pbIsSpecial?(attacker, type)", "end", 1)

# pbAbilitiesOnSwitchIn

AbilityContainer.multibility_case(:PokeBattle_Battler, Rejuv ? :__blessings_onSwitchIn : :pbAbilitiesOnSwitchIn, "case self.ability", "when :VESSELOFRUIN then @battle.pbAbilityBoxAndDisplay(self, _INTL(\"{1}'s {2} weakened the {3} of all surrounding Pokémon!\", pbThis, getAbilityName(self.ability), getStatName(PBStats::SPATK)))", "end")

AbilityContainer.multibility_case(:PokeBattle_Battler, Rejuv ? :__blessings_onSwitchIn : :pbAbilitiesOnSwitchIn, "case self.ability", "when :EMBODYASPECTCORNERSTONE then stat, mask = PBStats::DEFENSE, :CORNERSTONEMASK", "end", 1)

# disableAbility

AbilityContainer.multibility_case(:PokeBattle_Battler, :disableAbility, "case ability", "priority.each { |pkmn| pkmn.pbBerryHerbCheck if self.pbIsOpposing?(pkmn.index) }", "end")

# pbGenerateEncounter

AbilityContainer.multibility_case(:PokemonEncounters, :pbGenerateEncounter, "case user.ability", "encount *= 2.0 / 3 if [:CLEANSETAG, :PUREINCENSE].include?(user.item)", "end")