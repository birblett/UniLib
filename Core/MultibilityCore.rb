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

  def ability
    @ability = AbilityContainer.new(self, other) if @ability.is_a? Symbol
    @ability
  end

end

class AbilityContainer

  attr_accessor(:ctx)

  def initialize(pkmn, ability)
    @pokemon = pkmn.is_a?(PokeBattle_Battler) ? pkmn.pokemon : pkmn
    @abilities = ability.is_a?(Array) ? ability.dup : [ability]
    @ctx = ability
    key = [pkmn.species, pkmn.form]
    UniLib::MULTIBILITY_HANDLERS[key].each do |handler, condition|
      next if condition and !condition.call(@pokemon)
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

  def each
    @abilities.each { |a| yield(a) }
  end

  def self.multibility_case(clazz, method, case_statement, tail, ending, idx=0, idx2=0)
    s = case_statement.sub("case ", "") + ".each " + (ending == "}" ? "{" : "do") + " |ability| case ability"
    UniLib.replace_in_method(clazz, method, case_statement, s, idx)
    real_ending = ending + " if #{case_statement.sub("case ", "")}.is_a? AbilityContainer"
    ending == "}" ? UniLib.insert_in_method_before(clazz, method, tail, real_ending, idx2) : UniLib.insert_in_method(clazz, method, tail, real_ending, idx2)
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

UniLib.insert_in_method(:PokeBattle_Battler, :crestStats, :TAIL, "self.ability = @ability if @ability.is_a? Symbol")

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

AbilityContainer.multibility_case(:PokeBattle_AI, :getMoveScore, "case @opponent.ability", "contactscore*=0.8 if @opponent.species == :AEGISLASH && !checkAImoves([:KINGSSHIELD]) && (@move.pbIsPhysical?() || @battle.FE == :FAIRYTALE)", "}")

AbilityContainer.multibility_case(:PokeBattle_AI, :entraincode, "case @attacker.ability", "case @opponent.ability", "}")

AbilityContainer.multibility_case(:PokeBattle_AI, :entraincode, "case @opponent.ability", "when :SLOWSTART  then score +=50", "end")

AbilityContainer.multibility_case(:PokeBattle_AI, :moldbreakeronalaser, "case @opponent.ability", "return miniscore", "}")

AbilityContainer.multibility_case(:PokeBattle_AI, :pbTypeModNoMessages, "case opponent.ability", "when :TELEPATHY 						then return 0 if  move.basedamage>0 && opponent.index == attacker.pbPartner.index", "end")

AbilityContainer.multibility_case(:PokeBattle_AI, :getAbilityDisruptScore, "case opponent.ability", "abilityscore*=0.01", "}")

AbilityContainer.multibility_case(:PokeBattle_AI, :getSwitchInScoresParty, "case i.ability", "abilityscore+=30 if checkAImoves(PBStuff::PROTECTMOVE,aimem2) && @mondata.skill>=BESTSKILL", "end")

AbilityContainer.multibility_case(:PokeBattle_Move, :pbType, "case attacker.ability", "when :LIQUIDVOICE then type= @battle.FE==:ICY ? :ICE : :WATER if isSoundBased?", "end")

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", "when :INEXORABLE    then basemult*=1.3 if type == :DRAGON && (!opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index])", "end")

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case opponent.ability", "if attitemworks", "}")

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", "when :QUARKDRIVE then atkmult*=1.3 if (attacker.effects[:Quarkdrive][0] == PBStats::ATTACK && pbIsPhysical?(type)) || (attacker.effects[:Quarkdrive][0] == PBStats::SPATK && pbIsSpecial?(type))", "end", 1)

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", "when :SKILLLINK then atkmult*=1.2 if (@battle.FE == :COLOSSEUM && (@function == 0xC0 || @function == 0x307 || (attacker.crested == :CINCCINO && !pbIsMultiHit)))", "end", 2)

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case opponent.ability", "defmult*=0.5 if type == :FIRE && !(opponent.moldbroken)", "end", 1)

AbilityContainer.multibility_case(:PokeBattle_Battler, :pbSpeed, "case self.ability", "case @battle.FE", "}")

AbilityContainer.multibility_case(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "case self.ability", "when :NEUTRALIZINGGAS then @battle.pbDisplay(_INTL(\"{1}'s gas neutralized all other Pokémon's abilities!\",pbThis))", "end")

# ignoring "case $Trainer.party[0].ability" in PokemonEncounters$pbGenerateEncounters