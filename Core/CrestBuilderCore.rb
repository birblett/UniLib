# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)
unilib_include "ItemBuilder"
unilib_include "PokeModOM"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

SHOP_CRESTS = [{}, {}, {}, {}]
$custom_crest_flags = {}

CREST_STAB_OVERRIDE = {}
CREST_WEAKNESS_OVERRIDE = {}
CREST_RESIST_OVERRIDE = {}
CREST_FORCE_RESIST = {}
CREST_FORM_RESTRICTION = {}
CREST_BASE_STAT_MODS = {}
CREST_BATTLE_STAT_MODS = {}
CREST_DAMAGE_MODS = {}
CREST_ACCURACY_MODS = {}
CREST_PRIORITY_MODS = {}
CREST_HIT_COUNT_MODS = {}
CREST_TYPE_MODS = {}
CREST_DEALT_DAMAGE_EVENTS = {}
CREST_ON_DAMAGE_EVENTS = {}
CREST_ON_TURN_END_EVENTS = {}
TYPE_WEAKNESS_MAP = { :NORMAL => [:FIGHTING], :FIGHTING => [:FLYING, :PSYCHIC, :FAIRY], :FLYING => [:ROCK, :ELECTRIC, :ICE],
                      :GROUND => [:WATER, :GRASS, :ICE], :POISON => [:GROUND, :PSYCHIC],
                      :ROCK => [:FIGHTING, :GROUND, :STEEL, :WATER, :GRASS], :BUG => [:FLYING, :ROCK, :FIRE], :GHOST => [:GHOST, :DARK],
                      :STEEL => [:FIGHTING, :GROUND, :FIRE], :QMARKS => [], :FIRE => [:GROUND, :ROCK, :WATER],
                      :WATER => [:GRASS, :ELECTRIC], :GRASS => [:FLYING, :POISON, :BUG, :FIRE, :ICE], :ELECTRIC => [:GROUND],
                      :PSYCHIC => [:BUG, :GHOST, :DARK], :ICE => [:FIGHTING, :ROCK, :STEEL, :FIRE], :DRAGON => [:ICE, :DRAGON, :FAIRY],
                      :DARK => [:FIGHTING, :BUG, :FAIRY], :FAIRY => [:POISON, :STEEL] }
TYPE_IMMUNITY_MAP = { :NORMAL => [:GHOST], :FIGHTING => [], :FLYING => [:GROUND], :GROUND => [:ELECTRIC], :POISON => [], :ROCK => [],
                      :BUG => [], :GHOST => [:NORMAL, :FIGHTING], :STEEL => [:POISON], :QMARKS => [], :FIRE => [], :WATER => [],
                      :GRASS => [], :ELECTRIC => [], :PSYCHIC => [], :ICE => [], :DRAGON => [], :DARK => [:PSYCHIC], :FAIRY => [:DRAGON] }
TYPE_RESISTANCE_MAP = { :NORMAL => [], :FIGHTING => [:ROCK, :BUG, :DARK], :FLYING => [:FIGHTING, :BUG, :GRASS], :GROUND => [:POISON, :ROCK],
                        :POISON => [:FIGHTING, :POISON, :BUG, :GRASS], :ROCK => [:NORMAL, :FLYING], :BUG => [:GROUND, :GRASS],
                        :STEEL => [:NORMAL, :FIGHTING, :FLYING, :ROCK, :BUG, :STEEL, :GRASS, :PSYCHIC, :ICE, :DRAGON, :FAIRY],
                        :QMARKS => [], :FIRE => [:BUG, :FIRE, :GRASS, :ICE], :WATER => [:FIRE, :STEEL, :WATER, :ICE],
                        :GRASS => [:GROUND, :WATER, :GRASS, :ELECTRIC], :ELECTRIC => [:FLYING, :ELECTRIC],
                        :PSYCHIC => [:FIGHTING, :PSYCHIC], :ICE => [:ICE], :DRAGON => [:FIRE, :WATER, :GRASS, :ELECTRIC],
                        :DARK => [:GHOST, :DARK], :FAIRY => [:FIGHTING, :BUG, :DARK], :GHOST => [:BUG] }

class CrestBuilder < ItemBuilder

  def initialize(species, form, hash)
    super((species.to_s + "CREST").to_sym, hash)
    @species = [[species, form]]
    @tier = 1
    @essence = nil
    @secondary = nil
    @resistance_override = nil
    @stab_override = nil
    @weakness_override = nil
    @force_resistance = nil
    @base_stat_modifiers = []
    @battle_stat_modifiers = []
    @damage_modifiers = []
    @accuracy_modifiers = []
    @priority_modifiers = []
    @hit_number_modifiers = []
    @type_modifiers = []
    @on_dealt_damage_events = []
    @on_damage_events = []
    @on_turn_end = []
  end

  def build
    super
    item = $cache.items[@symbol]
    @species.each do |arr|
      species, form = arr
      PBStuff::POKEMONTOCREST[species] = @symbol
      CREST_FORM_RESTRICTION[species] = [] if CREST_FORM_RESTRICTION[species].nil?
      CREST_FORM_RESTRICTION[species].push(form)
      CREST_STAB_OVERRIDE[species] = @stab_override unless @stab_override.nil?
      CREST_WEAKNESS_OVERRIDE[species] = @weakness_override unless @weakness_override.nil?
      CREST_RESIST_OVERRIDE[species] = @resistance_override unless @resistance_override.nil?
      CREST_FORCE_RESIST[species] = @force_resistance unless @force_resistance.nil?
      unless @secondary.nil?
        add_custom_plate(@item, @secondary)
        PokeModifier.add(species).set_plates(@item)
      end
      if @base_stat_modifiers.length > 0
        CREST_BASE_STAT_MODS[[species, @symbol]] = [] if CREST_BASE_STAT_MODS[[species, @symbol]].nil?
        CREST_BASE_STAT_MODS[[species, @symbol]] += @base_stat_modifiers
      end
      if @battle_stat_modifiers.length > 0
        key = form == 0 ? species : [species, form]
        CREST_BATTLE_STAT_MODS[key] = [] if CREST_BATTLE_STAT_MODS[key].nil?
        CREST_BATTLE_STAT_MODS[key] += @battle_stat_modifiers
      end
      if @damage_modifiers.length > 0
        key = form == 0 ? species : [species, form]
        CREST_DAMAGE_MODS[key] = [] if CREST_DAMAGE_MODS[key].nil?
        CREST_DAMAGE_MODS[key] += @damage_modifiers
      end
      if @accuracy_modifiers.length > 0
        key = form == 0 ? species : [species, form]
        CREST_ACCURACY_MODS[key] = [] if CREST_ACCURACY_MODS[key].nil?
        CREST_ACCURACY_MODS[key] += @accuracy_modifiers
      end
      if @priority_modifiers.length > 0
        key = form == 0 ? species : [species, form]
        CREST_PRIORITY_MODS[key] = [] if CREST_PRIORITY_MODS[key].nil?
        CREST_PRIORITY_MODS[key] += @priority_modifiers
      end
      if @hit_number_modifiers.length > 0
        key = form == 0 ? species : [species, form]
        CREST_HIT_COUNT_MODS[key] = [] if CREST_HIT_COUNT_MODS[key].nil?
        CREST_HIT_COUNT_MODS[key] += @hit_number_modifiers
      end
      if @type_modifiers.length > 0
        key = form == 0 ? species : [species, form]
        CREST_TYPE_MODS[key] = [] if CREST_TYPE_MODS[key].nil?
        CREST_TYPE_MODS[key] += @type_modifiers
      end
      if @on_dealt_damage_events.length > 0
        key = form == 0 ? species : [species, form]
        CREST_DEALT_DAMAGE_EVENTS[key] = [] if CREST_DEALT_DAMAGE_EVENTS[key].nil?
        CREST_DEALT_DAMAGE_EVENTS[key] += @on_dealt_damage_events
      end
      if @on_damage_events.length > 0
        key = form == 0 ? species : [species, form]
        CREST_ON_DAMAGE_EVENTS[key] = [] if CREST_ON_DAMAGE_EVENTS[key].nil?
        CREST_ON_DAMAGE_EVENTS[key] += @on_damage_events
      end
      if @on_turn_end.length > 0
        key = form == 0 ? species : [species, form]
        CREST_ON_TURN_END_EVENTS[key] = [] if CREST_ON_TURN_END_EVENTS[key].nil?
        CREST_ON_TURN_END_EVENTS[key] += @on_turn_end
      end
    end
    (@tier..4).each { |tier| SHOP_CRESTS[tier - 1][@symbol] = [item, @essence]} unless @essence.nil?
  end

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def read_custom_crest_flags
  $custom_crest_flags = unilib_load_data("custom_crest_flags", {})
end

def write_custom_crest_flags
  unilib_save_data("custom_crest_flags", $custom_crest_flags)
end

add_play_event(:read_custom_crest_flags)
add_save_event(:write_custom_crest_flags)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

insert_in_method(:PokeBattle_Battler, :hasCrest?, "return true if @battle.pbGetOwnerItems(@index).include?(:SILVCREST) && crestmon.species == :SILVALLY && !@battle.pbOwnedByPlayer?(@index)", proc do |crestmon|
  unless CREST_FORM_RESTRICTION[crestmon.species].nil?
    if CREST_FORM_RESTRICTION[crestmon.species].include?(crestmon.form) and PBStuff::POKEMONTOCREST[crestmon.species]==crestmon.item
      return crestmon.form == 0 ? true : [crestmon.species, crestmon.form]
    end
    return false
  end
end)

replace_in_method(:PokeBattle_Battler, :__shadow_pbInitPokemon, "@crested = hasCrest? ? pkmn.species : false", proc do
  h = hasCrest?
  @crested = h ? (h.is_a?(Array) ? h : pkmn.species) : false
end)

insert_in_method(:Cache_Game, :map_load, "end", proc do |mapid|
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
      SHOP_CRESTS[i - 1].each do |symbol, item|
        arr[0] += ", #{item[0].name}"
        current = []
        (112..144).each { |j| current.push(Marshal.load(Marshal.dump(@cachedmaps[mapid].events[16].pages[1].list[j]))) }
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

insert_in_method(:Interpreter, :command_111, "result = false", proc do |result|
  if (@parameters[1].is_a? Symbol) and @parameters[1].to_s.start_with?("UNILIB_CREST_")
    result = !$custom_crest_flags[@parameters[1]].nil?
  else
end end)

replace_in_method(:Interpreter, :command_111, "@branch[@list[@index].indent] = result", proc do if true
  end
  @branch[@list[@index].indent] = result
end)

insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, "if opponent.crested", proc do |opponent, type, typemod|
  if opponent.crested
    vtype = CREST_WEAKNESS_OVERRIDE[opponent.species]
    b = check_type(type, vtype, TYPE_WEAKNESS_MAP)
    typemod /= 2 if b
    unless b
      vtype = CREST_RESIST_OVERRIDE[opponent.species]
      b = check_type(type, vtype, TYPE_RESISTANCE_MAP)
      typemod /= 2 if b
      unless b
        vtype = CREST_FORCE_RESIST[opponent.species]
        typemod = 2 if check_type(type, vtype, TYPE_RESISTANCE_MAP)
      end
    end
  end
end)

def check_type(type, vtype, map)
  (vtype.class == Array and vtype.include?(type)) or (map[vtype].include?(type) unless vtype.nil? or map[vtype].nil?)
end

insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested", proc do |attacker, typecrest, type|
  if attacker.crested
    vtype = CREST_WEAKNESS_OVERRIDE[attacker.species]
    typecrest = true if check_type(type, vtype, TYPE_WEAKNESS_MAP)
    unless typecrest
      vtype = CREST_RESIST_OVERRIDE[attacker.species]
      typecrest = true if check_type(type, vtype, TYPE_RESISTANCE_MAP)
      unless typecrest
        vtype = CREST_FORCE_RESIST[attacker.species]
        typecrest = true if check_type(type, vtype, TYPE_RESISTANCE_MAP)
      end
    end
  end
end, 1)

insert_in_method(:PokeBattle_Pokemon, :calcStats, "bs=self.baseStats", "CREST_BASE_STAT_MODS[[@species, @item]].each { |mod| bs = mod.call(self, bs.dup) } unless CREST_BASE_STAT_MODS[[@species, @item]].nil?")

insert_in_method(:PokeBattle_Battler, :crestStats, :HEAD, proc do
  CREST_BATTLE_STAT_MODS[self.crested].each do |mod|
    h = mod.call(self)
    h.each do |key, value|
      case key.downcase
        when :hp then @hp *= value
        when :atk then @attack *= value
        when :def then @defense *= value
        when :spa then @spatk *= value
        when :spd then @spdef *= value
        when :spe then @speed *= value
      end
    end unless h.nil?
  end unless CREST_BATTLE_STAT_MODS[self.crested].nil?
end)

insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested", proc do |attacker|
  CREST_DAMAGE_MODS[attacker.crested].each do |mod|
    modifier = mod.call(attacker, self, true)
    basemult *= modifier unless modifier.nil?
  end unless CREST_DAMAGE_MODS[attacker.crested].nil?
end, 1)

insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", proc do |attacker, hitnum|
  typecrest = true if type == CREST_STAB_OVERRIDE[attacker.crested]
  CREST_DAMAGE_MODS[attacker.crested].each do |mod|
    modifier = mod.call(attacker, self, hitnum, false)
    basemult *= modifier unless modifier.nil?
  end unless CREST_DAMAGE_MODS[attacker.crested].nil?
end)

replace_in_method(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)", proc do |attacker, baseaccuracy, accuracy, evasion|
  CREST_ACCURACY_MODS[attacker.crested].each do |mod|
    modified = mod.call(attacker, self, baseaccuracy, accuracy, evasion)
    baseaccuracy, accuracy, evasion = modified[0], modified[1], modified[2] unless modified.nil?
  end unless CREST_ACCURACY_MODS[attacker.crested].nil?
  return @battle.pbRandom(100) < (baseaccuracy * accuracy / evasion)
end)


insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER", proc do |attacker|
  CREST_PRIORITY_MODS[attacker.crested].each do |mod|
    modifier = mod.call(attacker, self)
    pri += modifier unless modifier.nil? or modifier == 0
  end unless CREST_PRIORITY_MODS[attacker.crested].nil?
end)

insert_in_method(:PokeBattle_Battle, :pbPriority, "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)", proc do
  attacker, move = @battlers[i], @choices[i][2]
  CREST_PRIORITY_MODS[attacker.crested].each do |mod|
    modifier = mod.call(attacker, move)
    pri += modifier unless modifier.nil? or modifier == 0
  end unless CREST_PRIORITY_MODS[attacker.crested].nil?
end)

insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "target.damagestate.reset", proc do |target, basemove|
  CREST_HIT_COUNT_MODS[self.crested].each do |mod|
    modifier = mod.call(self, target, basemove)
    numhits += modifier unless modifier.nil? or modifier == 0
  end unless CREST_HIT_COUNT_MODS[self.crested].nil?
end)

insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?", proc do |user, target, move, damage|
  CREST_DEALT_DAMAGE_EVENTS[user.crested].each { |event| event.call(user, target, move, damage) } unless CREST_DEALT_DAMAGE_EVENTS[user.crested].nil?
  CREST_ON_DAMAGE_EVENTS[target.crested].each { |event| event.call(user, target, move, damage) } unless CREST_ON_DAMAGE_EVENTS[target.crested].nil?
end)

insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "if i.crested == :VESPIQUEN", "CREST_ON_TURN_END_EVENTS[i.crested].each { |event| event.call(i) } unless CREST_ON_TURN_END_EVENTS[i.crested].nil?")

insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return mod1*mod2", proc do |attacker, opponent, atype, mod1, mod2|
  CREST_TYPE_MODS[attacker.crested].each do |mod|
    modifiers = mod.call(attacker, opponent, atype, mod1, mod2)
    mod1, mod2 = modifiers[0], modifiers[1] unless modifiers.nil?
  end unless CREST_TYPE_MODS[attacker.crested].nil?
end)
