# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
>> ability creation and event API. refer to the Events API for common event types; ability specific events are provided in AbilityModifier.
DOC
module AbilityBuilder

  <<-DOC
  @param symbol - ability symbol
  @param name - ability name, string
  @param desc - ability description, string; must fit in the small ability description box
  @param fulldesc - full-length ability description, string; defaulting to regular desc
  >> used for the creation of new abilities. essentially just an AbilityModifier.new call wrapper.
  DOC
  def self.add(symbol, name, desc, fulldesc=desc)
    AbilityModifier.add(symbol, name, desc, fulldesc)
  end

end

class AbilityModifier

  <<-DOC
  >> injects a block of code after the specified target in the target move.
  DOC
  def self.get_event(ability, id)
    CUSTOM_ABILITIES[ability].event_hash[id]
  end

  <<-DOC
  @param symbol - ability symbol
  @param name - ability name, string
  @param desc - ability description, string; must fit in the small ability description box
  @param fulldesc - full-length ability description, string; defaulting to regular desc
  >> used to create abilitymodifier instances, and can also be used to create new abilities.
  DOC
  def self.add(symbol, name=nil, desc=nil, fulldesc=nil)
    return AbilityModifier.new(symbol, name, desc, fulldesc) if UniLib.cached(UniLib::ABILITY)
    CUSTOM_ABILITIES[symbol] = AbilityModifier.new(symbol, name, desc, fulldesc) if CUSTOM_ABILITIES[symbol].nil?
    CUSTOM_ABILITIES[symbol]
  end

  <<-DOC
  @param name - string
  >> sets the displayed name of the ability (i.e. in debug)
  DOC
  def set_name(name)
    return self if UniLib.cached(UniLib::ABILITY)
    @name = name
    self
  end

  <<-DOC
  @param fullname - string
  >> sets the full name of the ability
  DOC
  def set_full_name(fullname)
    return self if UniLib.cached(UniLib::ABILITY)
    @full_name = fullname
    self
  end


  <<-DOC
  @param desc - string
  >> sets both descriptions of an ability
  DOC
  def set_all_desc(desc)
    return self if UniLib.cached(UniLib::ABILITY)
    @desc = desc
    @full_desc = desc
    self
  end

  <<-DOC
  @param desc - string
  >> sets the initial displayed description of an ability
  DOC
  def set_desc(desc)
    return self if UniLib.cached(UniLib::ABILITY)
    @desc = desc
    self
  end

  <<-DOC
  @param fulldesc - string
  >> sets the detailed description of an ability
  DOC
  def set_full_desc(fulldesc)
    return self if UniLib.cached(UniLib::ABILITY)
    @full_desc = fulldesc
    self
  end

  <<-DOC
  @param proc - a function returning an integer adder.
  >> a conditional form provider, accepts 2 arguments, the calling AI instance (PokeBattle_AI), the calling pokemon (PokeBattle_Pokemon); 
     returns an added ability score modifier corresponding to the ability - see PokeBattle_AI$getSwitchInScoresParty
  DOC
  def ability_score(proc=nil, &block)
    return self if UniLib.cached(UniLib::EVENTS)
    add_or_create_event(:ability_score, proc, block)
  end

  <<-DOC
  @param proc - a function returning a float multiplier.
  >> a conditional form provider, accepts 3 arguments, the calling AI instance (PokeBattle_AI), the attacker (PokeBattle_Pokemon) and 
     target (PokeBattle_Pokemon); returns a miniscore multiplier corresponding to the ability - see PokeBattle_AI$getAbilityDisruptScore
  DOC
  def disrupt_score(proc=nil, &block)
    return self if UniLib.cached(UniLib::EVENTS)
    add_or_create_event(:disrupt_score, proc, block)
  end

end