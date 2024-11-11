# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module AbilityBuilder

  def self.add(symbol, name, desc, fulldesc=desc)
    AbilityModifier.add(symbol, name, desc, fulldesc)
  end

end

class AbilityModifier

  include UniLib

  def self.add(symbol, name=nil, desc=nil, fulldesc=nil)
    CUSTOM_ABILITIES[symbol] = AbilityModifier.new(symbol, name, desc, fulldesc) if CUSTOM_ABILITIES[symbol].nil?
    CUSTOM_ABILITIES[symbol]
  end

  <<-DOC
  @param name - string
  >> sets the displayed name of the ability (i.e. in debug)
  DOC
  def set_name(name)
    @name = name
    self
  end

  <<-DOC
  @param fullname - string
  >> sets the full name of the ability
  DOC
  def set_full_name(fullname)
    @full_name = fullname
    self
  end

  <<-DOC
  @param desc - string
  >> sets the initial displayed description of an ability
  DOC
  def set_desc(desc)
    @desc = desc
    self
  end

  <<-DOC
  @param fulldesc - string
  >> sets the detailed description of an ability
  DOC
  def set_full_desc(fulldesc)
    @full_desc = fulldesc
    self
  end

  <<-DOC
  @param proc - a function returning an integer adder.
  >> a conditional form provider, accepts 2 arguments, the calling AI instance (PokeBattle_AI), the calling pokemon (PokeBattle_Pokemon); 
     returns an added ability score modifier corresponding to the ability - see PokeBattle_AI$getSwitchInScoresParty
  DOC
  def ability_score(proc)
    @event_hash[:ability_score] = [] unless @event_hash[:ability_score]
    @event_hash[:ability_score].push(proc)
    self
  end

  <<-DOC
  @param proc - a function returning a float multiplier.
  >> a conditional form provider, accepts 3 arguments, the calling AI instance (PokeBattle_AI), the attacker (PokeBattle_Pokemon) and 
     target (PokeBattle_Pokemon); returns a miniscore multiplier corresponding to the ability - see PokeBattle_AI$getAbilityDisruptScore
  DOC
  def disrupt_score(proc)
    @event_hash[:disrupt_score] = [] unless @event_hash[:disrupt_score]
    @event_hash[:disrupt_score].push(proc)
    self
  end

end