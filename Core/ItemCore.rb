# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

CUSTOM_ITEMS = {}
EVENT_ITEMS = {}
INVALID_ITEMS = {}
ITEM_DATA = load_data("Data/items.dat") unless defined? ITEM_DATA

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

  attr_accessor(:symbol)
  attr_accessor(:data)
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
  attr_accessor(:type_modifiers)
  attr_accessor(:move_type_overrides)
  attr_accessor(:move_stat_overrides)
  attr_accessor(:on_battle_entry_events)
  attr_accessor(:on_dealt_damage_events)
  attr_accessor(:on_damage_events)
  attr_accessor(:on_turn_end_events)
  attr_accessor(:event_conditions)

  CONSUMED_ITEM = []

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
    @type_modifiers = []
    @move_type_overrides = []
    @move_stat_overrides = []
    @on_battle_entry_events = []
    @on_dealt_damage_events = []
    @on_damage_events = []
    @on_turn_end_events = []
    @ability_providers = []
    @event_conditions = []
    @has_event = false
  end

  def self.affects?(item, pkmn)
    pkmn = pkmn.pokemon if pkmn.is_a? PokeBattle_Battler
    return false if EVENT_ITEMS[item].nil?
    EVENT_ITEMS[item].affects?(pkmn)
  end

  def affects?(pkmn)
    @event_conditions.each { |cond| return false unless cond.call(pkmn) } if @event_conditions.length > 0
    unidev_log(@species)
    @species == :ALL or @species.include? [pkmn.species, pkmn.form]
  end

  def build
    EVENT_ITEMS[@symbol] = self if @has_event
    @species.each do |arr|
      species, form = arr
      @ability_providers.each { |provider| AbilityContainer.add_handler(species, provider, form) }
    end unless @species == :ALL
    $cache.items[@symbol].nil? ? $cache.items[@symbol] = ItemData.new(@symbol, @data) : $cache.items[@symbol].override(@data)
  end

end

def add_invalid_item(item, count=1)
  INVALID_ITEMS[item] = 0 if INVALID_ITEMS[item].nil?
  INVALID_ITEMS[item] += count
end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def add_items
  $cache.items.each do |item, _|
    if ITEM_DATA[item].nil? and CUSTOM_ITEMS[item].nil?
      $cache.items.delete(item)
    end
  end
  CUSTOM_ITEMS.each { |_, item_builder| item_builder.build }
  data = unilib_load_data("item_backup", {})
  data.each do |i, c|
    unless CUSTOM_ITEMS[i].nil?
      $PokemonBag.pbStoreItem(i, c)
      INVALID_ITEMS[i] = "true"
    end
  end
end

def remove_invalid_items
  $Trainer.party.each do |pokemon|
    item = pokemon.instance_variable_get(:@item)
    if !item.nil? and $cache.items[item].nil?
      add_invalid_item(item, 1)
      pokemon.instance_variable_set(:@item, nil)
    end
  end
  $PokemonStorage.boxes.each do |box|
    box.each do |pokemon|
      item = pokemon.instance_variable_get(:@item)
      if !item.nil? and $cache.items[item].nil?
        add_invalid_item(item, 1)
        pokemon.instance_variable_set(:@item, nil)
      end
    end
  end
  $PokemonBag.pockets.each do |pocket|
    pocket.each_with_index do |item, index|
      if $cache.items[item].nil?
        add_invalid_item(item, $PokemonBag.contents[item])
        $PokemonBag.contents.delete(item)
        $PokemonBag.instance_variable_get(:@choices).delete(item)
        pocket.delete_at(index)
      end
    end
  end
end

def write_invalid_items
  data = unilib_load_data("item_backup", {})
  INVALID_ITEMS.each do |i, c|
    if c != "true"
      data[i] = data[i].nil? ? c : data[i] + c
    else
      data.delete(i)
    end
  end
  unilib_save_data("item_backup", data)
end

add_play_event(:add_items, 1001)
add_play_event(:remove_invalid_items, 500)
add_save_event(:write_invalid_items)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

insert_in_function(:pbItemIconFile, :HEAD,
  "unless CUSTOM_ITEMS[item].nil?
    Dir.mkdir(UNILIB_ASSET_PATH) rescue nil
    name = \"Data/Mods/UniLibAssets/\#{item.to_s.gsub(\"_\", \"\").downcase}.png\"
    return name if File.file?(name)
    name = \"Data/Mods/UniLibAssets/Items/\#{item.to_s.gsub(\"_\", \"\").downcase}.png\"
    return name if File.file?(name)
  end")

def check_type(type, vtypes, map)
  vtypes.each { |vtype| return map[vtype].include?(type) unless map[vtype].nil? }
  nil
end

# base stat modifier
insert_in_method(:PokeBattle_Pokemon, :calcStats, "bs=self.baseStats",
  "if ItemModifier.affects?(@item, self)
    stats = NumberContainer.of(*bs)
    EVENT_ITEMS[@item].base_stat_modifiers.each { |mod| mod.call(self, stats) }
    bs = stats.map { |n| n.value }
  end")

# type modifier
insert_in_method(:PokeBattle_Pokemon, :type1, :HEAD,
  "return EVENT_ITEMS[@item].primary if ItemModifier.affects?(@item, self) and EVENT_ITEMS[@item].primary", 1001)

# type modifier
insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
  "(return EVENT_ITEMS[@item].secondary == self.type1 ? nil : EVENT_ITEMS[@item].secondary) if ItemModifier.affects?(@item, self) and EVENT_ITEMS[@item].secondary", 1001)

# resistance modifiers and overrides
insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, "if opponent.crested",
  "if ItemModifier.affects?(opponent.item, opponent)
    typemod = EVENT_ITEMS[opponent.item].forced_resistances[type] if (b = !EVENT_ITEMS[opponent.item].forced_resistances[type].nil?)
    typemod /= 2 if (b = check_type(type, EVENT_ITEMS[opponent.item].weakness_fakes, TYPE_WEAKNESS_MAP)) unless b
    typemod /= 2 if check_type(type, EVENT_ITEMS[opponent.item].resistance_fakes, TYPE_RESISTANCE_MAP) unless b
  end")

# move stab override
insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false",
  "typecrest = true if ItemModifier.affects?(attacker.item, attacker) and EVENT_ITEMS[attacker.item].stab_overrides.include? type")

# move stab override
insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "typecrest = true if ItemModifier.affects?(attacker.item, attacker) and EVENT_ITEMS[attacker.item].stab_overrides.include? type", 1)

# battle stat modifier
insert_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "crestStats if @crested",
  "if ItemModifier.affects?(@item, self)
    stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
    EVENT_ITEMS[@item].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
    @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
  end")

# battle stat modifier
insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "if ItemModifier.affects?(@item, self)
    stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
    EVENT_ITEMS[@item].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
    @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
  end")

# move damage modifier
insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "EVENT_ITEMS[attacker.item].damage_modifiers.each do |mod|
    modifier = mod.call(attacker, opponent, self, self.pbNumHits, true)
    basemult *= modifier unless modifier.nil?
  end if ItemModifier.affects?(attacker.item, attacker)", 1)

# move damage modifier
insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability",
  "EVENT_ITEMS[attacker.item].damage_modifiers.each do |mod|
    modifier = mod.call(attacker, opponent, self, self.pbNumHits, true)
    basemult *= modifier unless modifier.nil?
  end if ItemModifier.affects?(attacker.item, attacker)
  ItemModifier.consume_items")

# move accuracy modifier
insert_in_method_before(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)",
  "EVENT_ITEMS[attacker.item].accuracy_modifiers.each do |mod|
    modified = mod.call(attacker, self, baseaccuracy, accuracy, evasion)
    baseaccuracy, accuracy, evasion = *modified unless modified.nil?
  end if ItemModifier.affects?(attacker.item, attacker)
  ItemModifier.consume_items")

# move priority modifier
insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER",
  "EVENT_ITEMS[attacker.item].priority_modifiers.each do |mod|
    modifier = mod.call(attacker, self)
    pri += modifier unless modifier.nil?
  end if ItemModifier.affects?(attacker.item, attacker)")

# move priority modifier
insert_in_method(:PokeBattle_Battle, :pbPriority, "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)",
  "attacker, move = @battlers[i], @choices[i][2]
  EVENT_ITEMS[attacker.item].priority_modifiers.each do |mod|
    modifier = mod.call(attacker, move)
    pri += modifier unless modifier.nil?
  end if ItemModifier.affects?(attacker.item, attacker)
  ItemModifier.consume_items")

# hit number modifier
insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "target.damagestate.reset",
  "EVENT_ITEMS[self.item].hit_number_modifiers.each do |mod|
    modifier = mod.call(self, target, basemove)
    numhits += modifier unless modifier.nil?
  end if ItemModifier.affects?(self.item, self)
  ItemModifier.consume_items")

# move type override
insert_in_method(:PokeBattle_Move, :pbType, :HEAD,
  "EVENT_ITEMS[attacker.item].move_type_overrides.each do |mod|
    tmp = mod.call(attacker, self, type)
    type = tmp unless tmp.nil?
  end if ItemModifier.affects?(attacker.item, attacker)
  ItemModifier.consume_items")

# attacking stat modifier
insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "if attacker.ability == :HUSTLE && pbIsPhysical?(type)",
  "EVENT_ITEMS[attacker.item].move_stat_overrides.each do |mod|
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
  end if ItemModifier.affects?(attacker.item, attacker)
  ItemModifier.consume_items")

# move type effectiveness modifier
insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return mod1*mod2",
  "EVENT_ITEMS[attacker.item].type_modifiers.each do |mod|
    modifiers = mod.call(attacker, opponent, atype, mod1, mod2)
    mod1, mod2 = modifiers[0], modifiers[1] unless modifiers.nil?
  end if ItemModifier.affects?(attacker.item, attacker)
  ItemModifier.consume_items")

# switch in event
insert_in_method_before(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "if self.ability == :INTIMIDATE && onactive",
  "EVENT_ITEMS[self.item].on_battle_entry_events.each { |event| event.call(self, self.battle, index) } if ItemModifier.affects?(self.item, self) and onactive
  ItemModifier.consume_items")

# damage taken/dealt events
insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?",
  "EVENT_ITEMS[user.item].on_dealt_damage_events.each { |event| event.call(user, target, move, damage) } if ItemModifier.affects?(user.item, user)
  EVENT_ITEMS[target.item].on_damage_events.each { |event| event.call(user, target, move, damage) } if ItemModifier.affects?(target.item, target)
  ItemModifier.consume_items")

# turn end event handler
insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "if i.crested == :VESPIQUEN",
  "EVENT_ITEMS[i.item].on_turn_end_events.each { |event| event.call(i) } if ItemModifier.affects?(i.item, i)
  ItemModifier.consume_items")

# item update
insert_in_method(:PokeBattle_Battler, :pbDisposeItem, :HEAD, "b = !@item.nil? and EVENT_ITEMS[@item]")

# item update
insert_in_method(:PokeBattle_Battler, :pbDisposeItem, :TAIL, "self.pbUpdate(true) if b")