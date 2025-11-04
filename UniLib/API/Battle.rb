# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module UniLib

  def self.trainer_modifier_set_debug(val=true)
    $trainer_modifier_debug = val
  end

  def self.update_base(battler, iv: nil, ev: nil, nature: nil, item: nil, initial: nil)
    battler.pokemon.ev = ev if ev
    battler.pokemon.iv = iv if iv
    battler.pokemon.nature = nature if nature
    battler.pokemon.item = item if item
    battler.pokemon.itemInitial = initial if initial
    battler.pbUpdate
  end

end

module TrainerBuilder

  def self.create(tclass, name, id)
    key = [tclass, name, id]
    TrainerModifier::TRAINER_DATA[key] = TrainerModifier.add(tclass, name, id, true)
  end

end

class TrainerModifier

  $defaults = {}

  def self.with_defaults(**kwargs)
    prev = $defaults
    $defaults = kwargs
    yield
    $defaults = prev
  end

  def self.add(tclass, name, id, is_new=false)
    key = [tclass, name, id]
    TRAINER_DATA[key].delete if is_new and TRAINER_DATA[key]
    TRAINER_DATA[key] = TrainerModifier.new(tclass, name, id, is_new) unless TRAINER_DATA[key]
    TRAINER_DATA[key]
  end

  def set_pkmn(idx, species, level, ability, **kwargs)
    return self if UniLib.cached(UniLib::BATTLE)
    @pkmn[idx] = {} unless @pkmn[idx]
    $defaults[:trainer].each { |k, v| @pkmn[idx][k] = v } if $defaults[:trainer]
    @pkmn[idx][:species] = species
    @pkmn[idx][:level] = level
    ability.nil? ? @pkmn[idx].delete(:ability) : @pkmn[idx][:ability] = ability
    kwargs.each { |k, v| @pkmn[idx][k] = v }
    self
  end

  def set_items(items)
    return self if UniLib.cached(UniLib::BATTLE)
    @items = items
    self
  end

  def set_ace(ace_text)
    return self if UniLib.cached(UniLib::BATTLE)
    @ace = ace_text
    self
  end

  def set_defeat(def_text)
    return self if UniLib.cached(UniLib::BATTLE)
    @defeat = def_text
    self
  end

  def set_effects(effects)
    return self if UniLib.cached(UniLib::BATTLE)
    @effect = effects
    self
  end

  def forced_fe(fe)
    return self if UniLib.cached(UniLib::BATTLE)
    TRAINER_CACHE[@key][0] = fe
    self
  end

  def tclass_name_override(name)
    TRAINER_CACHE[@key][1] = name
    self
  end

end

module BossBuilder

  def self.create(id, species, level, ability, **kwargs)
    BossModifier.add(id, true).set_pkmn(species, level, ability, **kwargs)
  end

end

class BossModifier

  def self.add(id, is_new=false)
    BOSS_DATA[id].delete if is_new and BOSS_DATA[id]
    BOSS_DATA[id] = BossModifier.new(id, is_new) unless BOSS_DATA[id]
    BOSS_DATA[id]
  end

  def set_pkmn(species, level, ability, **kwargs)
    return self if UniLib.cached(UniLib::BATTLE)
    @pkmn[:species] = species
    @pkmn[:level] = level
    @pkmn[:ability] = ability
    $defaults[:boss].each { |k, v| @pkmn[k] = v } if $defaults[:boss]
    kwargs.each { |k, v| k == :unilib_flags ? v.each { |k2, v2| (@pkmn[:unilib_flags] |= {})[k2] = v2 } : @pkmn[k] = v }
    self
  end

  def set_name(name)
    return self if UniLib.cached(UniLib::BATTLE)
    @name = name
    self
  end

  def set_shields(count)
    return self if UniLib.cached(UniLib::BATTLE)
    @shields = count
    self
  end

  def set_immunity(immunity)
    return self if UniLib.cached(UniLib::BATTLE)
    @immunities = {} unless @immunities
    @immunities[immunity] = []
    self
  end

  def set_entry_text(text)
    return self if UniLib.cached(UniLib::BATTLE)
    @entry_text = text
    self
  end

  def set_entry_effect(**kwargs)
    return self if UniLib.cached(UniLib::BATTLE)
    @entry_effects = {} unless @entry_effects
    @entry_effects = {} if kwargs[:delete]
    kwargs.each { |k, v| @entry_effects[k] = v }
    self
  end

  def set_break_effect(idx, **kwargs)
    return self if UniLib.cached(UniLib::BATTLE)
    @break_effects = {} unless @break_effects
    @break_effects.delete(idx) if kwargs[:delete]
    @break_effects[idx] = {} unless @break_effects[idx]
    kwargs.each { |k, v| @break_effects[idx][k] = v if k != :delete }
    self
  end

  def set_sos_condition(condition)
    return self if UniLib.cached(UniLib::BATTLE)
    @sos_details = {} unless @sos_details
    @sos_details[:activationRequirement] = condition
    self
  end

  def set_sos_continuous(bool)
    return self if UniLib.cached(UniLib::BATTLE)
    @sos_details = {} unless @sos_details
    @sos_details[:continuous] = bool
    self
  end

  def set_sos_count(count)
    return self if UniLib.cached(UniLib::BATTLE)
    @sos_details = {} unless @sos_details
    @sos_details[:totalMonCount] = count
    self
  end

  def set_sos_pkmn(idx, species, level, ability, **kwargs)
    return self if UniLib.cached(UniLib::BATTLE)
    @sos_details = {} unless @sos_details
    @sos_details[:moninfos] = {} unless @sos_details[:moninfos]
    @sos_details[:moninfos][idx] = {} unless @sos_details[:moninfos][idx]
    $defaults[:sos].each { |k, v| @sos_details[:moninfos][idx][k] = v } if $defaults[:sos]
    @sos_details[:moninfos][idx][:species] = species
    @sos_details[:moninfos][idx][:level] = level
    @sos_details[:moninfos][idx][:ability] = ability
    kwargs[:delete] ? @sos_details[:moninfos].delete(idx) : kwargs.each { |k, v| @sos_details[:moninfos][idx][k] = v }
    self
  end

  def set_capturable(bool)
    return self if UniLib.cached(UniLib::BATTLE)
    @capturable = bool
    self
  end

  def set_can_run(bool)
    return self if UniLib.cached(UniLib::BATTLE)
    @can_run = bool
    self
  end

  def add_ability_provider(handler)
    AbilityContainer.add_handler(@pkmn[:species], handler, @pkmn[:form] ? @pkmn[:form] : 0, BOSS_MULTIBILITY_HANDLER)
  end

end