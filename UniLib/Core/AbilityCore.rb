# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Multibility"
UniLib.include "Constants"
UniLib.include "Events"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  ABILITY_DATA = load_data("Data/abil.dat") unless defined? ABILITY_DATA
  CUSTOM_ABILITIES = {}

end

class AbilityModifier < EventProvider

  include UniLib

  attr_accessor(:name)
  attr_accessor(:full_name)
  attr_accessor(:desc)
  attr_accessor(:full_desc)

  def initialize(symbol, name=nil, desc=nil, fulldesc=nil)
    @symbol = symbol
    @name = name
    @full_name = nil
    @desc = desc
    @full_desc = fulldesc.nil? ? desc : fulldesc
    super()
  end

  def build
    a = $cache.abil[@symbol]
    unless a.nil?
      @name = a.name if @name.nil?
      @full_name = a.fullName if @full_name.nil?
      @desc = a.desc if @desc.nil?
      @full_desc = a.fullDesc if @full_desc.nil?
    end
    $cache.abil[@symbol] = AbilityData.new(@symbol, { :name => @name, :fullName => @full_name, :desc => @desc, :fullDesc => @full_desc })
  end

  def self.has_event?(ability, id)
    !CUSTOM_ABILITIES[ability].nil? and CUSTOM_ABILITIES[ability].event_hash[id]
  end

  def self.get_event(ability, id)
    CUSTOM_ABILITIES[ability].event_hash[id]
  end

end unless UniLib.lib_loaded(__FILE__)

class PokeBattle_Pokemon_Ability < AbilityContainer

  attr_accessor(:base)
  def initialize(pkmn, ability)
    super
    @base = ability
  end

end unless UniLib.lib_loaded(__FILE__)

class PokeBattle_Pokemon

  def update_ability
    @abil_cache = AbilityContainer.new(self, self.ability).abilities unless @abil_cache and @abil_cache.is_a?(Array) and @abil_cache[0] == self.ability
  end unless UniLib.lib_loaded(__FILE__)

  def ability_event_value(event)
    update_ability
    return unless @abil_cache.is_a? Array
    @abil_cache.abilities.each do |ability|
      next unless AbilityModifier.has_event?(ability, event)
      out = AbilityModifier.get_event(ability, event)
      yield(out) unless out.nil?
    end
  end unless UniLib.lib_loaded(__FILE__)

  def apply_ability_event(event, *args)
    update_ability
    return unless @abil_cache.is_a? Array
    @abil_cache.each do |ability|
      next unless AbilityModifier.has_event?(ability, event)
      AbilityModifier.get_event(ability, event).each { |e, out = e.(*args)| yield(out) unless out.nil? }
    end
  end unless UniLib.lib_loaded(__FILE__)

  self.add_listeners(0, :ability_event_value, :apply_ability_event)

end

class PokeBattle_Battler

  def ability_event_value(event)
    return unless self.ability.is_a? AbilityContainer
    return if self.ability == nil
    self.ability.abilities.each do |ability|
      next unless AbilityModifier.has_event?(ability, event)
      out = AbilityModifier.get_event(ability, event)
      yield(out) unless out.nil?
    end
  end

  def apply_ability_event(event, *args)
    print "g" if event == :base_stat_mods
    return unless self.ability.is_a? AbilityContainer
    return if self.ability == nil
    print "b" if event == :base_stat_mods
    self.ability.abilities.each do |ability|
      next unless AbilityModifier.has_event?(ability, event)
      AbilityModifier.get_event(ability, event).each { |e, out = e.(*args)| yield(out) unless out.nil? }
    end
  end

  self.add_listeners(0, :ability_event_value, :apply_ability_event)

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def add_abilities
  $cache.abil.each { |ab, _| $cache.abil.delete(ab) if UniLib::ABILITY_DATA[ab].nil? and UniLib::CUSTOM_ABILITIES[ab].nil? }
  UniLib::CUSTOM_ABILITIES.each { |_, ability_builder| ability_builder.build }
end unless UniLib.lib_loaded(__FILE__)

UniLib.add_play_event(:add_abilities, 1001)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

# ability score
UniLib.insert_in_method_before(:PokeBattle_AI, :getSwitchInScoresParty, "case i.ability",
  "i.apply_ability_event(:weather_score, self, i) { |m| abilityscore += m }")

# ability disrupt score
UniLib.insert_in_method_before(:PokeBattle_AI, :getAbilityDisruptScore, "case opponent.ability",
  "opponent.apply_ability_event(:disrupt_score, self, attacker, opponent) { |m| abilityscore *= m }")