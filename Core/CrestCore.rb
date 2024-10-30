# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)
unilib_include "Item"
unilib_include "PokemonOM"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

CUSTOM_CRESTS = {}
CUSTOM_CREST_MAP = {}
SHOP_CRESTS = [{}, {}, {}, {}]
$custom_crest_flags = {}
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

class CrestBuilder

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
  attr_accessor(:on_turn_end)

  def initialize(symbol, species, form)
    @symbol = symbol
    @species = [[species, form]]
    @tier = 1
    @essence = nil
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
    @on_turn_end = []
  end

  def affects?(pkmn, form)
    @species.include? [pkmn, form]
  end

  def build
    CUSTOM_CREST_MAP[@symbol] = self
    @species.each do |arr|
      species, form = arr
      unless @secondary.nil?
        add_custom_plate(@symbol, @secondary)
        PokeModifier.add(species, form).set_plates(@symbol)
      end
    end
    (@tier..4).each { |tier| SHOP_CRESTS[tier - 1][@symbol] = [$cache.items[@symbol], @essence]} unless @essence.nil?
  end

end

class NumberContainer

  def self.of(*numbers)
    numbers.map { |n| new(n) }
  end

  def initialize(number)
    @number = number
  end

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def crests_init
  CUSTOM_CRESTS.each { |_, crest| crest.build }
  $custom_crest_flags = unilib_load_data("custom_crest_flags", {})
end

def write_custom_crest_flags
  unilib_save_data("custom_crest_flags", $custom_crest_flags)
end

add_play_event(:crests_init)
add_save_event(:write_custom_crest_flags)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

insert_in_method(:PokeBattle_Battler, :hasCrest?, "return true if @battle.pbGetOwnerItems(@index).include?(:SILVCREST) && crestmon.species == :SILVALLY && !@battle.pbOwnedByPlayer?(@index)", "return crestmon.form == 0 ? true : [crestmon.species, crestmon.form] if !CUSTOM_CREST_MAP[crestmon.item].nil? and CUSTOM_CREST_MAP[crestmon.item].affects?(crestmon.species, crestmon.form)")

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

def check_type(type, vtypes, map)
  vtypes.each { |vtype| return map[vtype].include?(type) unless map[vtype].nil? }
  nil
end

insert_in_method_before(:PokeBattle_Move, :pbTypeModMessages, "if opponent.crested", proc do |opponent, type, typemod|
  if opponent.crested and CUSTOM_CREST_MAP[opponent.item]
    typemod = CUSTOM_CREST_MAP[opponent.item].forced_resistances[type] if (b = !CUSTOM_CREST_MAP[opponent.item].forced_resistances[type].nil?)
    unless b
      typemod /= 2 if (b = check_type(type, CUSTOM_CREST_MAP[opponent.item].weakness_fakes, TYPE_WEAKNESS_MAP))
      unless b
        typemod /= 2 if check_type(type, CUSTOM_CREST_MAP[opponent.item].resistance_fakes, TYPE_RESISTANCE_MAP)
      end
    end
  end
end)

insert_in_method(:PokeBattle_Move, :pbCalcDamage, "typecrest = false", proc do |attacker, type|
  typecrest = true if attacker.crested and !CUSTOM_CREST_MAP[attacker.item].nil? and CUSTOM_CREST_MAP[attacker.item].stab_overrides == type
end)

insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested", proc do |attacker, type|
  typecrest = true if attacker.crested and !CUSTOM_CREST_MAP[attacker.item].nil? and CUSTOM_CREST_MAP[attacker.item].stab_overrides == type
end, 1)

insert_in_method(:PokeBattle_Pokemon, :calcStats, "bs=self.baseStats", proc do |bs|
  if CUSTOM_CREST_MAP[@item].affects?(@species, @form)
    stats = NumberContainer.of(*bs)
    CUSTOM_CREST_MAP[@item].base_stat_modifiers.each { |mod| mod.call(self, stats) }
    bs = stats.map { |n| n.value }
  end unless CUSTOM_CREST_MAP[@item].nil?
end)

insert_in_method(:PokeBattle_Battler, :crestStats, :HEAD, proc do
  if @crested
    stats = NumberContainer.of(@hp, @attack, @defense, @spatk, @spdef, @speed)
    CUSTOM_CREST_MAP[@item].battle_stat_modifiers.each { |mod| mod.call(self, stats) }
    @hp, @attack, @defense, @spatk, @spdef, @speed = *stats.map { |n| n.value }
  end unless CUSTOM_CREST_MAP[@item].nil?
end)

insert_in_method_before(:PokeBattle_AI, :pbRoughDamage, "case attacker.crested", proc do |attacker, opponent|
  CUSTOM_CREST_MAP[attacker.item].damage_modifiers.each do |mod|
    modifier = mod.call(attacker, opponent, self, self.pbNumHits, true)
    basemult *= modifier unless modifier.nil?
  end if attacker.crested unless CUSTOM_CREST_MAP[attacker.item].nil?
end, 1)

insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "case attacker.ability", proc do |attacker, opponent, hitnum|
  CUSTOM_CREST_MAP[attacker.item].damage_modifiers.each do |mod|
    modifier = mod.call(attacker, opponent, self, hitnum, false)
    basemult *= modifier unless modifier.nil?
  end if attacker.crested unless CUSTOM_CREST_MAP[attacker.item].nil?
end)

replace_in_method(:PokeBattle_Move, :pbAccuracyCheck, "return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)", proc do |attacker, baseaccuracy, accuracy, evasion|
  CUSTOM_CREST_MAP[attacker.item].accuracy_modifiers.each do |mod|
    modified = mod.call(attacker, self, baseaccuracy, accuracy, evasion)
    baseaccuracy, accuracy, evasion = *modified unless modified.nil?
  end if attacker.crested unless CUSTOM_CREST_MAP[attacker.item].nil?
  return @battle.pbRandom(100) < (baseaccuracy * accuracy / evasion)
end)

insert_in_method(:PokeBattle_Move, :priorityCheck, "pri -= 1 if @battle.FE == :DEEPEARTH && @move == :COREENFORCER", proc do |attacker|
  CUSTOM_CREST_MAP[attacker.item].priority_modifiers.each do |mod|
    modifier = mod.call(attacker, self)
    pri += modifier unless modifier.nil?
  end if attacker.crested unless CUSTOM_CREST_MAP[attacker.item].nil?
end)

insert_in_method(:PokeBattle_Battle, :pbPriority, "pri += 3 if @battlers[i].ability == :TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)", proc do
  attacker, move = @battlers[i], @choices[i][2]
  CUSTOM_CREST_MAP[attacker.item].priority_modifiers.each do |mod|
    modifier = mod.call(attacker, move)
    pri += modifier unless modifier.nil?
  end if attacker.crested unless CUSTOM_CREST_MAP[attacker.item].nil?
end)

insert_in_method_before(:PokeBattle_Battler, :pbUseMove, "target.damagestate.reset", proc do |target, basemove|
  CUSTOM_CREST_MAP[@item].hit_number_modifiers.each do |mod|
    modifier = mod.call(self, target, basemove)
    numhits += modifier unless modifier.nil?
  end if @crested unless CUSTOM_CREST_MAP[@item].nil?
end)

insert_in_method(:PokeBattle_Move, :pbType, :HEAD, proc do |attacker, type|
  CUSTOM_CREST_MAP[attacker.item].move_type_overrides.each do |mod|
    tmp = mod.call(attacker, self, type)
    type = tmp unless tmp.nil?
  end if attacker.crested unless CUSTOM_CREST_MAP[attacker.item].nil?
end)

insert_in_method_before(:PokeBattle_Move, :pbCalcDamage, "if attacker.ability == :HUSTLE && pbIsPhysical?(type)", proc do |attacker, opponent|
  CUSTOM_CREST_MAP[attacker.item].move_stat_overrides.each do |mod|
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
  end if attacker.crested unless CUSTOM_CREST_MAP[attacker.item].nil?
end)

insert_in_method_before(:PokeBattle_Battle, :pbCrestEffects, "case @battlers[index].crested", proc do |index|
    pkmn = @battlers[index]
    CUSTOM_CREST_MAP[pkmn.item].on_battle_entry_events.each { |event| event.call(pkmn, pkmn.battle, index) } if pkmn.crested unless CUSTOM_CREST_MAP[pkmn.item].nil?
end)

insert_in_method(:PokeBattle_Battler, :pbEffectsOnDealingDamage, "return if target.nil?", proc do |user, target, move, damage|
  CUSTOM_CREST_MAP[user.item].on_damage_dealt.each { |event| event.call(user, target, move, damage) } if user.crested unless CUSTOM_CREST_MAP[user.item].nil?
  CUSTOM_CREST_MAP[target.item].on_damage_taken.each { |event| event.call(user, target, move, damage) } if user.crested unless CUSTOM_CREST_MAP[target.item].nil?
end)

insert_in_method_before(:PokeBattle_Battle, :__clauses__pbEndOfRoundPhase, "if i.crested == :VESPIQUEN", "CUSTOM_CREST_MAP[i.item].on_turn_end.each { |event| event.call(i) } if i.crested unless CUSTOM_CREST_MAP[i.item].nil?")

insert_in_method_before(:PokeBattle_Move, :pbTypeModifier, "return mod1*mod2", proc do |attacker, opponent, atype, mod1, mod2|
  CUSTOM_CREST_MAP[attacker.item].type_modifiers.each do |mod|
    modifiers = mod.call(attacker, opponent, atype, mod1, mod2)
    mod1, mod2 = modifiers[0], modifiers[1] unless modifiers.nil?
  end if attacker.crested unless CUSTOM_CREST_MAP[attacker.item].nil?
end)
