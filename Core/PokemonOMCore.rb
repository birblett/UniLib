# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Pokemon"
UniLib.include "Move"
UniLib.include "Ability"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  unless lib_loaded(__FILE__)

    BANNED_ATTACKS = [:ASTRALBARRAGE, :BOLTBEAK, :CHATTER, :CLANGOROUSSOUL, :DECIMATION, :DOUBLEIRONBASH, :EXTREMESPEED, :FISHIOUSREND,
                      :THOUSANDARROWS, :THOUSANDWAVES, :VCREATE]
    BANNED_SETUP_MOVES = [:ACUPRESSURE, :BELLYDRUM, :GEOMANCY, :QUIVERDANCE, :SHELLSMASH, :SHIFTGEAR, :TAILGLOW]
    BANNED_INCOMPETITIVE_MOVES = [:DARKVOID, :FISSURE, :GRASSWHISTLE, :GUILLOTINE, :HORNDRILL, :HYPNOSIS, :LOVELYKISS, :SHEERCOLD,
                                  :SLEEPPOWDER, :SPORE]
    BANNED_TERRAIN_MOVES = [:PSYCHICTERRAIN, :ELECTRICTERRAIN, :GRASSYTERRAIN, :MISTYTERRAIN, :TOPSYTURVY]
    BANNED_ILLEGAL_MOVES = [:COMEUPPANCE, :DOOMDUMMY, :FUTUREDUMMY, :HOARFROSTMOON, :SOLARFLARE, :PROBOPOG, :STRUGGLE, :SPARKLEON,
                            :THUNDERRAID2, :THUNDERRAID3, :ULTRAMEGADEATH]

    BANNED_MOVES = BANNED_SETUP_MOVES + BANNED_INCOMPETITIVE_MOVES + BANNED_ATTACKS + BANNED_TERRAIN_MOVES + BANNED_ILLEGAL_MOVES

    BANNED_MOVES_RANGE = (641..658).to_a

    TYPE_MAPPED_MOVES = {:NORMAL => [], :FIRE => [], :FIGHTING => [], :WATER => [], :FLYING => [], :GRASS => [], :POISON => [],
                         :ELECTRIC => [], :GROUND => [], :PSYCHIC => [], :ROCK => [], :ICE => [], :BUG => [], :DRAGON => [],
                         :GHOST => [], :DARK => [], :STEEL => [], :FAIRY => [], :QMARKS => [], :SHADOW => []}

    ALPHABET_MOVES = ("a".."z").to_a.map.to_h { |letter| [letter, []] }

    MOVE_DATA.each do |key, value|
      TYPE_MAPPED_MOVES[value.type].append(key) unless BANNED_MOVES.include?(key) or value.flags[:ID].nil? or BANNED_MOVES_RANGE.include? value.flags[:ID] rescue nil
      ALPHABET_MOVES[letter = key.to_s[0].downcase].append(key) unless BANNED_MOVES.include?(key) or value.flags[:ID].nil? or BANNED_MOVES_RANGE.include? value.flags[:ID] rescue nil
    end

    BANNED_OVERPOWERED_ABILITIES = [:CONTRARY, :FLUFFY, :FURCOAT, :GORILLATACTICS, :HUGEPOWER, :INTREPIDSWORD, :LIBERO, :PARENTALBOND,
                                    :PROTEAN, :PUREPOWER, :SIMPLE, :SPEEDBOOST, :STAKEOUT, :WATERBUBBLE]
    BANNED_UNCOMPETITIVE_ABILITIES = [:ARENATRAP, :COMATOSE, :ILLUSION, :IMPOSTER, :INNARDSOUT, :MOODY, :SHADOWTAG, :WONDERGUARD, :TRIAGE]
    BANNED_SPEED_ABILITIES = [:CHLOROPHYLL, :SANDRUSH, :SLUSHRUSH, :SURGESURFER, :SWIFTSWIM, :TELEPATHY]
    BANNED_SETTING_ABILITIES = [:DELTASTREAM, :DESOLATELAND, :DRIZZLE, :DROUGHT, :ELECTRICSURGE, :GRASSYSURGE, :MISTYSURGE,
                                :PRIMORDIALSEA, :PSYCHICSURGE, :SANDSTREAM, :SNOWWARNING]
    BANNED_USELESS_ABILITIES = [:DISGUISE, :FLOWERGIFT, :GULPMISSILE, :HUNGERSWITCH, :ICEFACE, :MULTITYPE, :RKSSYSTEM, :POWERCONSTRUCT,
                                :SHIELDSDOWN, :STANCECHANGE, :ZENMODE]
    BANNED_ILLEGAL_ABILITIES = [:ACCUMULATION, :EXECUTION, :INEXORABLE, :LUNARIDOL, :NEUTRALIZINGGAS, :PRISMPOWER, :REFLECTOR,
                                :SOLARIDOL, :STOPPN, :TEMPEST, :TEMPORALSHIFT, :TRUESHOT, :WORLDOFNIGHTMARES]

    BANNED_ABILITIES = BANNED_OVERPOWERED_ABILITIES + BANNED_UNCOMPETITIVE_ABILITIES + BANNED_SPEED_ABILITIES + BANNED_SETTING_ABILITIES +
      BANNED_USELESS_ABILITIES + BANNED_ILLEGAL_ABILITIES

    POKEBILITY_PROC = proc { |pkmn, _| next pkmn.getAbilityList }

    def self.ability_select(default, list)
      cmdwin=pbListWindow([], 200)
      tmp = UniLib::CUSTOM_ABILITIES.map { |k, v| [k, v.name] }
      commands=[] + CUSTOM_POKEMON_ABILITIES + tmp
      list.each { |_, ability| commands.push([ability, UniLib::ABILITY_DATA[ability].name]) if BANNED_ABILITIES.include?(ability) }
      commands.sort! {|a,b| a[1]<=>b[1]}
      realcommands=[]
      commands.each { |command| realcommands.push(_ISPRINTF("{1:s}", command[1])) }
      ret=pbCommands2(cmdwin,realcommands,-1,default-1,true)
      cmdwin.dispose
      ret>=0 ? commands[ret][0] : 0
    end

    PLATE_MAP = {:SILKSCARF => :NORMAL, :FISTPLATE => :FIGHTING, :SKYPLATE => :FLYING, :EARTHPLATE => :GROUND, :TOXICPLATE => :POISON,
                 :STONEPLATE => :ROCK, :INSECTPLATE => :BUG, :SPOOKYPLATE => :GHOST, :IRONPLATE => :STEEL, :FLAMEPLATE => :FIRE,
                 :SPLASHPLATE => :WATER, :MEADOWPLATE => :GRASS, :ZAPPLATE => :ELECTRIC, :MINDPLATE => :PSYCHIC, :ICICLEPLATE => :ICE,
                 :DRACOPLATE => :DRAGON, :DREADPLATE => :DARK, :PIXIEPLATE => :FAIRY}

    CAMO_PROVIDER_TYPE1 = proc do |pokemon|
      next pokemon.moves[0].type unless pokemon.moves[0].nil?
      next nil
    end

    CAMO_PROVIDER_TYPE2 = proc do |pokemon|
      next pokemon.moves[1].type unless pokemon.moves[1].nil?
      next nil
    end

  end

  AAA_POKEMON = {}
  STAB_POKEMON = {}
  PLATE_POKEMON = {}
  CUSTOM_PLATE_MAP = {}
  ALPHABET_POKEMON = {}
  CUSTOM_POKEMON_ABILITIES = []
  POKEBILITIES_POKEMON = {}

  UniLib::ABILITY_DATA.each do |key, value|
    CUSTOM_POKEMON_ABILITIES.push([key, value.name]) unless BANNED_ABILITIES.include?(key)
  end

end

class PokeModifier

  attr_accessor(:aaa)
  attr_accessor(:stab)
  attr_accessor(:stab_types)
  attr_accessor(:plates)
  attr_accessor(:camo)
  attr_accessor(:alphabet)
  attr_accessor(:pokebilities)

  OM_MODIFIER_INIT = proc do |modifier|
    modifier.aaa = false
    modifier.stab = false
    modifier.stab_types = []
    modifier.plates = []
    modifier.camo = false
    modifier.alphabet = []
    modifier.pokebilities = false
  end

  OM_MODIFIER_BUILD = proc do |modifier|
    modifier.set_aaa_internal if modifier.aaa
    key = [modifier.species, modifier.form]
    if modifier.stab
      UniLib::STAB_POKEMON[key] = []
      type1 = modifier.get_data(:Type1)
      type2 = modifier.get_data(:Type2)
      unless type1.nil?
        UniLib::STAB_POKEMON[key].push(type1)
        modifier.egg_moves(UniLib::TYPE_MAPPED_MOVES[type1])
        modifier.compatible_moves(UniLib::TYPE_MAPPED_MOVES[type1])
        modifier.stab_types -= [type1]
      end
      unless type2.nil?
        UniLib::STAB_POKEMON[key].push(type2)
        modifier.egg_moves(UniLib::TYPE_MAPPED_MOVES[type2])
        modifier.compatible_moves(UniLib::TYPE_MAPPED_MOVES[type2])
        modifier.stab_types -= [type2]
      end
      modifier.stab_types.each do |type|
        UniLib::STAB_POKEMON[key].push(type)
        modifier.egg_moves(UniLib::TYPE_MAPPED_MOVES[type2])
        modifier.compatible_moves(UniLib::TYPE_MAPPED_MOVES[type2])
      end

    end
    UniLib::ALPHABET_POKEMON[key] = modifier.alphabet if modifier.alphabet.length > 0
    modifier.set_plates_internal(modifier.plates) unless modifier.plates.empty?
    if modifier.camo
      UniLib::CUSTOM_TYPE1_PROVIDERS[key] = UniLib::CAMO_PROVIDER_TYPE1
      UniLib::CUSTOM_TYPE2_PROVIDERS[key] = UniLib::CAMO_PROVIDER_TYPE2
    end
    UniLib::POKEBILITIES_POKEMON[key] = true if modifier.pokebilities
  end

  def set_aaa_internal
    UniLib::AAA_POKEMON[[@species, @form]] = true
  end

  def set_plates_internal(plates)
    key = [@species, @form]
    if plates == :ALL
      UniLib::PLATE_POKEMON[key] = UniLib::PLATE_MAP
    else
      UniLib::PLATE_POKEMON[key] = []
      plates.each { |plate| UniLib::PLATE_POKEMON[key].push(plate) if UniLib::PLATE_MAP.include?(plate) or UniLib::CUSTOM_PLATE_MAP.include?(plate) }
    end
  end

end unless UniLib.lib_loaded(__FILE__)

PokeModifier::EVENT_POKEMODIFIER_INIT.push(PokeModifier::OM_MODIFIER_INIT)
PokeModifier::EVENT_POKEMODIFIER_POST_BUILD.push(PokeModifier::OM_MODIFIER_BUILD)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_function(ItemHandlers::UseOnPokemon.instance_variable_get(:@hash)[:ABILITYCAPSULE], :HEAD,
 "key = [pokemon.species, pokemon.form]
  unless UniLib::AAA_POKEMON[key].nil?
    list = UniLib::POKEBILITIES_POKEMON[key] ? [] : pokemon.getAbilityList
    i = UniLib.ability_select(1, list)
    if i != 0
      pokemon.setAbility(i)
      scene.pbDisplay(_INTL(\"{1}'s ability was changed to {2}!\", pokemon.name, getAbilityName(pokemon.ability)))
    end
    next true
  end")

UniLib.insert_in_method(:PokeBattle_Pokemon, :type2, :HEAD,
 "key = [@species, @form]
  return UniLib::PLATE_MAP[@item] if !UniLib::PLATE_POKEMON[key].nil? and UniLib::PLATE_POKEMON[key].include?(@item) and UniLib::PLATE_MAP.include?(@item)
  return UniLib::CUSTOM_PLATE_MAP[@item] if !UniLib::PLATE_POKEMON[key].nil? and UniLib::PLATE_POKEMON[key].include?(@item) and UniLib::CUSTOM_PLATE_MAP.include?(@item)")

UniLib.insert_in_function_before(:pbGetRelearnableMoves, "return moves|[]",
  "key = [pokemon.species, pokemon.form]
  UniLib::STAB_POKEMON[key].each { |type| moves |= UniLib::TYPE_MAPPED_MOVES[type] unless UniLib::TYPE_MAPPED_MOVES[type].nil? } unless UniLib::STAB_POKEMON[key].nil?
  UniLib::ALPHABET_POKEMON[key].each { |letter| moves |= UniLib::ALPHABET_MOVES[letter] unless UniLib::ALPHABET_MOVES[letter].nil? } unless UniLib::ALPHABET_POKEMON[key].nil?")

UniLib.insert_in_method(:PokemonSummaryScene, :drawAbilPage, "memo+=_INTL(\"<c3=F8F8F8,686868>Ability:<c3=404040,B0B0B0>\n\")", "abilname = \"Pokebilities\" if UniLib::POKEBILITIES_POKEMON[[@pokemon.species, @pokemon.form]]")

UniLib.insert_in_method(:PokemonSummaryScene, :drawPageThree, "abilitydesc = abil.nil? ? (@pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : abil.desc",
   "if UniLib::POKEBILITIES_POKEMON[[@pokemon.species, @pokemon.form]]
    abilityname = \"Pokebilities\"
    list = @pokemon.getAbilityList
    abilitydesc = \"\"
    list.each { |abil| abilitydesc += getAbilityName(abil, true) + (abil != list.last ? \" + \" : \".\") }
    abilitydesc += \" + \" + getAbilityName(pokemon.ability) if !list.include?(pokemon.ability)
  end")

UniLib.insert_in_method(:PokemonSummaryScene, :drawPageFour, "abilitydesc = abil.nil? ? (pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : abil.desc",
  "if UniLib::POKEBILITIES_POKEMON[[pokemon.species, pokemon.form]]
    abilityname = \"Pokebilities\"
    list = pokemon.getAbilityList
    abilitydesc = \"\"
    list.each { |abil| abilitydesc += getAbilityName(abil, true) + (abil != list.last ? \" + \" : \".\")}
    abilitydesc += \" + \" + getAbilityName(pokemon.ability) if !list.include?(pokemon.ability)
  end")

UniLib.insert_in_method(:PokemonStorageScene, :pbUpdateOverlay, "abilityname=getAbilityName(pokemon.ability)", "abilityname = \"Pokebilities\" if UniLib::POKEBILITIES_POKEMON[[pokemon.species, pokemon.form]]")

UniLib.insert_in_method(:PokeBattle_Pokemon, :initAbility, :TAIL, "@ability = abillist[0] if UniLib::POKEBILITIES_POKEMON[[@species, @form]]")