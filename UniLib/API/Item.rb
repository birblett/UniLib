# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
>> builder class for explicitly creating new items
DOC
module ItemBuilder

  <<-DOC
  @param symbol - id to register under
  @param name - item name, string
  @param desc - item description, string
  @param price - item price, number, optional
  >> creates a new item builder unless it already exists for the specified item type; otherwise overwrites existing 
     traits if specified
  DOC
  def self.add(symbol, name, desc, price=0)
    name = "Dummy Item" if name.nil?
    desc = "Dummy Description" if desc.nil?
    ItemModifier.add(symbol)
                .name(name)
                .desc(desc)
                .price(price)
  end

end

<<-DOC
>> modifier class for modifying items
DOC
class ItemModifier

  <<-DOC
  @param symbol - id to register under
  @param hash - hash with relevant item data, same format as ITEMHASH
  >> creates a new item builder unless it already exists for the specified item type; otherwise overwrites existing 
     traits if specified
  DOC
  def self.add(symbol, hash={})
    CUSTOM_ITEMS[symbol] = ItemModifier.new(symbol, hash) if CUSTOM_ITEMS[symbol].nil?
    CUSTOM_ITEMS[symbol]
  end

  <<-DOC
  @param name - item name as a string
  >> sets the name of an item.
  DOC
  def name(name)
    return self if UniLib.cached(UniLib::ITEM)
    @data[:name] = name
    self
  end

  <<-DOC
  @param desc - item description as a string
  >> sets the description of an item.
  DOC
  def desc(desc)
    return self if UniLib.cached(UniLib::ITEM)
    @data[:desc] = desc
    self
  end

  <<-DOC
  @param price - a numeric price
  >> sets the shop price of an item.
  DOC
  def price(price)
    return self if UniLib.cached(UniLib::ITEM)
    @data[:price] = price
    self
  end

  <<-DOC
  >> makes an item a battle item
  DOC
  def battle_hold
    return self if UniLib.cached(UniLib::ITEM)
    @data[:battlehold] = true
    self
  end

  <<-DOC
  >> makes an item a berry
  DOC
  def berry
    return self if UniLib.cached(UniLib::ITEM)
    @data[:berry] = true
    self
  end

  <<-DOC
  >> makes an item a consumable held item
  DOC
  def consume_hold
    return self if UniLib.cached(UniLib::ITEM)
    @data[:consumehold] = true
    self
  end

  <<-DOC
  >> makes an item a crest
  DOC
  def crest
    return self if UniLib.cached(UniLib::ITEM)
    @data[:crest] = true
    self
  end

  <<-DOC
  >> makes an item a crystal
  DOC
  def crystal
    return self if UniLib.cached(UniLib::ITEM)
    @data[:crystal] = true
    self
  end

  <<-DOC
  >> makes an item an evo item
  DOC
  def evo_item
    return self if UniLib.cached(UniLib::ITEM)
    @data[:evoitem] = true
    self
  end

  <<-DOC
  >> makes an item a fossil
  DOC
  def fossil
    return self if UniLib.cached(UniLib::ITEM)
    @data[:fossil] = true
    self
  end

  <<-DOC
  >> makes an item a key item
  DOC
  def key_item
    return self if UniLib.cached(UniLib::ITEM)
    @data[:keyitem] = true
    self
  end

  <<-DOC
  >> makes an item a level up item
  DOC
  def level_up
    return self if UniLib.cached(UniLib::ITEM)
    @data[:levelup] = true
    self
  end

  <<-DOC
  >> makes an item an overworld item
  DOC
  def overworld
    return self if UniLib.cached(UniLib::ITEM)
    @data[:overworld] = true
    self
  end

  <<-DOC
  >> makes an item a medicinal item
  DOC
  def medicine
    return self if UniLib.cached(UniLib::ITEM)
    @data[:medicine] = true
    self
  end

  <<-DOC
  >> makes an item have no use in battle
  DOC
  def no_use_in_battle
    return self if UniLib.cached(UniLib::ITEM)
    @data[:noUseInBattle] = true
    self
  end

  <<-DOC
  >> makes an item have no use
  DOC
  def no_use
    return self if UniLib.cached(UniLib::ITEM)
    @data[:noUse] = true
    self
  end

  <<-DOC
  >> makes an item a resist berry
  DOC
  def resist_berry
    return self if UniLib.cached(UniLib::ITEM)
    @data[:resistberry] = true
    self
  end

  <<-DOC
  >> makes an item a status item
  DOC
  def status
    return self if UniLib.cached(UniLib::ITEM)
    @data[:status] = true
    self
  end

  <<-DOC
  @param move - a move id 
  >> makes an item a tm
  DOC
  def tm(move)
    return self if UniLib.cached(UniLib::ITEM)
    @data[:tm] = move
    self
  end

  <<-DOC
  @param type_boost - a type id of the type to be boosted
  >> makes an item a type boosting item
  DOC
  def type_boost(type_boost)
    return self if UniLib.cached(UniLib::ITEM)
    @data[:typeBoost] = type_boost
    self
  end

  <<-DOC
  >> makes an item a z crystal
  DOC
  def z_crystal
    return self if UniLib.cached(UniLib::ITEM)
    @data[:zcrystal] = true
    self
  end

  <<-DOC
  >> makes an item unlosable, or optionally makes it conditional. provided blocks take a single PokeBattle_Pokemon argument.
  DOC
  def unlosable(func=nil, &block)
    return self if UniLib.cached(UniLib::ITEM)
    UNLOSABLE_ITEMS[@symbol] = [] unless UNLOSABLE_ITEMS[@symbol]
    fn = block ? block : func
    UNLOSABLE_ITEMS[@symbol].push(fn ? fn : UNLOSABLE_DEFAULT_CONDITION)
    self
  end

  <<-DOC
  @param holder - pokemon id
  @param form - form string or number
  >> allows battle items to be proc'd with this pokemon
  DOC
  def add_receiver(holder, form = 0)
    return self if UniLib.cached(UniLib::ITEM)
    @species = :ALL if holder == :ALL
    return self if @species == :ALL
    form = UniLib.get_form_number(holder, form)[0]
    @species.push([holder, form]) unless @species.include? [holder, form]
    self
  end

  <<-DOC
  @param proc - a function returning an ability symbol (or array of them).
  >> a conditional ability provider. accepts 2 arguments, the user (PokeBattle_Pokemon) and its current abilities (array of symbols).
     return an ability symbol or array of them; 
  DOC
  def ability_provider(proc=nil, &block)
    return self if UniLib.cached(UniLib::ITEM)
    if proc.nil? and block.nil?
      print "No function or block provided for event ability_provider of #{@symbol}:#{self.class}"
      exit
    else
      @ability_providers.push(proc ? proc : block)
    end
    self
  end

  <<-DOC
  @param proc - a function returning a float multiplier.
  >> a conditional form provider, accepts 2 arguments, the calling AI instance (PokeBattle_AI) and the calling pokemon (PokeBattle_Pokemon); 
     returns an item score multiplier corresponding to the item. see PokeBattle_AI$getItemScore
  DOC
  def item_score(proc=nil, &block)
    return self if UniLib.cached(UniLib::EVENTS)
    add_or_create_event(:item_score, proc, block)
  end

  <<-DOC
  @param proc - a function returning an integer adder.
  >> a conditional form provider, accepts 3 arguments, the calling AI instance (PokeBattle_AI), possible switch (PokeBattle_Pokemon), and
     the target (PokeBattle_Pokemon); returns an item score adder corresponding to the item. see PokeBattle_AI$getSwitchInScoresParty
  DOC
  def switch_item_score(proc=nil, &block)
    return self if UniLib.cached(UniLib::EVENTS)
    add_or_create_event(:switch_item_score, proc, block)
  end

  <<-DOC
  >> returns the item symbol
  DOC
  def sym
    @symbol
  end

  <<-DOC
  @param pkmn - the pokemon whose item is consumed (PokeBattle_Battler)
  >> flags a pokemon's item as consumed in-battle. safe to call when when doing ai calculations.
  DOC
  def self.set_consumed_item(pkmn)
    CONSUMED_ITEM.push(pkmn) if $should_consume_item
  end

end