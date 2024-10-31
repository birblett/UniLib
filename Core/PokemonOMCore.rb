# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)
unilib_include "Pokemon"
unilib_include "Move"
unilib_include "Ability"
unilib_include "Multibility"

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
ALPHABET_MOVES = ("a".."z").to_a.map.to_h { |letter| [letter, []] }

AAA_POKEMON = {}
STAB_POKEMON = {}
PLATE_POKEMON = {}
ALPHABET_POKEMON = {}
POKEBILITIES_POKEMON = {}
CUSTOM_POKEMON_ABILITIES = []
CAMO_PROVIDER_TYPE1 = proc do |pokemon|
  next pokemon.moves[0].type unless pokemon.moves[0].nil?
  next nil
end
CAMO_PROVIDER_TYPE2 = proc do |pokemon|
  next pokemon.moves[1].type unless pokemon.moves[1].nil?
  next nil
end
POKEBILITY_PROC = proc { |pkmn, _| next pkmn.getAbilityList }

MOVE_DATA.each do |key, value|
  TYPE_MAPPED_MOVES[value.type].append(key) unless BANNED_MOVES.include?(key) or value.flags[:ID].nil? or BANNED_MOVES_RANGE.include? value.flags[:ID] rescue nil
  ALPHABET_MOVES[letter = key.to_s[0].downcase].append(key) unless BANNED_MOVES.include?(key) or value.flags[:ID].nil? or BANNED_MOVES_RANGE.include? value.flags[:ID] rescue nil
end

ABILITY_DATA.each do |key, value|
  CUSTOM_POKEMON_ABILITIES.push([key, value.name]) unless BANNED_ABILITIES.include?(key)
end

class PokeModifier

  attr_accessor(:aaa)
  attr_accessor(:stab)
  attr_accessor(:plates)
  attr_accessor(:camo)
  attr_accessor(:alphabet)
  attr_accessor(:pokebilities)

  EVENT_POKEMODIFIER_INIT.push(proc do |modifier|
    modifier.aaa = false
    modifier.stab = false
    modifier.plates = []
    modifier.camo = false
    modifier.alphabet = []
    modifier.pokebilities = false
  end)

  EVENT_POKEMODIFIER_POST_BUILD.push(proc do |modifier|
    modifier.set_aaa_internal if modifier.aaa
    key = [modifier.species, modifier.form]
    if modifier.stab
      STAB_POKEMON[key] = []
      type1 = modifier.get_data(:Type1)
      type2 = modifier.get_data(:Type2)
      unless type1.nil?
        STAB_POKEMON[key].push(type1)
        modifier.egg_moves(TYPE_MAPPED_MOVES[type1])
        modifier.compatible_moves(TYPE_MAPPED_MOVES[type1])
      end
      unless type2.nil?
        STAB_POKEMON[key].push(type2)
        modifier.egg_moves(TYPE_MAPPED_MOVES[type2])
        modifier.compatible_moves(TYPE_MAPPED_MOVES[type2])
      end
    end
    ALPHABET_POKEMON[key] = modifier.alphabet if modifier.alphabet.length > 0
    modifier.set_plates_internal(modifier.plates) unless modifier.plates.empty?
    if modifier.camo
      CUSTOM_TYPE1_PROVIDERS[key] = CAMO_PROVIDER_TYPE1
      CUSTOM_TYPE2_PROVIDERS[key] = CAMO_PROVIDER_TYPE2
    end
    POKEBILITIES_POKEMON[key] = true if modifier.pokebilities
  end)

  def set_aaa_internal
    AAA_POKEMON[[@species, @form]] = true
  end

  def set_plates_internal(plates)
    key = [@species, @form]
    if plates == :ALL
      PLATE_POKEMON[key] = PLATE_MAP
    else
      PLATE_POKEMON[key] = []
      plates.each { |plate| PLATE_POKEMON[key].push(plate) if PLATE_MAP.include?(plate) or CUSTOM_PLATE_MAP.include?(plate) }
    end
  end
end

def ability_select(default, list)
  cmdwin=pbListWindow([], 200)
  commands=[] + CUSTOM_POKEMON_ABILITIES
  list.each { |_, ability| commands.push([ability, ABILITY_DATA[ability].name]) if BANNED_ABILITIES.include?(ability) }
  commands.sort! {|a,b| a[1]<=>b[1]}
  realcommands=[]
  commands.each { |command| realcommands.push(_ISPRINTF("{1:s}", command[1])) }
  ret=pbCommands2(cmdwin,realcommands,-1,default-1,true)
  cmdwin.dispose
  ret>=0 ? commands[ret][0] : 0
end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

insert_in_function(ItemHandlers::UseOnPokemon.instance_variable_get(:@hash)[:ABILITYCAPSULE], :HEAD,
  "key = [pokemon.species, pokemon.form]
  if POKEBILITIES_POKEMON[key]
    scene.pbDisplay(_INTL(\"It won't have any effect.\"))
    next false
  end
  unless AAA_POKEMON[key].nil?
    i = ability_select(1, pokemon.getAbilityList)
    if i != 0
      pokemon.setAbility(i)
      scene.pbDisplay(_INTL(\"{1}'s ability was changed to {2}!\", pokemon.name, getAbilityName(pokemon.ability)))
    end
    next true
  end")

insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
  "key = [@species, @form]
  return PLATE_MAP[@item] if !PLATE_POKEMON[key].nil? and PLATE_POKEMON[key].include?(@item) and PLATE_MAP.include?(@item)
  return CUSTOM_PLATE_MAP[@item] if !PLATE_POKEMON[key].nil? and PLATE_POKEMON[key].include?(@item) and CUSTOM_PLATE_MAP.include?(@item)")

insert_in_function_before(:pbGetRelearnableMoves, "return moves|[]",
  "key = [pokemon.species, pokemon.form]
  STAB_POKEMON[key].each { |type| moves |= TYPE_MAPPED_MOVES[type] unless TYPE_MAPPED_MOVES[type].nil? } unless STAB_POKEMON[key].nil?
  ALPHABET_POKEMON[key].each { |letter| moves |= ALPHABET_MOVES[letter] unless ALPHABET_MOVES[letter].nil? } unless ALPHABET_POKEMON[key].nil?")

insert_in_method(:PokemonSummaryScene, :drawAbilPage, "memo+=_INTL(\"<c3=F8F8F8,686868>Ability:<c3=404040,B0B0B0>\n\")", "abilname = \"Pokebilities\" if POKEBILITIES_POKEMON[[@pokemon.species, @pokemon.form]]")

insert_in_method(:PokemonSummaryScene, :drawPageThree, "abilitydesc = abil.nil? ? (@pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : abil.desc",
  "if POKEBILITIES_POKEMON[[@pokemon.species, @pokemon.form]]
    abilityname = \"Pokebilities\"
    list = @pokemon.getAbilityList
    abilitydesc = ""
    list.each { |abil| abilitydesc += getAbilityName(abil, true) + (abil != list.last ? \" + \" : \".\")}
  end")

insert_in_method(:PokemonSummaryScene, :drawPageFour, "abilitydesc = abil.nil? ? (pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : abil.desc",
  "if POKEBILITIES_POKEMON[[pokemon.species, pokemon.form]]
    abilityname = \"Pokebilities\"
    list = pokemon.getAbilityList
    abilitydesc = ""
    list.each { |abil| abilitydesc += getAbilityName(abil, true) + (abil != list.last ? \" + \" : \".\")}
  end")

insert_in_method(:PokemonStorageScene, :pbUpdateOverlay, "abilityname=getAbilityName(pokemon.ability)", "abilityname = \"Pokebilities\" if POKEBILITIES_POKEMON[[pokemon.species, pokemon.form]]")

insert_in_method(:PokeBattle_Pokemon, :initAbility, :TAIL, "@ability = abillist[0] if POKEBILITIES_POKEMON[[@species, @form]]")