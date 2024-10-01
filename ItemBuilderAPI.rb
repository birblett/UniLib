# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, File.basename(__FILE__).gsub!(".rb", ""))

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
>> builder class for adding new items
DOC
class ItemBuilder

  <<-DOC
  @param symbol - id to register under
  @param hash - hash with relevant item data, same format as ITEMHASH
  @param override - whether old entries are overridden or not
  >> creates a new item builder unless it already exists for the specified item type; otherwise overwrites existing 
     traits if specified
  DOC
  def self.add(symbol, hash, override=true)
    if CUSTOM_ITEMS[symbol].nil?
      CUSTOM_ITEMS[symbol] = ItemBuilder.new(symbol, hash)
    else
      hash.each { |key, value| CUSTOM_ITEMS[symbol][key] = value } unless override
    end
    CUSTOM_ITEMS[symbol]
  end

  <<-DOC
  @param price - a numeric price
  >> sets the shop price of an item.
  DOC
  def price(price)
    @data[:price] = price
    self
  end

  <<-DOC
  >> makes an item a battle item
  DOC
  def battle_hold
    @data[:battlehold] = true
    self
  end

  <<-DOC
  >> makes an item a berry
  DOC
  def berry
    @data[:berry] = true
    self
  end

  <<-DOC
  >> makes an item a consumable held item
  DOC
  def consume_hold
    @data[:consumehold] = true
    self
  end

  <<-DOC
  >> makes an item a crest
  DOC
  def crest
    @data[:crest] = true
    self
  end

  <<-DOC
  >> makes an item a crystal
  DOC
  def crystal
    @data[:crystal] = true
    self
  end

  <<-DOC
  >> makes an item an evo item
  DOC
  def evo_item
    @data[:evoitem] = true
    self
  end

  <<-DOC
  >> makes an item a fossil
  DOC
  def fossil
    @data[:fossil] = true
    self
  end

  <<-DOC
  >> makes an item a key item
  DOC
  def key_item
    @data[:keyitem] = true
    self
  end

  <<-DOC
  >> makes an item a level up item
  DOC
  def level_up
    @data[:levelup] = true
    self
  end

  <<-DOC
  >> makes an item an overworld item
  DOC
  def overworld
    @data[:overworld] = true
    self
  end

  <<-DOC
  >> makes an item a medicinal item
  DOC
  def medicine
    @data[:medicine] = true
    self
  end

  <<-DOC
  >> makes an item have no use in battle
  DOC
  def no_use_in_battle
    @data[:noUseInBattle] = true
    self
  end

  <<-DOC
  >> makes an item have no use
  DOC
  def no_use
    @data[:noUse] = true
    self
  end

  <<-DOC
  >> makes an item a resist berry
  DOC
  def resist_berry
    @data[:resistberry] = true
    berry
  end

  <<-DOC
  >> makes an item a status item
  DOC
  def status
    @data[:status] = true
    medicine
  end

  <<-DOC
  @param move - a move id 
  >> makes an item a tm
  DOC
  def tm(move)
    @data[:tm] = move
    self
  end

  <<-DOC
  @param type_boost - a type id of the type to be boosted
  >> makes an item a type boosting item
  DOC
  def type_boost(type_boost)
    @data[:typeBoost] = type_boost
    self
  end

  <<-DOC
  >> makes an item a z crystal
  DOC
  def z_crystal
    @data[:zcrystal] = true
    crystal
  end

end