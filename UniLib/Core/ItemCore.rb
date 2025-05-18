# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.7, __FILE__)
UniLib.include "Constants"
UniLib.include "Helper"
UniLib.include "Events"

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
  UNLOSABLE_ITEMS = {}
  UNLOSABLE_DEFAULT_CONDITION = proc { true }
  $should_consume_item = false

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

class ItemModifier < EventProvider

  include UniLib

  attr_accessor(:symbol)
  attr_accessor(:data)
  attr_accessor(:species)

  def self.with_consumption
    $should_consume_item = true
    yield
    ItemModifier.consume_items
    $should_consume_item = false
  end

  def self.consume_items
    CONSUMED_ITEM.each { |pkmn| pkmn.pbDisposeItem(pbIsBerry?(pkmn.item)) if pkmn.is_a? PokeBattle_Battler }
    CONSUMED_ITEM.clear
  end

  def initialize(symbol, hash={})
    @symbol = symbol
    @data = hash
    @species = []
    @ability_providers = []
    super()
  end

  def build
    EVENT_ITEMS[@symbol] = self if @event_hash.size > 0
    item_check = proc { |pkmn| pkmn.item == @symbol }
    @species.each do |arr|
      species, form = arr
      @ability_providers.each { |provider| AbilityContainer.add_handler(species, provider, form, item_check) }
    end unless @species == :ALL
    $cache.items[@symbol].nil? ? $cache.items[@symbol] = ItemData.new(@symbol, @data) : $cache.items[@symbol].override(@data)
  end

  def self.has_event?(pkmn, id)
    pkmn = pkmn.pokemon if pkmn.is_a? PokeBattle_Battler
    return false if pkmn.nil? or EVENT_ITEMS[pkmn.item].nil? or EVENT_ITEMS[pkmn.item].event_hash[id].nil?
    species = EVENT_ITEMS[pkmn.item].species
    species == :ALL or species.include?([pkmn.species, pkmn.form]) or species.include?(pkmn.species)
  end

  def self.get_event(pkmn, id)
    EVENT_ITEMS[pkmn.item].event_hash[id]
  end

end unless UniLib.lib_loaded(__FILE__)

class PokeBattle_Pokemon

  def item_event_value(event)
    return unless ItemModifier.has_event?(self, event)
    out = ItemModifier.get_event(self, event)
    yield(out) unless out.nil?
  end

  def apply_item_event(event, *args)
    return unless ItemModifier.has_event?(self, event)
    ItemModifier.get_event(self, event).each { |e, out = e.(*args)| yield(out) unless out.nil? }
  end

end unless UniLib.lib_loaded(__FILE__)

class PokeBattle_Battler

  def item_event_value(event)
    return unless ItemModifier.has_event?(self, event)
    out = ItemModifier.get_event(self, event)
    yield(out) unless out.nil?
  end

  def apply_item_event(event, *args)
    return unless ItemModifier.has_event?(self, event)
    ItemModifier.get_event(self, event).each { |e, out = e.(*args)| yield(out) unless out.nil? }
  end

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

unless UniLib.lib_loaded(__FILE__)

  def add_items(save)
    $cache.items.each do |item, _|
      if UniLib::ITEM_DATA[item].nil? and UniLib::CUSTOM_ITEMS[item].nil?
        $cache.items.delete(item)
      end
    end
    UniLib::CUSTOM_ITEMS.each { |_, item_builder| item_builder.build }
    data = save[:UniLibInvalidItems]
    data.each do |i, c|
      unless UniLib::CUSTOM_ITEMS[i].nil?
        $PokemonBag.pbStoreItem(i, c)
        UniLib::INVALID_ITEMS[i] = "true"
      end
    end if save[:UniLibInvalidItems]
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

  def write_invalid_items(save)
    data = save[:UniLibInvalidItems] ? save[:UniLibInvalidItems] : {}
    UniLib::INVALID_ITEMS.each do |i, c|
      if c != "true"
        data[i] = data[i].nil? ? c : data[i] + c
      else
        data.delete(i)
      end
    end
    save[:UniLibInvalidItems] = data
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

UniLib.with_priority(1000) {

UniLib.insert_in_function(:pbItemIconFile, :HEAD,
  "unless UniLib::CUSTOM_ITEMS[item].nil?
    Dir.mkdir(UNILIB_ASSET_PATH) rescue nil
    name = \"Data/Mods/UniLibAssets/\#{item.to_s.gsub(\"_\", \"\").downcase}.png\"
    return name if File.file?(name)
    name = \"Data/Mods/UniLibAssets/Items/\#{item.to_s.gsub(\"_\", \"\").downcase}.png\"
    return name if File.file?(name)
  end")

# base stat modifier
target = Reborn ? "bs = self.baseStats" : "bs=self.baseStats"
UniLib.insert_in_method(:PokeBattle_Pokemon, :calcStats, target,
  "stats = NumberContainer.of(*bs)
  self.apply_item_event(:base_stat_mods, self, stats) {}
  bs = stats.map { |n| n.value }")

# type1 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type1, :HEAD,
  "self.apply_item_event(:primary_type, self) { |m| return m }")

# type2 modifier
UniLib.insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
  "self.apply_item_event(:secondary_type, self) { |m| return m == self.type1 ? nil : m }")

# type modifiers (in battle, on switch in)
UniLib.insert_in_method(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, :TAIL,
  "ItemModifier.with_consumption {
    self.apply_item_event(:primary_type_battle, self, true) { |m| @type1 = m }
    self.apply_item_event(:secondary_type_battle, self, true) { |m| @type2 = (m == @type1 ? nil : m) }
  }")

# type modifiers (in battle, on update)
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "ItemModifier.with_consumption {
    self.apply_item_event(:primary_type_battle, self, false) { |m| @type1 = m }
    self.apply_item_event(:secondary_type_battle, self, false) { |m| @type2 = (m == @type1 ? nil : m) }
  }")

# resistance modifiers and overrides
target = Reborn ? "if typemod == 0" : "if opponent.crested"
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, target,
  "ItemModifier.with_consumption {
    opponent.item_event_value(:forced_resistance) { |forced| typemod = forced[type] unless forced[type].nil? }
    opponent.item_event_value(:fake_reduce_weakness) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_WEAKNESS_MAP) }
    opponent.item_event_value(:fake_resistance) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_RESISTANCE_MAP) }
    opponent.apply_item_event(:type_effectiveness_simple, opponent, type, true) { |m| typemod *= m }
  }
  typemod = 0 if typemod < 0")

# resistance modifiers and overrides (ai)
target = Reborn ? "if id == :FLYINGPRESS" : "case opponent.crested"
UniLib.insert_in_method_before(:PokeBattle_AI, :pbTypeModNoMessages, target,
  "opponent.item_event_value(:forced_resistance) { |forced| typemod = forced[type] unless forced[type].nil? }
  opponent.item_event_value(:fake_reduce_weakness) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_WEAKNESS_MAP) }
  opponent.item_event_value(:fake_resistance) { |arr| typemod /= 2 if check_type(type, arr, UniLib::TYPE_RESISTANCE_MAP) }
  opponent.apply_item_event(:type_effectiveness_simple, opponent, type, false) { |m| typemod *= m }
  typemod = 0 if typemod < 0", Reborn ? 0 : 1)

# move type effectiveness modifier
target = Reborn ? "return mod1 * mod2" : "return mod1*mod2"
UniLib.insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, target,
  "ItemModifier.with_consumption { attacker.apply_item_event(:type_effectiveness, attacker, opponent, self, mod1, mod2) { |mod| mod1, mod2 = mod[0], mod[1] } }")

# move stab override
UniLib.insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false",
  "ItemModifier.with_consumption {
    attacker.item_event_value(:stab_type) { |types| typecrest = true if types.include?(type) }
    attacker.apply_item_event(:conditional_stab_type, attacker, self) { |c| typecrest ||= true }
  }")

# move stab override (ai)
UniLib.insert_in_method(:PokeBattle_AI, :pbRoughDamage, "typecrest = false",
  "attacker.item_event_value(:stab_type) { |types| typecrest = true if types.include?(type) }
  attacker.apply_item_event(:conditional_stab_type, attacker, self) { |c| typecrest ||= true }", Reborn ? 0 : 1)

# battle stat modifier
UniLib.insert_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "crestStats if @crested",
  "stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
  self.apply_item_event(:battle_stat_calc, self, stats) {}
  @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }")

# battle stat modifier (on update)
UniLib.insert_in_method(:PokeBattle_Battler, :pbUpdate, "crestStats if @crested",
  "stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
  self.apply_item_event(:battle_stat_calc, self, stats) {}
  @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }")

# battle speed modifier (on calculation)
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbSpeed, "speed = 1 if speed <= 1",
  "self.apply_item_event(:battle_speed_calc, self) { |m| speed *= m }")

# move damage modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability",
  "ItemModifier.with_consumption {
    attacker.apply_item_event(:damage_mod, attacker, opponent, self, hitnum, nil) { |m| basemult *= m }
    opponent.apply_item_event(:damage_taken_mod, opponent, attacker, self, hitnum, nil) { |m| basemult *= m }
  }")

# move damage modifier (ai)
UniLib.insert_in_method(:PokeBattle_AI, :pbRoughDamage, "typecrest = false",
  "attacker.apply_item_event(:damage_mod, attacker, opponent, move, move.pbNumHits(attacker), self) { |m| damage *= m }
  opponent.apply_item_event(:damage_taken_mod, opponent, attacker, self, move.pbNumHits(attacker), self) { |m| damage *= m }", 0, 1001)

# move accuracy modifier
if Reborn
  UniLib.insert_in_method_before(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100) < (baseaccuracy * accuracy / 100.0).floor",
    "base, acc, eva = NumberContainer.of(baseaccuracy, accuracy, 1)
    ItemModifier.with_consumption { attacker.apply_item_event(:accuracy_mod, attacker, self, base, acc, eva) { |m| return true if m } }
    baseaccuracy, accuracy = base.value, acc.value / eva.value")
else
  UniLib.insert_in_method_before(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)",
    "base, acc, eva = NumberContainer.of(baseaccuracy, accuracy, evasion)
    ItemModifier.with_consumption { attacker.apply_item_event(:accuracy_mod, attacker, self, base, acc, eva) { |m| return true if m } }
    baseaccuracy, accuracy, evasion = base.value, acc.value, eva.value")
end

# move priority modifier
target = Reborn ? "pri += 3 if @battlers[i].ability == :TRIAGE && PBStuff::HEALFUNCTIONS.include?(@choices[i][2].function)" : "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)"
UniLib.insert_in_method(:PokeBattle_Battle, :pbPriority, target,
  "ItemModifier.with_consumption { @battlers[i].apply_item_event(:move_priority, @battlers[i], @choices[i][2]) { |m| pri += m } }")

# move priority modifier (check only)
UniLib.insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER",
  "attacker.apply_item_event(:move_priority, attacker, self) { |m| pri += m }")

# move crit rate modifier
target = Reborn ? "c = 3 if c > 3" : "c=3 if c>3"
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCritRate?, target,
  "if (caller_locations.first.label == \"pbRoughDamage\" rescue false)
    attacker.apply_item_event(:crit_mod, attacker, opponent, self) { |m| c += m }
  else
    ItemModifier.with_consumption { attacker.apply_item_event(:crit_mod, attacker, opponent, self) { |m| c += m } }
  end")

# hit number modifier
UniLib.insert_in_method(:PokeBattle_Move, :pbNumHits, :HEAD,
  "attacker.effects[:Multihit] = nil
  ItemModifier.with_consumption { attacker.apply_item_event(:hit_count_mod, attacker, self) { |m| return m if m and (attacker.effects[:Multihit] = m > 1) } }")

# move type override
UniLib.insert_in_method(:PokeBattle_Move, :pbType, :HEAD,
  "attacker.apply_item_event(:move_type_override, attacker, self, type) { |m| type = m }")

# move subtype provider
UniLib.insert_in_method(:PokeBattle_Move, :getSecondaryType, "secondtype = []",
  "attacker.apply_item_event(:move_subtype, attacker, self) { |m| secondtype.push(m) }")

# attacking stat modifier
UniLib.insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "if opponent.ability != :UNAWARE || opponent.moldbroken",
  "ItemModifier.with_consumption { attacker.apply_item_event(:move_stat_override, attacker, opponent, self) { |m|
    m = [:hp, :atk, :def, :spa, :spd, :spe][m] if m.is_a? Integer
    case m.downcase
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
    end if m.is_a? Symbol
  } }")

# attacking stat modifier (ai)
UniLib.insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested",
  "attacker.apply_item_event(:move_stat_override, attacker, opponent, move) { |m|
    m = [:hp, :atk, :def, :spa, :spd, :spe][m] if m.is_a? Integer
    case m.downcase
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
    end if m.is_a? Symbol
  }")

# effect initialization event
UniLib.insert_in_method(:PokeBattle_Battler, :pbInitEffects, :TAIL,
  "ItemModifier.with_consumption { self.apply_item_event(:effects_init, self, self.battle, self.effects, oldeffects, fakebattler) {} }")

# switch in event
target = Reborn ? "return if @hp <= 0" : "return if @hp<=0"
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, target,
  "ItemModifier.with_consumption { self.apply_item_event(:battle_entry, self, self.battle, index) {} } if onactive")

# move attempted events
target = Reborn ? "protype = basemove.pbType(self, basemove.type)" : "protype=basemove.pbType(self,basemove.type)"
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbTryUseMove, target,
  "ItemModifier.with_consumption { self.apply_item_event(:try_move, self, basemove) {} }")

target = Reborn ? "damage = basemove.pbEffect(user, target, i, alltargets, showanimation)" : "damage = basemove.pbEffect(user,target,i,alltargets,showanimation)"
# move effect events
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbProcessMoveAgainstTarget, target,
  "ItemModifier.with_consumption { user.apply_item_event(:move_effect, user, target, i, basemove) {} }")

# after move effect events
UniLib.insert_in_method(:PokeBattle_Battler, :pbProcessMoveAgainstTarget, target,
  "ItemModifier.with_consumption { user.apply_item_event(:after_move_effect, user, target, i, basemove) {} }")

# switch out events
target = Reborn ? "pbInitPokemon(pkmn, index)" : "pbInitPokemon(pkmn,index)"
UniLib.insert_in_method_before(:PokeBattle_Battler, :pbInitialize, target,
  "ItemModifier.with_consumption { self.apply_item_event(:switch_out, self) {} }")

# damage taken/dealt events
UniLib.insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?",
  "ItemModifier.with_consumption { user.apply_item_event(:damage_dealt, user, target, move, damage) {} }
  ItemModifier.with_consumption { target.apply_item_event(:damage_taken, target, user, move, damage) {} } if damage > 0")

# ko events
UniLib.insert_in_method(:PokeBattle_Battler, :pbUseMove, "if !@battle.pbAllFainted?(@battle.pbParty(target.index))",
  "ItemModifier.with_consumption { user.apply_item_event(:on_ko, user, target, basemove) {} }")

# turn end event handler
UniLib.insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "if i.crested == :VESPIQUEN",
  "ItemModifier.with_consumption { i.apply_item_event(:turn_end, i) {} }")

# form change handler
if Reborn
  UniLib.insert_in_method(:PokeBattle_Battler, :pbCheckFormRoundEnd, :TAIL,
    "transformed = false
    ItemModifier.with_consumption { self.apply_item_event(:form_change, self, nil) { |m| transformed = !(self.form = m).nil? } } unless self.isFainted?
    if transformed
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.pbDisplay(_INTL(\"{1} transformed!\",pbThis))
    end")
  UniLib.insert_in_method(:PokeBattle_Battler, :pbTryUseMove, "pbCheckStance(basemove) if self.ability == :STANCECHANGE",
    "transformed = false
    ItemModifier.with_consumption { self.apply_item_event(:form_change, self, basemove) { |m| transformed = !(self.form = m).nil? } } unless self.isFainted?
    if transformed
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.pbDisplay(_INTL(\"{1} transformed!\",pbThis))
    end")
else
  UniLib.insert_in_method(:PokeBattle_Battler, :pbCheckForm, "transformed=false",
    "ItemModifier.with_consumption { self.apply_item_event(:form_change, self, basemove) { |m| transformed = !(self.form = m).nil? } } unless self.isFainted?")
end

# switch in score
UniLib.insert_in_method(:PokeBattle_AI, :getSwitchInScoresParty, "monscore += otherscore",
  "i.apply_item_event(:switch_in_score, self, i) { |m| monscore += m }")

# move score
UniLib.insert_in_method_before(:PokeBattle_AI, :getMoveScore, "case @move.function",
  "@attacker.apply_item_event(:move_score, self, @attacker, @opponent, @move) { |m| miniscore *= m }")

# should switch score
UniLib.insert_in_method_before(:PokeBattle_AI, :shouldSwitch?, "switchscore = statusscore + statscore + healscore + forcedscore + typescore + specialscore",
  "@attacker.apply_item_event(:should_switch_score, self, @attacker, @opponent) { |m| specialscore += m }")

# should switch score
UniLib.insert_in_method_before(:PokeBattle_AI, :shouldSwitch?, "switchscore = statusscore + statscore + healscore + forcedscore + typescore + specialscore",
  "@attacker.apply_item_event(:should_switch_score, self, @attacker, @opponent) { |m| specialscore += m }")

# move scores
UniLib.insert_in_method_before(:PokeBattle_AI, :getMoveScore, "case @move.function",
  "@attacker.apply_item_event(:move_score, self, @attacker, @opponent, @move) { |m| return -1 if m == -1; miniscore *= m }
    @opponent.apply_item_event(:targeted_by_move, self, @opponent, @attacker, @move) { |m| return -1 if m == -1; miniscore *= m }")

# role provider
UniLib.insert_in_method_before(:PokeBattle_AI, :pbGetMonRoles, "partyRoles.push(monRoles)",
  "mon.apply_item_event(:roles, self, mon) { |m| monRoles.push(m) }")


# ========= item only ========= #

# unlosable item
UniLib.insert_in_method(:PokeBattle_Battle, :pbIsUnlosableItem, :HEAD,
  "UniLib::UNLOSABLE_ITEMS[item].each { |cond| return true if cond.call(pkmn) } if UniLib::UNLOSABLE_ITEMS[item]")

# item update
UniLib.insert_in_method(:PokeBattle_Battler, :pbDisposeItem, :HEAD, "b = !@item.nil? and UniLib::EVENT_ITEMS[@item]")

# item update
UniLib.insert_in_method(:PokeBattle_Battler, :pbDisposeItem, :TAIL, "self.pbUpdate(true) if b")

# item score
target = Reborn ? "itemscore -= 100" : "itemscore-=100"
UniLib.insert_in_method_before(:PokeBattle_AI, :getItemScore, target,
  "@attacker.apply_item_event(:item_score, self, @attacker) { |m| itemscore *= m }")

# item switch in score
target = Reborn ? "if i.item == :ROCKYHELMET" : "if (i.item == :ROCKYHELMET)"
UniLib.insert_in_method_before(:PokeBattle_AI, :getSwitchInScoresParty, target,
  "i.apply_item_event(:switch_item_score, self, i, @opponent) { |m| itemscore += m }")

}