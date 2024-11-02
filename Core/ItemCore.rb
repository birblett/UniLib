# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Constants"
UniLib.include "Helper"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  ITEM_DATA = load_data("Data/items.dat") unless defined? ITEM_DATA

  def self.add_invalid_item(item, count=1)
    INVALID_ITEMS[item] = 0 if INVALID_ITEMS[item].nil?
    INVALID_ITEMS[item] += count
  end unless UniLib.lib_loaded(__FILE__)

  CUSTOM_ITEMS = {}
  EVENT_ITEMS = {}
  INVALID_ITEMS = {}
  CONSUMED_ITEM = []

end

class ItemData < DataObject

  def override(hash)
    hash.each do |key, value|
      case key
        when :name then         @name         = value
        when :desc then         @desc         = value
        when :price then        @price        = value
        else @flags[key] = value
      end
    end
  end

end

class ItemModifier

  include UniLib

  attr_accessor(:symbol)
  attr_accessor(:data)
  attr_accessor(:species)
  attr_accessor(:primary)
  attr_accessor(:secondary)
  attr_accessor(:stab_overrides)
  attr_accessor(:resistance_fakes)
  attr_accessor(:weakness_fakes)
  attr_accessor(:forced_resistances)
  attr_accessor(:base_stat_modifiers)
  attr_accessor(:battle_stat_modifiers)
  attr_accessor(:damage_modifiers)
  attr_accessor(:accuracy_modifiers)
  attr_accessor(:priority_modifiers)
  attr_accessor(:hit_number_modifiers)
  attr_accessor(:type_effectiveness_modifiers)
  attr_accessor(:type_modifiers)
  attr_accessor(:move_type_overrides)
  attr_accessor(:move_stat_overrides)
  attr_accessor(:on_battle_entry_events)
  attr_accessor(:on_move_attempt_events)
  attr_accessor(:on_dealt_damage_events)
  attr_accessor(:on_damage_events)
  attr_accessor(:on_turn_end_events)
  attr_accessor(:form_changes)
  attr_accessor(:event_conditions)
  attr_accessor(:has_event)

  def self.set_consumed_item(pkmn)
    CONSUMED_ITEM.push(pkmn)
  end

  def self.consume_items
    CONSUMED_ITEM.each { |pkmn| pkmn.pbDisposeItem(pbIsBerry?(pkmn.item)) }
  end

  def initialize(symbol, hash={})
    @symbol = symbol
    @data = hash
    @species = []
    @primary = nil
    @secondary = nil
    @resistance_fakes = []
    @stab_overrides = []
    @weakness_fakes = []
    @forced_resistances = {}
    @base_stat_modifiers = []
    @battle_stat_modifiers = []
    @damage_modifiers = []
    @accuracy_modifiers = []
    @priority_modifiers = []
    @hit_number_modifiers = []
    @type_effectiveness_modifiers = []
    @type_modifiers = []
    @move_type_overrides = []
    @move_stat_overrides = []
    @on_battle_entry_events = []
    @on_move_attempt_events = []
    @on_dealt_damage_events = []
    @on_damage_events = []
    @on_turn_end_events = []
    @form_changes = []
    @event_conditions = []
    @ability_providers = []
    @has_event = {}
  end

  def self.affects?(item, pkmn, id)
    pkmn = pkmn.pokemon if pkmn.is_a? PokeBattle_Battler
    return false if EVENT_ITEMS[item].nil?
    EVENT_ITEMS[item].affects?(pkmn, id)
  end

  def affects?(pkmn, id)
    return false unless @has_event[id]
    @event_conditions.each { |cond| return false unless cond.call(pkmn) } if @event_conditions.length > 0
    @species == :ALL or @species.include?([pkmn.species, pkmn.form]) or @species.include?(pkmn.species)
  end

  def build
    EVENT_ITEMS[@symbol] = self if @has_event.size > 0
    @species.each do |arr|
      species, form = arr
      @ability_providers.each { |provider| AbilityContainer.add_handler(species, provider, form) }
    end unless @species == :ALL
    $cache.items[@symbol].nil? ? $cache.items[@symbol] = ItemData.new(@symbol, @data) : $cache.items[@symbol].override(@data)
  end

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

unless UniLib.lib_loaded(__FILE__)

  def add_items
    $cache.items.each do |item, _|
      if UniLib::ITEM_DATA[item].nil? and UniLib::CUSTOM_ITEMS[item].nil?
        $cache.items.delete(item)
      end
    end
    UniLib::CUSTOM_ITEMS.each { |_, item_builder| item_builder.build }
    data = UniLib.restore_data("item_backup", {})
    data.each do |i, c|
      unless UniLib::CUSTOM_ITEMS[i].nil?
        $PokemonBag.pbStoreItem(i, c)
        UniLib::INVALID_ITEMS[i] = "true"
      end
    end
  end

  def remove_invalid_items
    $Trainer.party.each do |pokemon|
      item = pokemon.instance_variable_get(:@item)
      if !item.nil? and $cache.items[item].nil?
        UniLib.add_invalid_item(item, 1)
        pokemon.instance_variable_set(:@item, nil)
      end
    end
    $PokemonStorage.boxes.each do |box|
      box.each do |pokemon|
        item = pokemon.instance_variable_get(:@item)
        if !item.nil? and $cache.items[item].nil?
          UniLib.add_invalid_item(item, 1)
          pokemon.instance_variable_set(:@item, nil)
        end
      end
    end
    $PokemonBag.pockets.each do |pocket|
      pocket.each_with_index do |item, index|
        if $cache.items[item].nil?
          UniLib.add_invalid_item(item, $PokemonBag.contents[item])
          $PokemonBag.contents.delete(item)
          $PokemonBag.instance_variable_get(:@choices).delete(item)
          pocket.delete_at(index)
        end
      end
    end
  end

  def write_invalid_items
    data = UniLib.restore_data("item_backup", {})
    UniLib::INVALID_ITEMS.each do |i, c|
      if c != "true"
        data[i] = data[i].nil? ? c : data[i] + c
      else
        data.delete(i)
      end
    end
    UniLib.save_data("item_backup", data)
  end

end

UniLib.add_play_event(:add_items, 1001)
UniLib.add_play_event(:remove_invalid_items, 500)
UniLib.add_save_event(:write_invalid_items)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

def check_type(type, vtypes, map)
  vtypes.each { |vtype| return map[vtype].include?(type) unless map[vtype].nil? }
  nil
end unless UniLib.lib_loaded(__FILE__)

UniLib.insert_in_function(:pbItemIconFile, :HEAD,
  "unless UniLib::CUSTOM_ITEMS[item].nil?
    Dir.mkdir(UNILIB_ASSET_PATH) rescue nil
    name = \"Data/Mods/UniLibAssets/\#{item.to_s.gsub(\"_\", \"\").downcase}.png\"
    return name if File.file?(name)
    name = \"Data/Mods/UniLibAssets/Items/\#{item.to_s.gsub(\"_\", \"\").downcase}.png\"
    return name if File.file?(name)
  end")

# base stat modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :calcStats, "bs=self.baseStats",
  "if ItemModifier.affects?(@item, self, :base_stat)
    stats = NumberContainer.of(*bs)
    UniLib::EVENT_ITEMS[@item].base_stat_modifiers.each { |mod| mod.call(self, stats) }
    bs = stats.map { |n| n.value }
  end")

# type1 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type1, :HEAD,
  "return UniLib::EVENT_ITEMS[@item].primary if ItemModifier.affects?(@item, self, :primary_type) and UniLib::EVENT_ITEMS[@item].primary")

# type2 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
  "(return UniLib::EVENT_ITEMS[@item].secondary == self.type2 ? nil : UniLib::EVENT_ITEMS[@item].secondary) if ItemModifier.affects?(@item, self, :secondary_type) and UniLib::EVENT_ITEMS[@item].secondary")

# resistance modifiers and overrides
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, "if opponent.crested",
  "if ItemModifier.affects?(opponent.item, opponent, :type_effectiveness_simple)
    typemod = UniLib::EVENT_ITEMS[opponent.item].forced_resistances[type] if (b = !UniLib::EVENT_ITEMS[opponent.item].forced_resistances[type].nil?)
    typemod /= 2 if (b = check_type(type, UniLib::EVENT_ITEMS[opponent.item].weakness_fakes, UniLib::TYPE_WEAKNESS_MAP)) unless b
    typemod /= 2 if check_type(type, UniLib::EVENT_ITEMS[opponent.item].resistance_fakes, UniLib::TYPE_RESISTANCE_MAP) unless b
    UniLib::EVENT_ITEMS[opponent.item].type_effectiveness_modifiers.each { |provider| typemod *= provider.call(opponent, type) unless provider.call(opponent, type).nil? }
  end")

# move type effectiveness modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return mod1*mod2",
  "UniLib::EVENT_ITEMS[attacker.item].type_modifiers.each do |mod|
    modifiers = mod.call(attacker, opponent, atype, mod1, mod2)
    mod1, mod2 = modifiers[0], modifiers[1] unless modifiers.nil?
  end if ItemModifier.affects?(attacker.item, attacker, :type_effectiveness)
  ItemModifier.consume_items")

# move stab override
UniLib.insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false",
  "typecrest = true if ItemModifier.affects?(attacker.item, attacker, :stab_type) and UniLib::EVENT_ITEMS[attacker.item].stab_overrides.include? type")

# move stab override
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "typecrest = true if ItemModifier.affects?(attacker.item, attacker, :stab_type) and UniLib::EVENT_ITEMS[attacker.item].stab_overrides.include? type", 1)

# battle stat modifier
UniLib.insert_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "crestStats if @crested",
  "if ItemModifier.affects?(@item, self, :battle_stat_calc)
    stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
    UniLib::EVENT_ITEMS[@item].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
    @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
  end")

# battle stat modifier
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "if ItemModifier.affects?(@item, self, :battle_stat_calc)
    stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
    UniLib::EVENT_ITEMS[@item].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
    @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
  end")

# move damage modifier
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "UniLib::EVENT_ITEMS[attacker.item].damage_modifiers.each do |mod|
    modifier = mod.call(attacker, opponent, self, self.pbNumHits, true)
    basemult *= modifier unless modifier.nil?
  end if ItemModifier.affects?(attacker.item, attacker, :damage_mod)", 1)

# move damage modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability",
  "UniLib::EVENT_ITEMS[attacker.item].damage_modifiers.each do |mod|
    modifier = mod.call(attacker, opponent, self, self.pbNumHits, true)
    basemult *= modifier unless modifier.nil?
  end if ItemModifier.affects?(attacker.item, attacker, :damage_mod)
  ItemModifier.consume_items")

# move accuracy modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)",
  "UniLib::EVENT_ITEMS[attacker.item].accuracy_modifiers.each do |mod|
    modified = mod.call(attacker, self, baseaccuracy, accuracy, evasion)
    baseaccuracy, accuracy, evasion = *modified unless modified.nil?
  end if ItemModifier.affects?(attacker.item, attacker, :move_accuracy)
  ItemModifier.consume_items")

# move priority modifier
UniLib.insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER",
  "UniLib::EVENT_ITEMS[attacker.item].priority_modifiers.each do |mod|
    modifier = mod.call(attacker, self)
    pri += modifier unless modifier.nil?
  end if ItemModifier.affects?(attacker.item, attacker, :move_priority)")

# move priority modifier
UniLib.insert_in_method(:PokeBattle_Battle, :pbPriority, "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)",
  "attacker, move = @battlers[i], @choices[i][2]
  UniLib::EVENT_ITEMS[attacker.item].priority_modifiers.each do |mod|
    modifier = mod.call(attacker, move)
    pri += modifier unless modifier.nil?
  end if ItemModifier.affects?(attacker.item, attacker, :move_priority)
  ItemModifier.consume_items")

# hit number modifier
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "target.damagestate.reset",
  "if ItemModifier.affects?(self.item, self, :move_hit_count)
    UniLib::EVENT_ITEMS[self.item].hit_number_modifiers.each do |mod|
      modifier = mod.call(self, target, basemove)
      numhits += modifier unless modifier.nil?
    end
    self.effects[:Multihit] = numhits > 1
  end
  ItemModifier.consume_items")

# move type override
UniLib.insert_in_method(:PokeBattle_Move, :pbType, :HEAD,
  "UniLib::EVENT_ITEMS[attacker.item].move_type_overrides.each do |mod|
    tmp = mod.call(attacker, self, type)
    type = tmp unless tmp.nil?
  end if ItemModifier.affects?(attacker.item, attacker, :move_type)
  ItemModifier.consume_items")

# attacking stat modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "if attacker.ability == :HUSTLE && pbIsPhysical?(type)",
  "UniLib::EVENT_ITEMS[attacker.item].move_stat_overrides.each do |mod|
    tmp = mod.call(attacker, opponent, self)
    tmp = [:hp, :atk, :def, :spa, :spd, :spe][tmp] if tmp.is_a? Integer
    case tmp.downcase
    when :hp then atk = attacker.hp
    when :atk then atk = attacker.attack; atkstage = attacker.stages[PBStats::ATTACK]+6
    when :def then atk = attacker.defense; atkstage = attacker.stages[PBStats::DEFENSE]+6
    when :spa then atk = attacker.spatk; atkstage = attacker.stages[PBStats::SPATK]+6
    when :spd then atk = attacker.spdef; atkstage = attacker.stages[PBStats::SPDEF]+6
    when :spe then atk = attacker.speed; atkstage = attacker.stages[PBStats::SPEED]+6
    when :opphp then atk = opponent.hp
    when :oppatk then atk = opponent.attack; atkstage = opponent.stages[PBStats::ATTACK]+6
    when :oppdef then atk = opponent.defense; atkstage = opponent.stages[PBStats::DEFENSE]+6
    when :oppspa then atk = opponent.spatk; atkstage = opponent.stages[PBStats::SPATK]+6
    when :oppspd then atk = opponent.spdef; atkstage = opponent.stages[PBStats::SPDEF]+6
    when :oppspe then atk = opponent.speed; atkstage = opponent.stages[PBStats::SPEED]+6
    end if tmp.is_a? Symbol
  end if ItemModifier.affects?(attacker.item, attacker, :move_stat)
  ItemModifier.consume_items")

# switch in event
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "if self.ability == :INTIMIDATE && onactive",
  "UniLib::EVENT_ITEMS[self.item].on_battle_entry_events.each { |event| event.call(self, self.battle, index) } if ItemModifier.affects?(self.item, self, :battle_entry) and onactive
  ItemModifier.consume_items")

# move attempted events
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbTryUseMove, "protype=basemove.pbType(self,basemove.type)",
  "UniLib::EVENT_ITEMS[self.item].on_move_attempt_events.each { |event| event.call(self, basemove) } if ItemModifier.affects?(self.item, self, :try_move)")

# damage taken/dealt events
UniLib.insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?",
  "UniLib::EVENT_ITEMS[user.item].on_dealt_damage_events.each { |event| event.call(user, target, move, damage) } if ItemModifier.affects?(user.item, user, :damage_dealt)
  UniLib::EVENT_ITEMS[target.item].on_damage_events.each { |event| event.call(user, target, move, damage) } if ItemModifier.affects?(target.item, target, :damage_taken)
  ItemModifier.consume_items")

# turn end event handler
UniLib.insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "if i.crested == :VESPIQUEN",
  "UniLib::EVENT_ITEMS[i.item].on_turn_end_events.each { |event| event.call(i) } if ItemModifier.affects?(i.item, i, :turn_end)
  ItemModifier.consume_items")

# form change handler
UniLib.insert_in_method(:PokeBattle_Battler, :pbCheckForm, "transformed=false",
  "UniLib::EVENT_ITEMS[self.item].form_changes.each do |mod|
    unless (f = mod.call(self, basemove)).nil?
      self.form = f
      transformed=true
    end
  end if ItemModifier.affects?(self.item, self, :form_change)
  ItemModifier.consume_items")

# item update
UniLib.insert_in_method(:PokeBattle_Battler, :pbDisposeItem, :HEAD, "b = !@item.nil? and UniLib::EVENT_ITEMS[@item]")

# item update
UniLib.insert_in_method(:PokeBattle_Battler, :pbDisposeItem, :TAIL, "self.pbUpdate(true) if b")