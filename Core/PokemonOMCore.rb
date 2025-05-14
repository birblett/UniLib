# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Pokemon"
UniLib.include "Move"
UniLib.include "Ability"
UniLib.include "Item"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

ItemBuilder.add(:CATALYZER, "Catalyzer", "May activate the user's hidden potential.")
           .no_use
           .no_use_in_battle
           .unlosable { |pkmn| next (UniLib::POKEBILITIES_POKEMON[key = [pkmn.species, pkmn.form]] == 1 or UniLib::CAMO_POKEMON[key] == 1) }

module UniLib

  CUSTOM_ABILITY_BANS = []

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

    BANNED_OVERPOWERED_ABILITIES = [:CONTRARY, :FLUFFY, :FURCOAT, :GORILLATACTICS, :HUGEPOWER, :ICESCALES, :INTREPIDSWORD, :LIBERO,
                                    :PARENTALBOND, :PROTEAN, :PUREPOWER, :SIMPLE, :SPEEDBOOST, :STAKEOUT, :WATERBUBBLE]
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

    POKEBILITY_PROC = proc { |pkmn, _| pkmn = pkmn.pokemon if pkmn.is_a? PokeBattle_Battler; next pkmn.getAbilityList if pokebilities_active(pkmn) }

    def self.ability_select(default, list)
      cmdwin=pbListWindow([], 200)
      commands = CUSTOM_POKEMON_ABILITIES.clone
      UniLib::CUSTOM_ABILITIES.map { |ability, data| [ability, data.name] }.each { |cmd| commands.push(cmd) unless commands.include?(cmd) }
      list.each { |_, ability| commands.push([ability, UniLib::ABILITY_DATA[ability].name]) if BANNED_ABILITIES.include?(ability) }
      CUSTOM_ABILITY_BANS.each { |ability| commands.delete_if { |i| ability == i[0] } }
      commands.sort! { |a,b| a[1] <=> b[1] }
      ret = pbCommands2(cmdwin, commands.map { |command| _ISPRINTF("{1:s}", command[1])} ,-1,default-1,true)
      cmdwin.dispose
      ret >= 0 ? commands[ret][0] : 0
    end

    def self.pokebilities_active(pkmn)
      UniLib::POKEBILITIES_POKEMON[[pkmn.species, pkmn.form]] == 2 or (pkmn.item == :CATALYZER and UniLib::POKEBILITIES_POKEMON[[pkmn.species, pkmn.form]] == 1)
    end

    PLATE_MAP = {:SILKSCARF => :NORMAL, :FISTPLATE => :FIGHTING, :SKYPLATE => :FLYING, :EARTHPLATE => :GROUND, :TOXICPLATE => :POISON,
                 :STONEPLATE => :ROCK, :INSECTPLATE => :BUG, :SPOOKYPLATE => :GHOST, :IRONPLATE => :STEEL, :FLAMEPLATE => :FIRE,
                 :SPLASHPLATE => :WATER, :MEADOWPLATE => :GRASS, :ZAPPLATE => :ELECTRIC, :MINDPLATE => :PSYCHIC, :ICICLEPLATE => :ICE,
                 :DRACOPLATE => :DRAGON, :DREADPLATE => :DARK, :PIXIEPLATE => :FAIRY}

    PLATE_MAP.each { |plate, _| ItemModifier.add(plate).unlosable { |pkmn| next true if PLATE_POKEMON[key = [pkmn.pokemon.species, pkmn.pokemon.form]] and PLATE_POKEMON[key].include?(plate) } }

    CAMO_PROVIDER_TYPE1 = proc do |pokemon|
      next pokemon.moves[0].type if (UniLib::CAMO_POKEMON[key = [pokemon.species, pokemon.form]] == 2 or (UniLib::CAMO_POKEMON[key] == 1 and pokemon.item == :CATALYZER)) unless pokemon.moves[0].nil?
    end

    CAMO_PROVIDER_TYPE2 = proc do |pokemon|
      next pokemon.moves[1].type if (UniLib::CAMO_POKEMON[key = [pokemon.species, pokemon.form]] == 2 or (UniLib::CAMO_POKEMON[key] == 1 and pokemon.item == :CATALYZER)) unless pokemon.moves[1].nil?
    end

  end

  AAA_POKEMON = {}
  STAB_POKEMON = {}
  PLATE_POKEMON = {}
  CUSTOM_PLATE_MAP = {}
  ALPHABET_POKEMON = {}
  CAMO_POKEMON = {}
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
    modifier.camo = 0
    modifier.alphabet = []
    modifier.pokebilities = 0
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
    if modifier.camo > 0
      UniLib::CAMO_POKEMON[key] = modifier.camo
      UniLib.add_type1_provider(modifier.species, modifier.form, UniLib::CAMO_PROVIDER_TYPE1)
      UniLib.add_type2_provider(modifier.species, modifier.form, UniLib::CAMO_PROVIDER_TYPE2)
    end
    UniLib::POKEBILITIES_POKEMON[key] = modifier.pokebilities if modifier.pokebilities > 0
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
    list = UniLib.pokebilities_active(pokemon) ? [] : pokemon.getAbilityList
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

UniLib.insert_in_method(:PokeBattle_Battle, :pbIsUnlosableItem, :HEAD,
  "key = [pkmn.species, pkmn.form]
  return true if !UniLib::PLATE_POKEMON[key].nil? and UniLib::PLATE_POKEMON[key].include?(item)")

target = Reborn ? "return moves | []" : "return moves|[]"
UniLib.insert_in_function_before(:pbGetRelearnableMoves, target,
  "key = [pokemon.species, pokemon.form]
  UniLib::STAB_POKEMON[key].each { |type| moves |= UniLib::TYPE_MAPPED_MOVES[type] unless UniLib::TYPE_MAPPED_MOVES[type].nil? } unless UniLib::STAB_POKEMON[key].nil?
  UniLib::ALPHABET_POKEMON[key].each { |letter| moves |= UniLib::ALPHABET_MOVES[letter] unless UniLib::ALPHABET_MOVES[letter].nil? } unless UniLib::ALPHABET_POKEMON[key].nil?")

target = Reborn ? "memo += _INTL(\"<c3=F8F8F8,686868>Ability:<c3=404040,B0B0B0>\\n\")" : "memo+=_INTL(\"<c3=F8F8F8,686868>Ability:<c3=404040,B0B0B0>\n\")"
UniLib.insert_in_method(:PokemonSummaryScene, :drawAbilPage, target, "abilname = \"Pokebilities\" if UniLib.pokebilities_active(@pokemon)")

UniLib.insert_in_method(:PokemonSummaryScene, :drawPageThree, "abilitydesc = abil.nil? ? (@pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : abil.desc",
   "if UniLib.pokebilities_active(@pokemon)
    abilityname = \"Pokebilities\"
    list = @pokemon.getAbilityList
    list.push(pokemon.ability) unless list.include?(pokemon.ability)
    abilitydesc = \"\"
    list.each { |abil| abilitydesc += getAbilityName(abil, true) + (abil != list.last ? \" + \" : \".\") }
  end")

UniLib.insert_in_method(:PokemonSummaryScene, :drawPageFour, "abilitydesc = abil.nil? ? (pokemon.ability.nil? ? NoAbilDesc : NotRealAbil) : abil.desc.nil? ? MissingAbilDesc : abil.desc",
  "if UniLib.pokebilities_active(@pokemon)
    abilityname = \"Pokebilities\"
    list = pokemon.getAbilityList
    list.push(pokemon.ability) unless list.include?(pokemon.ability)
    abilitydesc = \"\"
    list.each { |abil| abilitydesc += getAbilityName(abil, true) + (abil != list.last ? \" + \" : \".\")}
  end")

target = Reborn ? "abilityname = getAbilityName(pokemon.ability)" : "abilityname=getAbilityName(pokemon.ability)"
UniLib.insert_in_method(:PokemonStorageScene, :pbUpdateOverlay, target, "abilityname = \"Pokebilities\" if UniLib.pokebilities_active(pokemon)")

UniLib.insert_in_method(:PokeBattle_Pokemon, :initAbility, :TAIL, "@ability = abillist[0] if UniLib.pokebilities_active(self)")