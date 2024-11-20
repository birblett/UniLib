# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Item"
UniLib.include "Map"
UniLib.include "Switch"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  VALID_CRESTS = {}
  SHOP_CRESTS = [{}, {}, {}, {}]

end

class CrestBuilder < ItemModifier

  def initialize(symbol, hash)
    super(symbol, hash)
    @tier = 1
    @essence = nil
    @holders = nil
    @event_hash[:crest] = true
  end

  def holders
    @holders
  end

  def build
    super
    holders = []
    @species.each do |arr|
      species, form = arr
      form == 0 ? holders.push(species) : holders.push([species, form])
    end
    VALID_CRESTS[@symbol] = self
    @holders = CrestHolder.new(holders)
    (@tier..4).each { |tier| SHOP_CRESTS[tier - 1][@symbol] = [$cache.items[@symbol], @essence]} unless @essence.nil?
  end

end unless UniLib.lib_loaded(__FILE__)

class CrestHolder

  def initialize(holders)
    @holders = holders
  end

  def ==(other)
    @holders.include? other
  end

end unless UniLib.lib_loaded(__FILE__)

class Symbol

  alias __shadow_crest_eq ===
  def ===(other)
    other.is_a?(CrestHolder) ? other == self : __shadow_crest_eq(other)
  end

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

MapEvent.add_map_event(168) do |map|
  chmap = [0, 6, 10, 14, 15]
  idmap = [0, 243, 377, 505, 535]
  (1..4).each do |i|
    to_add = []
    arr = map.events[16].pages[i].list[71].parameters
    if arr[0].gsub!(", None]", "").nil?
      arr = map.events[16].pages[i].list[72].parameters
      arr[0].gsub!(", None]", "").nil?
    end
    count = 0
    UniLib::SHOP_CRESTS[i - 1].each do |symbol, item|
      arr[0] += ", #{item[0].name}"
      current = []
      (112..144).each { |j| current.push(UniLib.deep_copy(map.events[16].pages[1].list[j])) }
      # [1][3] index
      current[1].parameters[3] = chmap[i] - 1 + count
      count += 1
      # [2][1] switch
      sym = ("UNILIB_CREST_" + symbol.to_s).to_sym
      current[2].parameters[1] = sym
      # [6][0] price text
      current[6].parameters[0] = "CAIRO: Very well, that will be #{item[1].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
      # [10][3] check price
      current[10].parameters[3] = item[1]
      # [11][4] decrement price
      current[11].parameters[4] = item[1]
      # [13][1] add item
      current[13].parameters[0] = "Kernel.pbReceiveItem(:#{symbol})"
      # [14] set switch
      current[14].instance_variable_set(:@code, 355)
      current[14].parameters[0] = "$unilib_switches[:#{sym}] = true"
      to_add += current
    end
    arr[0] += ", None]"
    map.events[16].pages[i].list[71].parameters[0].gsub!(/\\ch\[1,[0-9]+,/, "\\ch[1,#{chmap[i] + count},")
    tmp = map.events[16].pages[i].list
    map.events[16].pages[i].list = tmp[0, idmap[i]] + to_add + tmp[idmap[i] + 1, tmp.length]
    #str = ""
    #@cachedmaps[mapid].events[16].pages[i].list.each_with_index do |el, i|
    #  str += "#{i} #{el.inspect}\n"
    #end
    #unidev_log(str)
  end
end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method(:PokeBattle_Battler, :hasCrest?, "return true if @battle.pbGetOwnerItems(@index).include?(:SILVCREST) && crestmon.species == :SILVALLY && !@battle.pbOwnedByPlayer?(@index)",
  "return crestmon.form == 0 ? true : UniLib::VALID_CRESTS[crestmon.item].holders if UniLib::VALID_CRESTS[crestmon.item] and ItemModifier.has_event?(crestmon, :crest)")

UniLib.replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@crested = hasCrest? ? pkmn.species : false",
  "h = hasCrest?
  @crested = h ? (h.is_a?(CrestHolder) ? h : pkmn.species) : false")

=begin
UniLib.insert_in_method(:Cache_Game, :map_load, "end", proc do |mapid|
  if mapid == 168
    @cachedmaps[mapid] = load_data(sprintf("Data/Map%03d.rxdata", mapid))
    chmap = [0, 6, 10, 14, 15]
    idmap = [0, 243, 377, 505, 535]
    (1..4).each do |i|
      to_add = []
      arr = @cachedmaps[mapid].events[16].pages[i].list[71].parameters
      if arr[0].gsub!(", None]", "").nil?
        arr = @cachedmaps[mapid].events[16].pages[i].list[72].parameters
        arr[0].gsub!(", None]", "").nil?
      end
      count = 0
      UniLib::SHOP_CRESTS[i - 1].each do |symbol, item|
        arr[0] += ", #{item[0].name}"
        current = []
        (112..144).each { |j| current.push(UniLib.deep_copy(@cachedmaps[mapid].events[16].pages[1].list[j])) }
        # [1][3] index
        current[1].parameters[3] = chmap[i] - 1 + count
        count += 1
        # [2][1] switch
        sym = ("UNILIB_CREST_" + symbol.to_s).to_sym
        current[2].parameters[1] = sym
        # [6][0] price text
        current[6].parameters[0] = "CAIRO: Very well, that will be #{item[1].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
        # [10][3] check price
        current[10].parameters[3] = item[1]
        # [11][4] decrement price
        current[11].parameters[4] = item[1]
        # [13][1] add item
        current[13].parameters[0] = "Kernel.pbReceiveItem(:#{symbol})"
        # [14] set switch
        current[14].instance_variable_set(:@code, 355)
        current[14].parameters[0] = "$custom_crest_flags[:#{sym}] = true"
        to_add += current
      end
      arr[0] += ", None]"
      @cachedmaps[mapid].events[16].pages[i].list[71].parameters[0].gsub!(/\\ch\[1,[0-9]+,/, "\\ch[1,#{chmap[i] + count},")
      tmp = @cachedmaps[mapid].events[16].pages[i].list
      @cachedmaps[mapid].events[16].pages[i].list = tmp[0, idmap[i]] + to_add + tmp[idmap[i] + 1, tmp.length]
      #str = ""
      #@cachedmaps[mapid].events[16].pages[i].list.each_with_index do |el, i|
      #  str += "#{i} #{el.inspect}\n"
      #end
      #unidev_log(str)
    end
  end
end)
=end