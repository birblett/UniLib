# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
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

  self.add_listeners(1, :item_event_value, :apply_item_event)

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

  self.add_listeners(1, :item_event_value, :apply_item_event)

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

UniLib.insert_in_function(:pbItemIconFile, :HEAD,
  "unless UniLib::CUSTOM_ITEMS[item].nil?
    Dir.mkdir(UNILIB_ASSET_PATH) rescue nil
    name = \"Data/Mods/UniLibAssets/\#{item.to_s.gsub(\"_\", \"\").downcase}.png\"
    return name if File.file?(name)
    name = \"Data/Mods/UniLibAssets/Items/\#{item.to_s.gsub(\"_\", \"\").downcase}.png\"
    return name if File.file?(name)
  end")

# unlosable item
UniLib.insert_in_method(:PokeBattle_Battle, :pbIsUnlosableItem, :HEAD,
  "UniLib::UNLOSABLE_ITEMS[item].each { |cond| return true if cond.call(pkmn) } if UniLib::UNLOSABLE_ITEMS[item]")

# item update
UniLib.insert_in_method(:PokeBattle_Battler, :pbDisposeItem, :HEAD, "b = !@item.nil? and UniLib::EVENT_ITEMS[@item]")

# item update
UniLib.insert_in_method(:PokeBattle_Battler, :pbDisposeItem, :TAIL, "self.pbUpdate(false) if b")

# item score
target = Reborn ? "itemscore -= 100" : "itemscore-=100"
UniLib.insert_in_method_before(:PokeBattle_AI, :getItemScore, target,
  "@attacker.apply_item_event(:item_score, self, @attacker) { |m| itemscore *= m }")

# item switch in score
target = Reborn ? "if i.item == :ROCKYHELMET" : "if (i.item == :ROCKYHELMET)"
UniLib.insert_in_method_before(:PokeBattle_AI, :getSwitchInScoresParty, target,
  "i.apply_item_event(:switch_item_score, self, i, @opponent) { |m| itemscore += m }")