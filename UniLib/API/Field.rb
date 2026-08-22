# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

class FieldBuilder

  def self.add(field, name, message)
    m = FieldModifier.add(field)
    return m if m
    FieldModifier::MODIFIED_FIELDS[field] = FieldModifier.new({ name: name, fieldMessage: message })
  end

end
class FieldModifier

  # attempts to create a new field modifier for an existing field
  #
  # @param field field symbol
  def self.add(field)
    return MODIFIED_FIELDS[field] if MODIFIED_FIELDS[field]
    return MODIFIED_FIELDS[field] = FieldModifier.new(UniLib.deep_copy(FIELD_DATA[field])) if FIELD_DATA[field]
  end

  # sets core data for the field
  #
  # @param name field name text
  # @param field_message text to display
  def core_data(name: nil, field_message: nil)
    set_value(:name, name)
    set_value(:fieldMessage, field_message)
    self
  end

  # sets the field graphic
  #
  # @param index index used to replace in the graphic array, if larger than the array then appends to the end. can also be :push for append.
  # @param graphic graphic path
  # @param redirect_bg redirect to a path in the mod folder, applied to backgrounds
  def set_graphic(index: :push, graphic: nil, redirect_bg: nil, redirect_base_player: nil, redirect_base_enemy: nil)
    set_array(:graphic, graphic, index)
    Assets.redirect(:BMP, "battlebg#{graphic}", redirect_bg) if graphic and redirect_bg
    Assets.redirect(:BMP, "playerbase#{graphic}", redirect_base_player) if graphic and redirect_base_player
    Assets.redirect(:BMP, "enemybase#{graphic}", redirect_base_enemy) if graphic and redirect_base_enemy
    self
  end

  # sets conditions for changing to another field
  #
  # @param field field to change to
  # @param condition condition code eval'd in PokeBattle_Move, end of move use
  def change_condition(field, condition)
    set_hash(:changeCondition, field, condition)
    self
  end

  # sets simple data for the field
  #
  # @param secret_power secret power animation move
  # @param nature_power nature power move
  # @param mimicry mimicry type
  # @param burmy_cloak burmy cloak type, delete defaults to terrain tag
  def basic_interactions(secret_power: nil, nature_power: nil, mimicry: nil, burmy_cloak: nil)
    set_value(:secretPower, secret_power)
    set_value(:naturePower, nature_power)
    set_value(:mimicry, mimicry)
    set_value(:burmyCloak, burmy_cloak)
    self
  end


  # sets seed data for the field
  #
  # @param seed seed type
  # @param effect effect to apply
  # @param duration effect duration, if applicable
  # @param message text to display when effect is applied
  # @param animation animation to display
  # @param atk attack stat change
  # @param defe defense stat change
  # @param spa special attack stat change
  # @param spd special defense stat change
  # @param spe speed stat change
  # @param acc accuracy stat change
  # @param eva evation stat change
  def seed_data(seed, effect: nil, duration: nil, message: nil,
                animation: nil, atk: nil, defe: nil, spa: nil, spd: nil, spe: nil,
                acc: nil, eva: nil)
    set_hash(:seed, :seedtype, seed)
    set_hash(:seed, :effect, effect)
    set_hash(:seed, :duration, duration)
    set_hash(:seed, :message, message)
    set_hash(:seed, :animation, animation)
    set_hash(:stats, PBStats::ATTACK, atk, @data[:seed])
    set_hash(:stats, PBStats::DEFENSE, defe, @data[:seed])
    set_hash(:stats, PBStats::SPATK, spa, @data[:seed])
    set_hash(:stats, PBStats::SPDEF, spd, @data[:seed])
    set_hash(:stats, PBStats::SPEED, spe, @data[:seed])
    set_hash(:stats, PBStats::ACCURACY, acc, @data[:seed])
    set_hash(:stats, PBStats::EVASION, eva, @data[:seed])
    self
  end

  # move modifiers for the field
  #
  # @param move move or moves to apply field-based mods to
  # @param mult damage multiplier
  # @param typemod type change
  # @param accmod fixed accuracy
  # @param text text to display on use
  # @param counter how to interact with field counters - [counter to increment, increment, maximum, text to display]
  # @param effect code eval'd by PokeBattle_Move after use but before field changes
  # @param field_change field to change to
  # @param change_message text to display on field change
  # @param change_effect code eval'd by PokeBattle_Move after a field change
  # @param change_backup whether move will store current field as a backup
  # @param status_buff buffed by field flag, only used for field app
  # @param status_nerf nerfed by field flag, only used for field app
  def move_interaction(move, mult: nil, typemod: nil, accmod: nil, text: nil,
                       counter: nil, effect: nil, field_change: nil,
                       change_message: nil, change_effect: nil, change_backup: nil,
                       status_buff: nil, status_nerf: nil)
    [*move].each { |m|
      set_hash_inverted(:damageMods, m, mult)
      set_hash_inverted(:typeMods, m, typemod)
      set_hash_inverted(:accuracyMods, m, accmod)
      set_hash_inverted(:moveMessages, m, text)
      set_hash_inverted(:fieldCounterIncreases, m, counter)
      set_hash_inverted(:moveEffects, m, effect)
      set_hash_inverted(:fieldChange, m, field_change)
      set_hash_inverted(:changeMessage, m, change_message)
      set_hash_inverted(:changeEffects, m, change_effect)
      set_array_inverted(:dontChangeBackup, m, change_backup)
      set_array_inverted(:statusBuffs, m, status_buff)
      set_array_inverted(:statusNerfs, m, status_nerf)
    }
    self
  end

  # type modifiers for the field
  #
  # @param type type or types to apply field-based mods to
  # @param mult damage multiplier
  # @param addon added type
  # @param effect code eval'd by PokeBattle_Move after use but before field changes
  # @param text text to display on field change
  # @param condition condition code eval'd by PokeBattle_Move before use
  def type_interaction(type, mult: nil, addon: nil, effect: nil,
                       text: nil, condition: nil)
    [*type].each { |t|
      set_hash_inverted(:typeBoosts, t, mult)
      set_hash_inverted(:typeAddOns, t, addon)
      set_hash_inverted(:typeEffects, t, effect)
      set_hash_inverted(:typeMessages, t, text)
      set_hash_inverted(:typeCondition, t, condition)
    }
    self
  end

  # move modifiers for the field as an overlay
  #
  # @param move move or moves to apply field-based mods to
  # @param mult damage multiplier
  # @param typemod type change
  # @param text text to display on use
  def overlay_move_interaction(move, mult: nil, typemod: nil, text: nil,
                               status_buff: nil, status_nerf: nil)
    [*move].each { |m|
      set_hash_inverted(:damageMods, m, mult, @data[:overlay] ||= {})
      set_hash_inverted(:typeMods, m, typemod, @data[:overlay])
      set_hash_inverted(:moveMessages, m, text, @data[:overlay])
      set_array_inverted(:statusBuffs, m, status_buff, @data[:overlay])
      set_array_inverted(:statusNerfs, m, status_nerf, @data[:overlay])
    }
    self
  end

  # type modifiers for the field as an overlay
  #
  # @param type type or types to apply field-based mods to
  # @param mult damage multiplier
  # @param addon added type
  # @param text text to display on field change
  def overlay_type_interaction(type, mult: nil, addon: nil, text: nil)
    [*type].each { |t|
      set_hash_inverted(:typeBoosts, t, mult, @data[:overlay] ||= {})
      set_hash_inverted(:typeAddOns, t, addon, @data[:overlay])
      set_hash_inverted(:typeMessages, t, text, @data[:overlay])
    }
    self
  end

end