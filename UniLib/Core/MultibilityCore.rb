# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  MULTIBILITY_HANDLERS = {}

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
    @abilities = (ability.is_a?(Array) ? ability : [ability]) | added_abilities
    @added_abilities = added_abilities
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

  def self.multibility_case(clazz, method, case_statement, tail, ending, idx=0, idx2=0)
    s = case_statement.sub("case ", "") + ".each " + (ending == "}" ? "{" : "do") + " |ability| case ability"
    UniLib.replace_in_method(clazz, method, case_statement, s, idx)
    target = "#{case_statement.sub("case ", "")}"
    real_ending = ending + " if #{target}.is_a? AbilityContainer and !#{target}.nil?"
    ending == "}" ? UniLib.insert_in_method_before(clazz, method, tail, real_ending, idx2) : UniLib.insert_in_method(clazz, method, tail, real_ending, idx2)
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

$cache.abil.extend(Ability_Cache)

UniLib.insert_in_method(:PokeBattle_Battler, :crestStats, :TAIL, "self.ability = @ability if @ability.is_a? Symbol") if Rejuv

UniLib.replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@ability      = pkmn.ability", "@ability = AbilityContainer.new(pkmn, pkmn.ability, @ability.added_abilities)")

target = Reborn ? "@backupability = pkmn.ability" : "@backupability= pkmn.ability"
UniLib.replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, target, "@backupability = @ability.copy")

if Reborn
  UniLib.insert_in_method_before(:PokeBattle_Battler, :changeAbility, "@effects[:GorillaLock] = nil",
    "@ability = AbilityContainer.new(@pokemon, @pokemon.ability) if @ability.is_a?(Symbol) or @ability.is_a?(Array)
    @ability = AbilityContainer.new(@pokemon, @pokemon.ability, @ability.added_abilities) if !@ability.nil?")
else
  UniLib.replace_in_method(:PokeBattle_Battler, :pbUpdate, "@ability = @pokemon.ability if !@ability.nil? && !((@crested == :SILVALLY || @crested == :ZOROARK))",
    "@ability = AbilityContainer.new(@pokemon, @pokemon.ability, @ability.added_abilities) if !@ability.nil? && !((@crested == :SILVALLY || @crested == :ZOROARK))")
end
UniLib.insert_in_function(:getAbilityName, :HEAD, "abil = abil.ctx.nil? ? abil.abilities[0] : abil.ctx if abil.is_a? AbilityContainer")

target = Reborn ? "report.push(_INTL(\"Ability: {1}\", pkmn.ability.nil? ? \"Ability Negated\" : getAbilityName(shownmon.ability)))" :
           "report.push(_INTL(\"Ability: {1}\",pkmn.ability.nil? ? \"Ability Negated\" : getAbilityName(shownmon.ability)))"
UniLib.replace_in_function(:pbShowBattleStats, target,
  "if pkmn.ability == nil
    report.push(_INTL(\"Ability: Ability Negated\"))
  elsif shownmon.ability.is_multiple?
    report.push(_INTL(\"Abilities: \"))
    shownmon.ability.abilities.each { |ability| report.push(_INTL(\"- {1}\", getAbilityName(ability))) }
  else
    report.push(_INTL(\"Ability: {1}\", getAbilityName(shownmon.ability.abilities[0])))
  end")

tail = Reborn ? "contactscore *= 0.8 if @opponent.species == :AEGISLASH && !checkAImoves([:KINGSSHIELD]) && (@move.pbIsPhysical?(@attacker) || @battle.FE == :FAIRYTALE)" :
         "contactscore*=0.8 if @opponent.species == :AEGISLASH && !checkAImoves([:KINGSSHIELD]) && (@move.pbIsPhysical?() || @battle.FE == :FAIRYTALE)"
AbilityContainer.multibility_case(:PokeBattle_AI, :getMoveScore, "case @opponent.ability", tail, "}")

AbilityContainer.multibility_case(:PokeBattle_AI, :entraincode, "case @attacker.ability", "case @opponent.ability", "}")

tail = Reborn ? "when :SLOWSTART  then score += 50" : "when :SLOWSTART  then score +=50"
AbilityContainer.multibility_case(:PokeBattle_AI, :entraincode, "case @opponent.ability", tail, "end")

AbilityContainer.multibility_case(:PokeBattle_AI, :moldbreakeronalaser, "case @opponent.ability", "return miniscore", "}") if Rejuv

target = Reborn ? "when :TELEPATHY then return 0 if move.basedamage > 0 && opponent.index == attacker.pbPartner.index" :
           "when :TELEPATHY 						then return 0 if  move.basedamage>0 && opponent.index == attacker.pbPartner.index"
AbilityContainer.multibility_case(:PokeBattle_AI, :pbTypeModNoMessages, "case opponent.ability", target, "end")

tail = Reborn ? "abilityscore *= 0.01" : "abilityscore*=0.01"
AbilityContainer.multibility_case(:PokeBattle_AI, :getAbilityDisruptScore, "case opponent.ability", tail, "}")

tail = Reborn ? "abilityscore += 30 if checkAImoves(PBStuff::PROTECTMOVE, aimem2) && @mondata.skill >= BESTSKILL" :
         "abilityscore+=30 if checkAImoves(PBStuff::PROTECTMOVE,aimem2) && @mondata.skill>=BESTSKILL"
AbilityContainer.multibility_case(:PokeBattle_AI, :getSwitchInScoresParty, "case i.ability", tail, "end")

tail = Reborn ? "when :LIQUIDVOICE then type = @battle.FE == :ICY ? :ICE : :WATER if isSoundBased?" :
         "when :LIQUIDVOICE then type= @battle.FE==:ICY ? :ICE : :WATER if isSoundBased?"
AbilityContainer.multibility_case(:PokeBattle_Move, :pbType, "case attacker.ability", tail, "end")

tail = Reborn ? "when :INEXORABLE    then basemult *= 1.3 if type == :DRAGON && (!opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index])" :
         "when :INEXORABLE    then basemult*=1.3 if type == :DRAGON && (!opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index])"
AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", tail, "end")

AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case opponent.ability", "if attitemworks", "}")

tail = Reborn ? "when :QUARKDRIVE then atkmult *= 1.3 if (attacker.effects[:Quarkdrive][0] == PBStats::ATTACK && pbIsPhysical?(attacker, type)) || (attacker.effects[:Quarkdrive][0] == PBStats::SPATK && pbIsSpecial?(attacker, type))" :
         "when :QUARKDRIVE then atkmult*=1.3 if (attacker.effects[:Quarkdrive][0] == PBStats::ATTACK && pbIsPhysical?(type)) || (attacker.effects[:Quarkdrive][0] == PBStats::SPATK && pbIsSpecial?(type))"
AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", tail, "end", 1)

tail = Reborn ? "when :SKILLLINK then atkmult *= 1.2 if @battle.FE == :COLOSSEUM && (@function == 0xC0 || @function == 0x307 || (attacker.crested == :CINCCINO && !pbIsMultiHit))" :
         "when :SKILLLINK then atkmult*=1.2 if (@battle.FE == :COLOSSEUM && (@function == 0xC0 || @function == 0x307 || (attacker.crested == :CINCCINO && !pbIsMultiHit)))"
AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", tail, "end", 2)

tail = Reborn ? "defmult *= 0.5 if type == :FIRE && !opponent.moldbroken" : "defmult*=0.5 if type == :FIRE && !(opponent.moldbroken)"
AbilityContainer.multibility_case(:PokeBattle_Move, :pbCalcDamage, "case opponent.ability", tail, "end", 1)

AbilityContainer.multibility_case(:PokeBattle_Battler, :pbSpeed, "case self.ability", "case @battle.FE", "}")

tail = Reborn ? "when :ASONECHILLING, :ASONEGRIM then @battle.pbDisplay(_INTL(\"{1} has two Abilities!\", pbThis))" : "when :NEUTRALIZINGGAS then @battle.pbDisplay(_INTL(\"{1}'s gas neutralized all other Pokémon's abilities!\",pbThis))"
AbilityContainer.multibility_case(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "case self.ability", tail, "end")

UniLib.replace_in_method(:PokemonEncounters, :pbGenerateEncounter, "case $Trainer.party[0].ability",
  "$Trainer.party[0].ability.each do |ability|
    case ability")

target = Reborn ? "return nil if rand(250 * 16) >= encount" : "return nil if rand(250*16)>=encount"
UniLib.insert_in_method_before(:PokemonEncounters, :pbGenerateEncounter, target, "end")

# handle trace
UniLib.replace_in_method(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "self.changeAbility(battlerability)",
  "self.ability.handle_trace(battlerability)")