# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module UniLib

  def self.trainer_modifier_set_debug(val=true)
    $trainer_modifier_debug = val
  end

end

module TrainerBuilder

  def self.create(tclass, name, id)
    key = [tclass, name, id]
    TRAINER_DATA[key] = TrainerModifier.add(tclass, name, id, true) unless TRAINER_DATA[key]
    TRAINER_DATA[key]
  end

end

class TrainerModifier

  $defaults = {}

  def self.with_defaults(**kwargs)
    $defaults = kwargs
    yield
    $defaults = nil
  end

  def self.add(tclass, name, id, is_new=false)
    key = [tclass, name, id]
    TRAINER_DATA[key] = TrainerModifier.new(tclass, name, id, is_new) unless TRAINER_DATA[key]
    TRAINER_DATA[key]
  end

  def set_pkmn(idx, species, level, ability, **kwargs)
    @pkmn[idx] = {} unless @pkmn[idx]
    $defaults[:trainer].each { |k, v| @pkmn[idx][k] = v } if $defaults[:trainer]
    @pkmn[idx][:species] = species
    @pkmn[idx][:level] = level
    ability.nil? ? @pkmn[idx].delete(:ability) : @pkmn[idx][:ability] = ability
    kwargs.each { |k, v| @pkmn[idx][k] = v }
    self
  end

  def set_items(items)
    @items = items
    self
  end

  def set_ace(ace_text)
    @ace = ace_text
    self
  end

  def set_defeat(def_text)
    @defeat = def_text
    self
  end

  def set_effects(effects)
    @effect = effects
    self
  end

end

class BossModifier

  def self.add(id, is_new=false)
    BOSS_DATA[id] = BossModifier.new(id, is_new) unless BOSS_DATA[id]
    BOSS_DATA[id]
  end

  def set_name(name)
    @name = name
    self
  end

  def set_pkmn(species, level, ability, **kwargs)
    @pkmn[:species] = species
    @pkmn[:level] = level
    @pkmn[:ability] = ability
    kwargs.each { |k, v| @pkmn[k] = v }
    self
  end

  def set_shields(count)
    @shields = count
    self
  end

  def set_immunity(immunity)
    @immunities = {} unless @immunities
    @immunities[immunity] = []
    self
  end

  def set_entry_text(text)
    @entry_text = text
    self
  end

  def set_entry_effect(idx, **kwargs)
    @entry_effects = {} unless @entry_effects
    @entry_effects[idx] = {} unless @entry_effects[idx]
    kwargs[:delete] ? @entry_effects.delete(idx) : kwargs.each { |k, v| @entry_effects[idx][k] = v }
    self
  end

  def set_break_effect(idx, **kwargs)
    @break_effects = {} unless @break_effects
    @break_effects.delete(idx) if kwargs[:delete]
    @break_effects[idx] = {} unless @break_effects[idx]
    kwargs.each { |k, v| @break_effects[idx][k] = v if k != :delete }
    self
  end

  def set_sos_condition(condition)
    @sos_details = {} unless @sos_details
    @sos_details[:activationRequirement] = condition
    self
  end

  def set_sos_continuous(bool)
    @sos_details = {} unless @sos_details
    @sos_details[:continuous] = bool
    self
  end

  def set_sos_count(count)
    @sos_details = {} unless @sos_details
    @sos_details[:totalMonCount] = count
    self
  end

  def set_sos_pkmn(idx, species, level, ability, **kwargs)
    @sos_details = {} unless @sos_details
    @sos_details[:moninfos][idx] = {} unless @sos_details[:moninfos][idx]
    $defaults[:boss].each { |k, v| @sos_details[:moninfos][idx][k] = v } if $defaults[:boss]
    @sos_details[:moninfos][idx][:species] = species
    @sos_details[:moninfos][idx][:level] = level
    @sos_details[:moninfos][idx][:ability] = ability
    kwargs[:delete] ? @sos_details[:moninfos].delete(idx) : kwargs.each { |k, v| @sos_details[:moninfos][idx][k] = v }
    self
  end

  def set_capturable(bool)
    @capturable = bool
    self
  end

  def set_can_run(bool)
    @can_run = bool
    self
  end

end