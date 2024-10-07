# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

CUSTOM_ITEMS = {}
INVALID_ITEMS = {}
ITEM_DATA = load_data("Data/items.dat") unless defined? ITEM_DATA

class ItemBuilder

  attr_accessor(:data)

  def initialize(symbol, hash)
    @symbol = symbol
    @data = hash
    @item = symbol

    @data[:name] = "Dummy Item" if @data[:name].nil?
    @data[:desc] = "Some Description" if @data[:desc].nil?
    @data[:price] = 0 if @data[:price].nil?
  end

  def build
    $cache.items[@symbol] = ItemData.new(@symbol, @data)
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

insert_in_function(:pbItemIconFile, :HEAD, proc do
  unless CUSTOM_ITEMS[item].nil?
    Dir.mkdir(UNILIB_ASSET_PATH) rescue nil
    name = "Data/Mods/UniLibAssets/#{item.to_s.gsub("_","").downcase}.png"
    return name if File.file?(name)
  end
end)