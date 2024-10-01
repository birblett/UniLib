# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.4, File.basename(__FILE__).gsub!(".rb", ""))
require "Scripts/Rejuv/movetext"
require "Scripts/Rejuv/abiltext"
unilib_include "PokeMod"

# ======================================================================================================================================== #
# ================================================================ CONFIG ================================================================ #
# ======================================================================================================================================== #

BANNED_MOVES = [:ACUPRESSURE, :BELLYDRUM, :CHATTER, :EXTREMESPEED, :GEOMANCY, :LOVELYKISS, :SHELLSMASH, :SHIFTGEAR, :SPORE, :THOUSANDARROWS, :THOUSANDWAVES, :PSYCHICTERRAIN, :ELECTRICTERRAIN, :GRASSYTERRAIN, :MISTYTERRAIN, :TOPSYTURVY, :DECIMATION, :FUTUREDUMMY, :DOOMDUMMY, :BOLTBEAK, :FISHIOUSREND, :CLANGOROUSSOUL, :DECIMATION, :SOLARFLARE, :HOARFROSTMOON, :PROBOPOG, :THUNDERRAID2, :THUNDERRAID3]
BANNED_MOVES_RANGE = (641..658).to_a
BANNED_ABILITIES = [:COMATOSE,:CONTRARY, :FLUFFY, :FURCOAT, :HUGEPOWER, :ILLUSION, :IMPOSTER, :INNARDSOUT, :PARENTALBOND, :PROTEAN, :PUREPOWER, :SIMPLE, :SPEEDBOOST, :STAKEOUT, :WATERBUBBLE, :WONDERGUARD, :DELTASTREAM, :DESOLATELAND, :PRIMORDIALSEA, :DROUGHT, :DRIZZLE, :SNOWWARNING, :SANDSTREAM, :MISTYSURGE, :PSYCHICSURGE, :ELECTRICSURGE, :GRASSYSURGE, :SURGESURFER, :TELEPATHY, :SWIFTSWIM, :CHLOROPHYLL, :SANDRUSH, :SLUSHRUSH, :MOODY, :SHADOWTAG, :ARENATRAP, :DISGUISE, :STANCECHANGE]

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

PLATE_MAP = {:SILKSCARF => :NORMAL, :FISTPLATE => :FIGHTING, :SKYPLATE => :FLYING, :EARTHPLATE => :GROUND, :TOXICPLATE => :POISON, :STONEPLATE => :ROCK, :INSECTPLATE => :BUG, :SPOOKYPLATE => :GHOST, :IRONPLATE => :STEEL, :FLAMEPLATE => :FIRE, :SPLASHPLATE => :WATER, :MEADOWPLATE => :GRASS, :ZAPPLATE => :ELECTRIC, :MINDPLATE => :PSYCHIC, :ICICLEPLATE => :ICE, :DRACOPLATE => :DRAGON, :DREADPLATE => :DARK, :PIXIEPLATE => :FAIRY}
CUSTOM_PLATE_MAP = {}
TYPE_MAPPED_MOVES = {:NORMAL => [], :FIRE => [], :FIGHTING => [], :WATER => [], :FLYING => [], :GRASS => [], :POISON => [], :ELECTRIC => [], :GROUND => [], :PSYCHIC => [], :ROCK => [], :ICE => [], :BUG => [], :DRAGON => [], :GHOST => [], :DARK => [], :STEEL => [], :FAIRY => [], :QMARKS => [], :SHADOW => []}

AAA_POKEMON = {}
STAB_POKEMON = {}
PLATE_POKEMON = {}
CUSTOM_ABILITIES = []
CAMO_PROVIDER_TYPE1 = proc do |pokemon|
  next pokemon.moves[0].type unless pokemon.moves[0].nil?
  next nil
end
CAMO_PROVIDER_TYPE2 = proc do |pokemon|
  next pokemon.moves[1].type unless pokemon.moves[1].nil?
  next nil
end

MOVEHASH.each do |key, value|
  TYPE_MAPPED_MOVES[value[:type]].append(key) unless BANNED_MOVES.include?(key) or value[:ID].nil? or BANNED_MOVES_RANGE.include? value[:ID] rescue nil
end

ABILHASH.each do |key, value|
  CUSTOM_ABILITIES.push([key, value[:name]]) unless BANNED_ABILITIES.include?(key)
end


class PokeModifier

  attr_accessor(:aaa)
  attr_accessor(:stab)
  attr_accessor(:plates)
  attr_accessor(:camo)

  EVENT_POKEMODIFIER_INIT.push(proc do |modifier|
    modifier.aaa = false
    modifier.stab = false
    modifier.plates = []
    modifier.camo = false
  end)

  EVENT_POKEMODIFIER_POST_BUILD.push(proc do |modifier|
    modifier.set_aaa_internal if modifier.aaa
    if modifier.stab
      STAB_POKEMON[modifier.species] = []
      type1 = modifier.get_data(:Type1)
      type2 = modifier.get_data(:Type2)
      unless type1.nil?
        STAB_POKEMON[modifier.species].push(type1)
        modifier.egg_moves(TYPE_MAPPED_MOVES[type1])
        modifier.compatible_moves(TYPE_MAPPED_MOVES[type1])
      end
      unless type2.nil?
        STAB_POKEMON[modifier.species].push(type2)
        modifier.egg_moves(TYPE_MAPPED_MOVES[type2])
        modifier.compatible_moves(TYPE_MAPPED_MOVES[type2])
      end
    end
    modifier.set_plates_internal(modifier.plates) unless modifier.plates.empty?
    if modifier.camo
      CUSTOM_TYPE1_PROVIDERS[modifier.species] = CAMO_PROVIDER_TYPE1
      CUSTOM_TYPE2_PROVIDERS[modifier.species] = CAMO_PROVIDER_TYPE2
    end
  end)

  def set_aaa_internal
    if AAA_POKEMON[@species].nil?
      AAA_POKEMON[@species] = [@form]
    else
      AAA_POKEMON[@species].push(@form)
    end
  end

  def set_plates_internal(plates)
    PLATE_POKEMON[@species] = {} if PLATE_POKEMON[@species].nil?
    if plates == :ALL
      PLATE_POKEMON[@species][@form] = PLATE_MAP
    else
      PLATE_POKEMON[@species][@form] = []
      plates.each { |plate| PLATE_POKEMON[@species][@form].push(plate) if PLATE_MAP.include?(plate) or CUSTOM_PLATE_MAP.include?(plate) }
    end
  end
end

def ability_select(default, list)
  cmdwin=pbListWindow([],200)
  commands=[] + CUSTOM_ABILITIES
  list.each do |_, ability|
    if BANNED_ABILITIES.include?(ability)
      commands.push([ability, ABILHASH[ability][:name]])
    end
  end
  commands.sort! {|a,b| a[1]<=>b[1]}
  realcommands=[]
  commands.each { |command|
    realcommands.push(_ISPRINTF("{1:s}", command[1]))
  }
  ret=pbCommands2(cmdwin,realcommands,-1,default-1,true)
  cmdwin.dispose
  ret>=0 ? commands[ret][0] : 0
end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

insert_in_function(ItemHandlers::UseOnPokemon.instance_variable_get(:@hash)[:ABILITYCAPSULE], :HEAD, proc do |pokemon, scene|
  if !AAA_POKEMON[pokemon.species].nil? and AAA_POKEMON[pokemon.species].include?(pokemon.form)
    i = ability_select(1, pokemon.getAbilityList)
    if i != 0
      pokemon.setAbility(i)
      scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", pokemon.name, getAbilityName(pokemon.ability)))
    end
    next true
  end
end)

insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD, proc do
  return PLATE_MAP[@item] if !PLATE_POKEMON[@species].nil? and !PLATE_POKEMON[@species][@form].nil? and PLATE_POKEMON[@species][@form].include?(@item) and PLATE_MAP.include?(@item)
  return CUSTOM_PLATE_MAP[@item] if !PLATE_POKEMON[@species].nil? and !PLATE_POKEMON[@species][@form].nil? and PLATE_POKEMON[@species][@form].include?(@item) and CUSTOM_PLATE_MAP.include?(@item)
end)

insert_in_function_before(:pbGetRelearnableMoves, "return moves|[]", proc do |pokemon, moves|
  STAB_POKEMON[pokemon.species].each { |type| moves += TYPE_MAPPED_MOVES[type] unless TYPE_MAPPED_MOVES[type].nil? } unless STAB_POKEMON[pokemon.species].nil?
end)
