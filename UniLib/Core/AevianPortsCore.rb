# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Pokemon"
UniLib.include "Ability"
UniLib.include "Move"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

if Reborn

  PARAS_AEVIAN = PokeModifier.add_form(:PARAS, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :BUG, :Type2 => :POISON})
              .set_ev([0, 1, 0, 0, 0, 0])
              .set_evolutions([[:PARASECT, :Item, :XENWASTE]])
              .level_moves([[1, :SCRATCH], [6, :POISONPOWDER], [6, :STUNSPORE], [11, :POISONSTING], [17, :FURYCUTTER], [22, :TOXIC], [27, :SLASH], [33, :AROMATHERAPY], [37, :CROSSPOISON], [41, :VENOMDRENCH], [45, :SLEEPPOWDER], [51, :XSCISSOR], [54, :GUNKSHOT]])
              .egg_moves([:AGILITY, :BUGBITE, :METALCLAW, :CROSSPOISON, :ENDURE, :LEECHSEED, :FLAIL, :KNOCKOFF, :PURSUIT, :PSYBEAM, :SCREECH, :DISABLE])
              .compatible_moves([:AERIALACE, :BUGBITE, :CROSSPOISON, :CUT, :ELECTROWEB, :ENDEAVOR, :FALSESWIPE, :GASTROACID, :GIGADRAIN, :GUNKSHOT, :ICYWIND, :INFESTATION, :IRRITATION, :KNOCKOFF, :LASERFOCUS, :LEECHLIFE, :MAGICROOM, :MUDSHOT, :PAINSPLIT, :PINMISSILE, :POISONJAB, :POISONSWEEP, :POLLENPUFF, :RAINDANCE, :RECYCLE, :ROCKSMASH, :SCARYFACE, :SCREECH, :SIGNALBEAM, :SKITTERSMACK, :SLUDGEBOMB, :SPITE, :STRUGGLEBUG, :SUCKERPUNCH, :THIEF, :TOXICSPIKES, :VENOMDRENCH, :VENOSHOCK, :WATERPULSE, :WONDERROOM, :XSCISSOR, :IRRITATION, :SLASHANDBURN])
              .set_dex_entry("The environment caused the species of mushroom infesting Paras to mutate. Their poison is strong enough to shock the host back to life when on the brink of death.")
              .asset_override(asset: "UniLib/Assets/Battlers/paras-aevian.png", asset_egg: "UniLib/Assets/Battlers/paras-aevian_egg.png", icon: "UniLib/Assets/Icons/paras-aevian.png", icon_egg: "UniLib/Assets/Icons/paras-aevian_egg.png")
              .get_form

  PARAS_ZOMBIE = PokeModifier.add_form(:PARAS, "Zombie Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GHOST, :Type2 => :POISON})
              .stats([15, 100, 25, 45, 25, 75])
              .abilities({0 => :RESUSCITATION, 1 => nil, 2 => :RESUSCITATION})
              .level_moves([[1, :SCRATCH], [6, :POISONPOWDER], [6, :STUNSPORE], [11, :POISONSTING], [17, :FURYCUTTER], [22, :TOXIC], [27, :SLASH], [33, :AROMATHERAPY], [37, :CROSSPOISON], [41, :VENOMDRENCH], [45, :SLEEPPOWDER], [51, :XSCISSOR], [54, :GUNKSHOT]])
              .egg_moves([:AGILITY, :BUGBITE, :METALCLAW, :CROSSPOISON, :ENDURE, :LEECHSEED, :FLAIL, :KNOCKOFF, :PURSUIT, :PSYBEAM, :SCREECH, :DISABLE])
              .compatible_moves([:AERIALACE, :BUGBITE, :CROSSPOISON, :CUT, :ELECTROWEB, :ENDEAVOR, :FALSESWIPE, :GASTROACID, :GIGADRAIN, :GUNKSHOT, :ICYWIND, :INFESTATION, :IRRITATION, :KNOCKOFF, :LASERFOCUS, :LEECHLIFE, :MAGICROOM, :MUDSHOT, :PAINSPLIT, :PINMISSILE, :POISONJAB, :POISONSWEEP, :POLLENPUFF, :RAINDANCE, :RECYCLE, :ROCKSMASH, :SCARYFACE, :SCREECH, :SIGNALBEAM, :SKITTERSMACK, :SLUDGEBOMB, :SPITE, :STRUGGLEBUG, :SUCKERPUNCH, :THIEF, :TOXICSPIKES, :VENOMDRENCH, :VENOSHOCK, :WATERPULSE, :WONDERROOM, :XSCISSOR, :IRRITATION, :SLASHANDBURN])
              .asset_override(asset: "UniLib/Assets/Battlers/paras-zombie.png", asset_egg: "UniLib/Assets/Battlers/paras-zombie_egg.png", icon: "UniLib/Assets/Icons/paras-zombie.png", icon_egg: "UniLib/Assets/Icons/paras-zombie_egg.png")
              .get_form

  PARASECT_AEVIAN = PokeModifier.add_form(:PARASECT, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :BUG, :Type2 => :POISON})
              .stats([60, 90, 80, 60, 80, 30])
              .abilities({0 => :RESUSCITATION, 1 => nil, 2 => :RESUSCITATION})
              .set_ev([0, 2, 1, 0, 0, 0])
              .set_preevo({:species=>:PARAS, :form=>1})
              .level_moves([[0, :SHADOWCLAW], [1, :PHANTOMFORCE], [1, :SHADOWSNEAK], [1, :SCRATCH], [6, :POISONPOWDER], [6, :STUNSPORE], [11, :POISONSTING], [17, :FURYCUTTER], [22, :TOXIC], [29, :SLASH], [37, :AROMATHERAPY], [41, :CROSSPOISON], [45, :VENOMDRENCH], [49, :SLEEPPOWDER], [52, :XSCISSOR], [56, :GUNKSHOT]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :BLOCK, :BODYPRESS, :BRICKBREAK, :BUGBITE, :CROSSPOISON, :CUT, :DARKPULSE, :DREAMEATER, :ELECTROWEB, :EMBARGO, :ENDEAVOR, :FALSESWIPE, :GASTROACID, :GIGADRAIN, :GIGAIMPACT, :GUNKSHOT, :HEX, :HYPERBEAM, :ICYWIND, :INFESTATION, :IRRITATION, :KNOCKOFF, :LASERFOCUS, :LASTRESORT, :LEECHLIFE, :MAGICROOM, :MUDSHOT, :PAINSPLIT, :PAYBACK, :PHANTOMFORCE, :PINMISSILE, :POISONJAB, :POISONSWEEP, :POLLENPUFF, :POLTERGEIST, :RAINDANCE, :RECYCLE, :RETALIATE, :ROCKCLIMB, :ROCKSMASH, :SCARYFACE, :SCREECH, :SHADOWBALL, :SHADOWCLAW, :SIGNALBEAM, :SKITTERSMACK, :SLASHANDBURN, :SLUDGEBOMB, :SLUDGEWAVE, :SPEEDSWAP, :SPITE, :STOMPINGTANTRUM, :STOREDPOWER, :STRENGTH, :STRUGGLEBUG, :SUCKERPUNCH, :THIEF, :THROATCHOP, :TOXICSPIKES, :UTURN, :VENOMDRENCH, :VENOSHOCK, :WATERPULSE, :WILLOWISP, :WONDERROOM, :XSCISSOR, :IRRITATION, :SLASHANDBURN, :STACKINGSHOT])
              .set_dex_entry("The poisonous ooze dripping from the mushrooms on its back is postulated to have medicinal uses, however verification of this rumour's validity is still ongoing.")
              .asset_override(asset: "UniLib/Assets/Battlers/parasect-aevian.png", icon: "UniLib/Assets/Icons/parasect-aevian.png")
              .get_form

  PARASECT_ZOMBIE = PokeModifier.add_form(:PARASECT, "Zombie Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GHOST, :Type2 => :POISON})
              .stats([40, 130, 40, 50, 40, 105])
              .abilities({0 => :RESUSCITATION, 1 => nil, 2 => :RESUSCITATION})
              .level_moves([[0, :SHADOWCLAW], [1, :PHANTOMFORCE], [1, :SHADOWSNEAK], [1, :SCRATCH], [6, :POISONPOWDER], [6, :STUNSPORE], [11, :POISONSTING], [17, :FURYCUTTER], [22, :TOXIC], [29, :SLASH], [37, :AROMATHERAPY], [41, :CROSSPOISON], [45, :VENOMDRENCH], [49, :SLEEPPOWDER], [52, :XSCISSOR], [56, :GUNKSHOT]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :BLOCK, :BODYPRESS, :BRICKBREAK, :BUGBITE, :CROSSPOISON, :CUT, :DARKPULSE, :DREAMEATER, :ELECTROWEB, :EMBARGO, :ENDEAVOR, :FALSESWIPE, :GASTROACID, :GIGADRAIN, :GIGAIMPACT, :GUNKSHOT, :HEX, :HYPERBEAM, :ICYWIND, :INFESTATION, :IRRITATION, :KNOCKOFF, :LASERFOCUS, :LASTRESORT, :LEECHLIFE, :MAGICROOM, :MUDSHOT, :PAINSPLIT, :PAYBACK, :PHANTOMFORCE, :PINMISSILE, :POISONJAB, :POISONSWEEP, :POLLENPUFF, :POLTERGEIST, :RAINDANCE, :RECYCLE, :RETALIATE, :ROCKCLIMB, :ROCKSMASH, :SCARYFACE, :SCREECH, :SHADOWBALL, :SHADOWCLAW, :SIGNALBEAM, :SKITTERSMACK, :SLASHANDBURN, :SLUDGEBOMB, :SLUDGEWAVE, :SPEEDSWAP, :SPITE, :STOMPINGTANTRUM, :STOREDPOWER, :STRENGTH, :STRUGGLEBUG, :SUCKERPUNCH, :THIEF, :THROATCHOP, :TOXICSPIKES, :UTURN, :VENOMDRENCH, :VENOSHOCK, :WATERPULSE, :WILLOWISP, :WONDERROOM, :XSCISSOR, :IRRITATION, :SLASHANDBURN, :STACKINGSHOT])
              .asset_override(asset: "UniLib/Assets/Battlers/parasect-zombie.png", icon: "UniLib/Assets/Icons/parasect-zombie.png")
              .get_form

  MAGIKARP_AEVIAN = PokeModifier.add_form(:MAGIKARP, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FIRE, :Type2 => :FIRE})
              .set_ev([0, 0, 0, 0, 0, 1])
              .level_moves([[1, :SPLASH], [15, :TACKLE], [30, :FLAIL]])
              .egg_moves([])
              .compatible_moves([:BOUNCE, :CELEBRATE, :HAPPYHOUR, :FIREBLAST])
              .asset_override(asset: "UniLib/Assets/Battlers/magikarp-aevian.png", asset_egg: "UniLib/Assets/Battlers/magikarp-aevian_egg.png", asset_egg_f: "UniLib/Assets/Battlers/magikarp-aevian_egg_f.png", asset_f: "UniLib/Assets/Battlers/magikarp-aevian_f.png", icon: "UniLib/Assets/Icons/magikarp-aevian.png", icon_egg: "UniLib/Assets/Icons/magikarp-aevian_egg.png", icon_egg_f: "UniLib/Assets/Icons/magikarp-aevian_egg_f.png", icon_f: "UniLib/Assets/Icons/magikarp-aevian_f.png")
              .get_form

  GYARADOS_AEVIAN = PokeModifier.add_form(:GYARADOS, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FIRE, :Type2 => :DRAGON})
              .stats([95, 60, 79, 125, 100, 81])
              .abilities({0 => :INTIMIDATE, 1 => :MULTISCALE, 2 => :INTIMIDATE})
              .set_ev([0, 2, 0, 0, 0, 0])
              .set_preevo({:species=>:MAGIKARP, :form=>1})
              .level_moves([[1, :SNARL], [1, :MORNINGSUN], [1, :THRASH], [0, :SNARL], [21, :LEER], [24, :TWISTER], [27, :FIREFANG], [30, :FLAMEBURST], [33, :SCARYFACE], [36, :DRAGONRAGE], [39, :DARKPULSE], [42, :FIREBLAST], [45, :FIERYDANCE], [48, :SOLARBEAM], [51, :SUNNYDAY], [54, :HYPERBEAM]])
              .egg_moves([])
              .compatible_moves([:BIND, :BODYSLAM, :BOUNCE, :BREAKINGSWIPE, :BRUTALSWING, :BURNINGJEALOUSY, :CHARGEBEAM, :CRUNCH, :DARKPULSE, :DIG, :DRACOMETEOR, :DRAGONCLAW, :DRAGONDANCE, :DRAGONPULSE, :DRAGONTAIL, :EARTHPOWER, :EARTHQUAKE, :ENERGYBALL, :FALSESWIPE, :FIREBLAST, :FIREFANG, :FIRESPIN, :FLAMECHARGE, :FLAMETHROWER, :FLAREBLITZ, :GIGADRAIN, :GIGAIMPACT, :GRASSKNOT, :HEATCRASH, :HEATWAVE, :HONECLAWS, :HURRICANE, :HYDROPUMP, :HYPERBEAM, :HYPERVOICE, :INCINERATE, :IRONHEAD, :IRONTAIL, :LASHOUT, :LASTRESORT, :MAGMADRIFT, :MUDSHOT, :MYSTICALFIRE, :NASTYPLOT, :OUTRAGE, :OVERHEAT, :PAYBACK, :POWERWHIP, :ROAR, :ROCKCLIMB, :ROCKSMASH, :ROCKTOMB, :ROOST, :SCALD, :SCALESHOT, :SCARYFACE, :SHADOWCLAW, :SHOCKWAVE, :SLASHANDBURN, :SNARL, :SOLARBEAM, :SOLARBLADE, :STOMPINGTANTRUM, :STRENGTH, :SUNNYDAY, :SURF, :TAUNT, :THUNDER, :THUNDERBOLT, :THUNDERFANG, :THUNDERWAVE, :TORMENT, :UPROAR, :WATERPULSE, :WEATHERBALL, :WILLOWISP, :ZAPCANNON, :ZENHEADBUTT, :MAGMADRIFT, :SLASHANDBURN])
              .set_dex_entry("Finally free to travel anywhere it wants, the first thing Gyarados does after evolution is track down the trainers that walked past it in its Magikarp stage and burn their houses to the ground.")
              .asset_override(asset: "UniLib/Assets/Battlers/gyarados-aevian.png", asset_f: "UniLib/Assets/Battlers/gyarados-aevian_f.png", icon: "UniLib/Assets/Icons/gyarados-aevian.png", icon_f: "UniLib/Assets/Icons/gyarados-aevian_f.png")
              .get_form

  LAPRAS_AEVIAN = PokeModifier.add_form(:LAPRAS, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :ROCK, :Type2 => :PSYCHIC})
              .stats([135, 95, 80, 85, 85, 60])
              .abilities({0 => :SOLIDROCK, 1 => :FOREWARN, 2 => :NOGUARD})
              .set_ev([2, 0, 0, 0, 0, 0])
              .level_moves([[1, :HARDEN], [1, :PSYWAVE], [5, :SING], [10, :ROCKPOLISH], [15, :GRAVITY], [20, :POWERGEM], [25, :CONFUSERAY], [30, :ROCKSLIDE], [35, :ZENHEADBUTT], [40, :BODYSLAM], [45, :PSYCHIC], [50, :SANDSTORM], [55, :MIRACLEEYE], [60, :PERISHSONG], [65, :STONEEDGE]])
              .egg_moves([:ANCIENTPOWER, :CURSE, :DRAGONDANCE, :HEAVYSLAM, :ROCKTOMB, :TELEPORT])
              .compatible_moves([:AFTERYOU, :ALLYSWITCH, :AMNESIA, :ARENITEWALL, :AURORAVEIL, :AVALANCHE, :BLIZZARD, :BLOCK, :BODYPRESS, :BODYSLAM, :BREAKINGSWIPE, :BULLDOZE, :CALMMIND, :CHARM, :COSMICPOWER, :DAZZLINGGLEAM, :DRAGONDANCE, :DRAGONPULSE, :DRAGONTAIL, :DREAMEATER, :DRILLRUN, :EARTHPOWER, :EARTHQUAKE, :ECHOEDVOICE, :ENCORE, :EXPANDINGFORCE, :EXPLOSION, :FLASH, :FLASHCANNON, :FOCUSBLAST, :FROSTBREATH, :FUTURESIGHT, :GIGAIMPACT, :GRAVITY, :GUARDSWAP, :GYROBALL, :HEALBELL, :HEAVYSLAM, :HELPINGHAND, :HYPERBEAM, :HYPERVOICE, :ICEBEAM, :IRONDEFENSE, :IRONHEAD, :IRONTAIL, :LIGHTSCREEN, :MAGICCOAT, :MAGICROOM, :MEGAHORN, :METEORBEAM, :NATUREPOWER, :OUTRAGE, :POWERGEM, :POWERSWAP, :PSYCHIC, :PSYCHICFANGS, :PSYCHICTERRAIN, :PSYCHOCUT, :PSYSHOCK, :REFLECT, :ROAR, :ROCKBLAST, :ROCKCLIMB, :ROCKPOLISH, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SAFEGUARD, :SANDSTORM, :SCREECH, :SELFDESTRUCT, :SHADOWBALL, :SHOCKWAVE, :SMACKDOWN, :SMARTSTRIKE, :SPEEDSWAP, :STEALTHROCK, :STOMPINGTANTRUM, :STONEEDGE, :STRENGTH, :TELEKINESIS, :TERRAINPULSE, :THUNDERWAVE, :TRICKROOM, :UPROAR, :WEATHERBALL, :WONDERROOM, :ZAPCANNON, :ZENHEADBUTT, :ARENITEWALL, :MAGMADRIFT, :QUICKSILVERSPEAR])
              .set_dex_entry("This unique Lapras was previously fossilized, but the strange energy the crystals in Amethyst cave seem to give off slowly revived and altered it.")
              .asset_override(asset: "UniLib/Assets/Battlers/lapras-aevian.png", asset_egg: "UniLib/Assets/Battlers/lapras-aevian_egg.png", icon: "UniLib/Assets/Icons/lapras-aevian.png", icon_egg: "UniLib/Assets/Icons/lapras-aevian_egg.png")
              .get_form

  MAREEP_AEVIAN = PokeModifier.add_form(:MAREEP, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :ICE, :Type2 => :ELECTRIC})
              .stats([55, 40, 45, 65, 40, 35])
              .abilities({0 => :FILTER, 1 => :COTTONDOWN, 2 => :FILTER})
              .set_ev([0, 0, 0, 1, 0, 0])
              .level_moves([[1, :TACKLE], [1, :HAIL], [4, :THUNDERWAVE], [8, :THUNDERSHOCK], [11, :COTTONSPORE], [15, :ICYWIND], [18, :TAKEDOWN], [22, :ICEBALL], [25, :CONFUSERAY], [29, :POWERGEM], [32, :DISCHARGE], [36, :COTTONGUARD], [39, :REST], [43, :REFLECT], [46, :THUNDER]])
              .egg_moves([:AFTERYOU, :AGILITY, :BODYSLAM, :CHARGE, :EERIEIMPULSE, :ELECTRICTERRAIN, :FLATTER, :IRONTAIL, :FROSTBREATH, :SANDATTACK, :SCREECH, :TAKEDOWN])
              .compatible_moves([:AFTERYOU, :AURORAVEIL, :AVALANCHE, :BLIZZARD, :CHARGEBEAM, :DRAGONPULSE, :ECHOEDVOICE, :EERIEIMPULSE, :ELECTRICTERRAIN, :ELECTROBALL, :ELECTROWEB, :ENDEAVOR, :FAKETEARS, :FLASH, :FLASHCANNON, :FROSTBREATH, :GUARDSWAP, :HAIL, :HEALBELL, :ICEBEAM, :ICICLESPEAR, :ICYWIND, :IRONTAIL, :LASERFOCUS, :MAGICCOAT, :MAGNETRISE, :OUTRAGE, :PAYBACK, :PAYDAY, :POWERGEM, :RAINDANCE, :RECYCLE, :REFLECT, :RISINGVOLTAGE, :ROLEPLAY, :SAFEGUARD, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :THUNDER, :THUNDERWAVE, :THUNDERBOLT, :VOLTSWITCH, :WATERPULSE, :WEATHERBALL, :WILDCHARGE, :ZAPCANNON, :DELUGE])
              .set_dex_entry("The cold climate of Neverwinter made Mareep's wool even thicker, making it a popular companion in the region.")
              .asset_override(asset: "UniLib/Assets/Battlers/mareep-aevian.png", asset_egg: "UniLib/Assets/Battlers/mareep-aevian_egg.png", icon: "UniLib/Assets/Icons/mareep-aevian.png", icon_egg: "UniLib/Assets/Icons/mareep-aevian_egg.png")
              .get_form

  FLAAFFY_AEVIAN = PokeModifier.add_form(:FLAAFFY, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :ICE, :Type2 => :ELECTRIC})
              .stats([70, 55, 60, 80, 50, 45])
              .abilities({0 => :FILTER, 1 => :COTTONDOWN, 2 => :FILTER})
              .set_ev([0, 0, 0, 2, 0, 0])
              .set_preevo({:species=>:MAREEP, :form=>1})
              .level_moves([[1, :TACKLE], [1, :HAIL], [1, :THUNDERWAVE], [1, :THUNDERSHOCK], [4, :THUNDERWAVE], [8, :THUNDERSHOCK], [11, :COTTONSPORE], [16, :ICYWIND], [20, :TAKEDOWN], [25, :ICEBALL], [29, :CONFUSERAY], [34, :POWERGEM], [38, :DISCHARGE], [43, :COTTONGUARD], [47, :REST], [52, :REFLECT], [56, :THUNDER]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :AGILITY, :AURORAVEIL, :AVALANCHE, :BEATUP, :BLIZZARD, :BREAKINGSWIPE, :CHARGEBEAM, :DRAGONPULSE, :DYNAMICPUNCH, :ECHOEDVOICE, :EERIEIMPULSE, :ELECTRICTERRAIN, :ELECTROBALL, :ELECTROWEB, :ENDEAVOR, :FAKETEARS, :FLASH, :FLASHCANNON, :FLING, :FROSTBREATH, :GUARDSWAP, :HAIL, :HEALBELL, :ICEBEAM, :ICEPUNCH, :ICICLESPEAR, :ICYWIND, :IRONTAIL, :LASERFOCUS, :MAGICCOAT, :MAGNETRISE, :MEGAKICK, :MEGAPUNCH, :METRONOME, :OUTRAGE, :PAYBACK, :PAYDAY, :POWERGEM, :RAINDANCE, :RECYCLE, :REFLECT, :RISINGVOLTAGE, :ROCKSMASH, :ROLEPLAY, :SAFEGUARD, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SNATCH, :STRENGTH, :THUNDER, :THUNDERPUNCH, :THUNDERWAVE, :THUNDERBOLT, :VOLTSWITCH, :WATERPULSE, :WEATHERBALL, :WILDCHARGE, :ZAPCANNON, :DELUGE, :STACKINGSHOT])
              .set_dex_entry("The frigid environment caused Flaaffy to not lose its fluffy coat upon evolution. Its horns and tail are warm to the touch due to the constant flow of electricity.")
              .asset_override(asset: "UniLib/Assets/Battlers/flaaffy-aevian.png", icon: "UniLib/Assets/Icons/flaaffy-aevian.png")
              .get_form

  AMPHAROS_AEVIAN = PokeModifier.add_form(:AMPHAROS, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :ICE, :Type2 => :ELECTRIC})
              .stats([90, 75, 90, 115, 85, 55])
              .abilities({0 => :FILTER, 1 => :COTTONDOWN, 2 => :FILTER})
              .set_ev([0, 0, 0, 3, 0, 0])
              .set_preevo({:species=>:FLAAFFY, :form=>1})
              .level_moves([[1, :THUNDERPUNCH], [1, :ZAPCANNON], [1, :HAZE], [1, :BLIZZARD], [1, :ICEPUNCH], [1, :TACKLE], [1, :HAIL], [1, :THUNDERWAVE], [1, :THUNDERSHOCK], [0, :THUNDERPUNCH], [4, :THUNDERWAVE], [8, :THUNDERSHOCK], [11, :COTTONSPORE], [16, :ICYWIND], [20, :TAKEDOWN], [25, :ICEBALL], [29, :CONFUSERAY], [35, :POWERGEM], [40, :DISCHARGE], [46, :COTTONGUARD], [51, :REST], [57, :REFLECT], [62, :THUNDER], [65, :BLIZZARD]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :AGILITY, :AURORAVEIL, :AVALANCHE, :BEATUP, :BLIZZARD, :BODYPRESS, :BODYSLAM, :BRUTALSWING, :CHARGEBEAM, :DRAGONDANCE, :DRAGONPULSE, :DYNAMICPUNCH, :ECHOEDVOICE, :EERIEIMPULSE, :ELECTRICTERRAIN, :ELECTROBALL, :ELECTROWEB, :ENDEAVOR, :FAKETEARS, :FLASH, :FLASHCANNON, :FLING, :FOCUSPUNCH, :FROSTBREATH, :GIGAIMPACT, :GUARDSWAP, :GYROBALL, :HAIL, :HEALBELL, :HYPERBEAM, :ICEBEAM, :ICEPUNCH, :ICICLESPEAR, :ICYWIND, :IRONTAIL, :LASERFOCUS, :MAGICCOAT, :MAGNETRISE, :MEGAKICK, :MEGAPUNCH, :METRONOME, :OUTRAGE, :PAYDAY, :PAYBACK, :PLAYROUGH, :POWERGEM, :RAINDANCE, :RECYCLE, :REFLECT, :RISINGVOLTAGE, :ROCKCLIMB, :ROCKSMASH, :ROLEPLAY, :SAFEGUARD, :SHADOWBALL, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SNATCH, :STRENGTH, :TAILSLAP, :TAUNT, :THUNDER, :THUNDERPUNCH, :THUNDERWAVE, :THUNDERBOLT, :VOLTSWITCH, :WATERPULSE, :WEATHERBALL, :WILDCHARGE, :ZAPCANNON, :DELUGE, :STACKINGSHOT])
              .set_dex_entry("Its tail and horns glow bright enough to be clearly visible in even the harshest of snowstorms, making it invaluable for rescue missions during extreme weather.")
              .asset_override(asset: "UniLib/Assets/Battlers/ampharos-aevian.png", icon: "UniLib/Assets/Icons/ampharos-aevian.png")
              .get_form

  SHROOMISH_AEVIAN = PokeModifier.add_form(:SHROOMISH, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GRASS, :Type2 => :GRASS})
              .set_ev([1, 0, 0, 0, 0, 0])
              .level_moves([[1, :ABSORB], [1, :TACKLE], [5, :STUNSPORE], [8, :LEECHSEED], [12, :BULLETSEED], [15, :HEADBUTT], [19, :POISONPOWDER], [22, :SPARK], [26, :GIGADRAIN], [29, :EERIEIMPULSE], [33, :NUZZLE], [36, :SEEDBOMB], [40, :SPORE]])
              .egg_moves([:BULLETSEED, :CHARM, :DRAINPUNCH, :EERIEIMPULSE, :INGRAIN, :NATURALGIFT, :SEEDBOMB, :WAKEUPSLAP, :WORRYSEED])
              .compatible_moves([:BULLETSEED, :CHARM, :DREAMEATER, :EERIEIMPULSE, :ELECTRICTERRAIN, :ELECTROBALL, :ELECTROWEB, :ENDEAVOR, :ENERGYBALL, :FLASH, :GIGADRAIN, :GRASSKNOT, :GRASSYGLIDE, :GRASSYTERRAIN, :INFESTATION, :IRONHEAD, :MAGICALLEAF, :MAGNETRISE, :NATUREPOWER, :PAYBACK, :POLLENPUFF, :POWERWHIP, :RAINDANCE, :SEEDBOMB, :SHOCKWAVE, :SKITTERSMACK, :SOLARBEAM, :SUCKERPUNCH, :SUNNYDAY, :SYNTHESIS, :TAUNT, :THIEF, :THUNDER, :THUNDERBOLT, :THUNDERWAVE, :VOLTSWITCH, :WILDCHARGE, :WORKUP, :WORRYSEED, :ZAPCANNON, :ZENHEADBUTT, :IRRITATION])
              .set_dex_entry("It can be seen lurking in small, glowing groups with others of its kind. It is highly anxious and will attack without warning if it is approached.")
              .asset_override(asset: "UniLib/Assets/Battlers/shroomish-aevian.png", asset_egg: "UniLib/Assets/Battlers/shroomish-aevian_egg.png", icon: "UniLib/Assets/Icons/shroomish-aevian.png", icon_egg: "UniLib/Assets/Icons/shroomish-aevian_egg.png")
              .get_form

  BRELOOM_AEVIAN = PokeModifier.add_form(:BRELOOM, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GRASS, :Type2 => :ELECTRIC})
              .set_ev([0, 2, 0, 0, 0, 0])
              .set_preevo({:species=>:SHROOMISH, :form=>1})
              .level_moves([[0, :THUNDERPUNCH], [1, :THUNDERPUNCH], [1, :ABSORB], [1, :TACKLE], [1, :STUNSPORE], [1, :LEECHSEED], [5, :STUNSPORE], [8, :LEECHSEED], [12, :BULLETSEED], [15, :HEADBUTT], [19, :SUCKERPUNCH], [22, :MIRRORCOAT], [28, :FAKEOUT], [33, :SPOTLIGHT], [39, :WAKEUPSHOCK], [44, :SEEDBOMB], [50, :ZINGZAP]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :ASSURANCE, :BRICKBREAK, :BRUTALSWING, :BULKUP, :BULLETSEED, :CHARM, :CUT, :DRAINPUNCH, :DREAMEATER, :DUALCHOP, :EERIEIMPULSE, :ELECTRICTERRAIN, :ELECTROBALL, :ELECTROWEB, :ENDEAVOR, :ENERGYBALL, :FLASH, :FLING, :FOCUSENERGY, :GIGADRAIN, :GIGAIMPACT, :GRASSKNOT, :GRASSYGLIDE, :GRASSYTERRAIN, :HONECLAWS, :HYPERBEAM, :INFESTATION, :IRONHEAD, :KNOCKOFF, :LASERFOCUS, :MAGICALLEAF, :MAGNETRISE, :MEGAPUNCH, :METRONOME, :NATUREPOWER, :PAYBACK, :POISONJAB, :POLLENPUFF, :POWERWHIP, :POWERUPPUNCH, :RAINDANCE, :REVERSAL, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SEEDBOMB, :SHADOWCLAW, :SHOCKWAVE, :SKITTERSMACK, :SLASHANDBURN, :SMACKDOWN, :SOLARBEAM, :SOLARBLADE, :STACKINGSHOT, :STRENGTH, :SUCKERPUNCH, :SUNNYDAY, :SWORDSDANCE, :SYNTHESIS, :TAUNT, :THIEF, :THROATCHOP, :THUNDER, :THUNDERPUNCH, :THUNDERWAVE, :THUNDERBOLT, :VOLTSWITCH, :WILDCHARGE, :WORKUP, :WORRYSEED, :ZAPCANNON, :ZENHEADBUTT, :IRRITATION, :POISONSWEEP])
              .set_dex_entry("It can be seen lurking in small, glowing groups with others of its kind. It is highly anxious and will attack without warning if it is approached.")
              .asset_override(asset: "UniLib/Assets/Battlers/breloom-aevian.png", icon: "UniLib/Assets/Icons/breloom-aevian.png")
              .get_form

  ROSELIA_AEVIAN = PokeModifier.add_form(:ROSELIA, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GROUND, :Type2 => :FIGHTING})
              .set_ev([0, 0, 0, 2, 0, 0])
              .set_evolutions([[:ROSERADE, :Item, :SUNSTONE]])
              .set_preevo({:species=>:BUDEW, :form=>1})
              .level_moves([[1, :MUDSLAP], [4, :SANDATTACK], [7, :ROCKSMASH], [10, :CAMOUFLAGE], [13, :ROCKTHROW], [16, :KNOCKOFF], [19, :MUDSHOT], [22, :VACUUMWAVE], [25, :ANCIENTPOWER], [28, :TORMENT], [31, :SANDTOMB], [34, :TAUNT], [37, :LOWSWEEP], [40, :FOULPLAY], [43, :AURASPHERE], [46, :MORNINGSUN], [50, :CLOSECOMBAT]])
              .egg_moves([:EARTHPOWER, :EXTRASENSORY, :FINALGAMBIT, :FOCUSBLAST, :MINDREADER, :MORNINGSUN, :MUDSHOT, :NATURALGIFT, :PINMISSILE, :REVENGE, :ROCKBLAST, :SANDSTORM, :SPIKES, :WEATHERBALL, :YAWN])
              .compatible_moves([:AERIALACE, :AURASPHERE, :BRICKBREAK, :BULLDOZE, :CHARM, :CLOSECOMBAT, :COACHING, :COVET, :CUT, :DARKPULSE, :DEFOG, :DRAINPUNCH, :DUALCHOP, :DYNAMICPUNCH, :EARTHPOWER, :EARTHQUAKE, :ECHOEDVOICE, :ENCORE, :ENDEAVOR, :FIREPUNCH, :FOCUSBLAST, :FOULPLAY, :GUNKSHOT, :KNOCKOFF, :LASERFOCUS, :LASTRESORT, :LOWKICK, :LOWSWEEP, :MEGAPUNCH, :MUDSHOT, :NATUREPOWER, :PINMISSILE, :POISONJAB, :POISONSWEEP, :POWERGEM, :POWERUPPUNCH, :REVERSAL, :ROCKBLAST, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :ROLEPLAY, :SANDSTORM, :SANDTOMB, :SCORCHINGSANDS, :SHADOWBALL, :SMACKDOWN, :SNATCH, :SPIKES, :STACKINGSHOT, :STEALTHROCK, :STOREDPOWER, :STRENGTH, :SUNNYDAY, :SUPERPOWER, :THIEF, :THROATCHOP, :TORMENT, :TOXICSPIKES, :UPROAR, :VACUUMWAVE, :WEATHERBALL, :ARENITEWALL, :MUDBARRAGE, :POISONSWEEP, :STACKINGSHOT])
              .set_dex_entry("It fights dirty to survive; it blinds foes with the sand circling around its neck, then bludgeons them with crystals that formed in the desert sand it picked up.")
              .asset_override(asset: "UniLib/Assets/Battlers/roselia-aevian.png", asset_egg: "UniLib/Assets/Battlers/roselia-aevian_egg.png", asset_egg_f: "UniLib/Assets/Battlers/roselia-aevian_egg_f.png", asset_f: "UniLib/Assets/Battlers/roselia-aevian_f.png", icon: "UniLib/Assets/Icons/roselia-aevian.png", icon_egg: "UniLib/Assets/Icons/roselia-aevian_egg.png", icon_egg_f: "UniLib/Assets/Icons/roselia-aevian_egg_f.png", icon_f: "UniLib/Assets/Icons/roselia-aevian_f.png")
              .get_form

  FEEBAS_AEVIAN = PokeModifier.add_form(:FEEBAS, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :POISON, :Type2 => :FAIRY})
              .set_ev([0, 0, 0, 0, 0, 1])
              .level_moves([[1, :SPLASH], [15, :TACKLE], [25, :FLAIL]])
              .egg_moves([:BRINE, :CONFUSERAY, :CAPTIVATE, :TOXICSPIKES, :HAZE, :MUDSPORT, :BELCH, :CAPTIVATE, :HYPNOSIS])
              .compatible_moves([:VENOSHOCK, :ICEBEAM, :BLIZZARD, :HYPERBEAM, :RAINDANCE, :SLUDGEWAVE, :SLUDGEBOMB, :SLEEPTALK, :SNARL, :DAZZLINGGLEAM, :CHARM, :WHIRLPOOL, :BRINE, :MISTYTERRAIN, :SURF, :LASTRESORT, :BOUNCE, :AMNESIA, :ENCORE, :TOXICSPIKES, :CORROSIVEGAS, :DELUGE, :MUDBARRAGE])
              .set_dex_entry("A rare type of Feebas that has become particularly popular with collectors. The bright fins serve as a warning to predators about the toxins it carries in its body.")
              .asset_override(asset: "UniLib/Assets/Battlers/feebas-aevian.png", asset_egg: "UniLib/Assets/Battlers/feebas-aevian_egg.png", icon: "UniLib/Assets/Icons/feebas-aevian.png", icon_egg: "UniLib/Assets/Icons/feebas-aevian_egg.png")
              .get_form

  MILOTIC_AEVIAN = PokeModifier.add_form(:MILOTIC, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :POISON, :Type2 => :FAIRY})
              .stats([95, 100, 79, 60, 125, 81])
              .abilities({0 => :POISONPOINT, 1 => :MERCILESS, 2 => :DEFIANT})
              .set_ev([0, 0, 0, 0, 2, 0])
              .set_preevo({:species=>:FEEBAS, :form=>1})
              .level_moves([[1, :POISONTAIL], [1, :WRAP], [1, :MOONLIGHT], [1, :POISONSTING], [1, :FAIRYWIND], [1, :REFRESH], [0, :POISONTAIL], [4, :FAIRYWIND], [7, :REFRESH], [11, :DISARMINGVOICE], [14, :SLAM], [17, :VENOMDRENCH], [21, :CHARM], [24, :DRAGONTAIL], [31, :PLAYROUGH], [34, :ATTRACT], [37, :PAINSPLIT], [41, :POISONGAS], [44, :POISONJAB], [51, :TOXIC], [58, :GUNKSHOT], [67, :COIL]])
              .egg_moves([])
              .compatible_moves([:WORKUP, :HAIL, :VENOSHOCK, :TAUNT, :ICEBEAM, :BLIZZARD, :HYPERBEAM, :RAINDANCE, :SLUDGEWAVE, :SLUDGEBOMB, :ROCKTOMB, :TORMENT, :THIEF, :ECHOEDVOICE, :QUASH, :EMBARGO, :PAYBACK, :GIGAIMPACT, :THUNDERWAVE, :PSYCHUP, :BULLDOZE, :DRAGONTAIL, :INFESTATION, :DREAMEATER, :SNARL, :DAZZLINGGLEAM, :ROCKCLIMB, :POISONSWEEP, :IRRITATION, :LEECHLIFE, :CHARM, :WHIRLPOOL, :FAKETEARS, :MUDSHOT, :BRINE, :ASSURANCE, :POWERSWAP, :TAILSLAP, :DRAININGKISS, :MISTYTERRAIN, :SURF, :STRENGTH, :WATERFALL, :DIVE, :UPROAR, :BIND, :LASTRESORT, :COVET, :SNATCH, :IRONTAIL, :SPITE, :ALLYSWITCH, :SIGNALBEAM, :BOUNCE, :WATERPULSE, :AQUATAIL, :PAINSPLIT, :ICYWIND, :MAGICCOAT, :GASTROACID, :SKILLSWAP, :GUNKSHOT, :KNOCKOFF, :BODYSLAM, :DRAGONDANCE, :TOXICSPIKES, :PLAYROUGH, :VENOMDRENCH, :MISTYEXPLOSION, :CORROSIVEGAS, :DELUGE, :MUDBARRAGE])
              .set_dex_entry("Beautiful but highly dangerous, it's seen as a status symbol among the wealthy. Its venom is potent enough to completely immobilize an adult within seconds.")
              .asset_override(asset: "UniLib/Assets/Battlers/milotic-aevian.png", icon: "UniLib/Assets/Icons/milotic-aevian.png")
              .get_form

  SNORUNT_AEVIAN = PokeModifier.add_form(:SNORUNT, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GRASS, :Type2 => :ROCK})
              .set_ev([1, 0, 0, 0, 0, 0])
              .set_evolutions([[:GLALIE, :Level, 42], [:FROSLASS, :ItemFemale, :WATERSTONE]])
              .level_moves([[1, :ABSORB], [1, :LEER], [5, :WORRYSEED], [10, :ROCKTHROW], [14, :RAZORLEAF], [19, :PAYBACK], [23, :LEAFTORNADO], [28, :HEADBUTT], [32, :PROTECT], [37, :CAMOUFLAGE], [41, :ROCKSLIDE], [46, :WOODHAMMER], [50, :GRASSYTERRAIN]])
              .egg_moves([:BIDE, :CHIPAWAY, :DISABLE, :FAKETEARS, :LEECHSEED, :ROLLOUT, :SPIKES, :SWITCHEROO, :WEATHERBALL, :WIDEGUARD])
              .compatible_moves([:AFTERYOU, :ALLYSWITCH, :ASSURANCE, :AVALANCHE, :BODYSLAM, :BULLETSEED, :ENDEAVOR, :ENERGYBALL, :FAKETEARS, :GIGADRAIN, :GRASSKNOT, :GRASSYGLIDE, :GRASSYTERRAIN, :GYROBALL, :IRONHEAD, :LEAFSTORM, :MAGICALLEAF, :MAGNETRISE, :MUDSHOT, :NATUREPOWER, :PAYBACK, :POWERGEM, :RAINDANCE, :ROCKBLAST, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDSTORM, :SEEDBOMB, :SHADOWBALL, :SOLARBEAM, :SPIKES, :STEELROLLER, :SUCKERPUNCH, :SUNNYDAY, :SYNTHESIS, :WEATHERBALL, :WORRYSEED, :ZENHEADBUTT, :IRRITATION, :MUDBARRAGE])
              .set_dex_entry("While it has adapted to Terajuma's climate, its natural instincts still remember the time where it happily shivered in the cold. It feels nostalgic when in cold areas.")
              .asset_override(asset: "UniLib/Assets/Battlers/snorunt-aevian.png", asset_egg: "UniLib/Assets/Battlers/snorunt-aevian_egg.png", asset_egg_f: "UniLib/Assets/Battlers/snorunt-aevian_egg_f.png", icon: "UniLib/Assets/Icons/snorunt-aevian.png", icon_egg: "UniLib/Assets/Icons/snorunt-aevian_egg.png", icon_egg_f: "UniLib/Assets/Icons/snorunt-aevian_egg_f.png")
              .get_form

  GLALIE_AEVIAN = PokeModifier.add_form(:GLALIE, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GRASS, :Type2 => :ROCK})
              .stats([110, 100, 90, 50, 80, 50])
              .abilities({0 => :GRASSYSURGE, 1 => :ROCKHEAD, 2 => :STAMINA})
              .set_ev([2, 0, 0, 0, 0, 0])
              .set_preevo({:species=>:SNORUNT, :form=>1})
              .level_moves([[1, :GRASSYTERRAIN], [1, :GRASSYGLIDE], [1, :LEECHSEED], [1, :LEER], [1, :ABSORB], [1, :ROCKTHROW], [1, :WORRYSEED], [0, :DOUBLEEDGE], [5, :WORRYSEED], [10, :ROCKTHROW], [14, :RAZORLEAF], [19, :PAYBACK], [23, :LEAFTORNADO], [28, :HEADBUTT], [32, :PROTECT], [37, :CAMOUFLAGE], [41, :ROCKSLIDE], [48, :WOODHAMMER], [54, :GRASSYTERRAIN], [60, :HEADSMASH]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :ALLYSWITCH, :AMNESIA, :ARENITEWALL, :ASSURANCE, :AVALANCHE, :BLOCK, :BODYPRESS, :BODYSLAM, :BULLDOZE, :BULLETSEED, :COSMICPOWER, :EARTHPOWER, :EARTHQUAKE, :ENDEAVOR, :ENERGYBALL, :EXPLOSION, :FAKETEARS, :FOULPLAY, :GIGADRAIN, :GIGAIMPACT, :GRASSKNOT, :GRASSYGLIDE, :GRASSYTERRAIN, :GRAVITY, :GUARDSWAP, :GYROBALL, :HEATCRASH, :HELPINGHAND, :HYPERBEAM, :ICEFANG, :IRONDEFENSE, :IRONHEAD, :LEAFSTORM, :MAGICALLEAF, :MAGNETRISE, :METEORBEAM, :MUDSHOT, :NATUREPOWER, :PAYBACK, :POWERGEM, :RAINDANCE, :ROCKBLAST, :ROCKPOLISH, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDTOMB, :SANDSTORM, :SCARYFACE, :SEEDBOMB, :SELFDESTRUCT, :SHADOWBALL, :SLASHANDBURN, :SOLARBEAM, :SPIKES, :STEALTHROCK, :STEELROLLER, :STONEEDGE, :STRENGTH, :SUCKERPUNCH, :SUNNYDAY, :SYNTHESIS, :TAUNT, :UPROAR, :WEATHERBALL, :WORRYSEED, :ZENHEADBUTT, :IRRITATION, :MUDBARRAGE])
              .set_dex_entry("It camouflages among moss covered rocks. Whether disturbed by prey or trainer, an encounter will leave unmistakable bite marks.")
              .asset_override(asset: "UniLib/Assets/Battlers/glalie-aevian.png", icon: "UniLib/Assets/Icons/glalie-aevian.png")
              .get_form

  BUDEW_AEVIAN = PokeModifier.add_form(:BUDEW, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GROUND, :Type2 => :GROUND})
              .set_ev([0, 0, 0, 1, 0, 0])
              .level_moves([[1, :MUDSLAP], [4, :SANDATTACK], [7, :MUDSPORT], [10, :CAMOUFLAGE], [13, :ROCKTHROW], [16, :CHARM]])
              .egg_moves([:EARTHPOWER, :EXTRASENSORY, :FINALGAMBIT, :MINDREADER, :MORNINGSUN, :MUDSHOT, :NATURALGIFT, :PINMISSILE, :REVENGE, :ROCKBLAST, :SANDSTORM, :SPIKES, :WEATHERBALL, :YAWN])
              .compatible_moves([:ARENITEWALL, :AURASPHERE, :BULLDOZE, :CHARM, :COVET, :CUT, :EARTHPOWER, :EARTHQUAKE, :ECHOEDVOICE, :ENCORE, :ENDEAVOR, :FOCUSBLAST, :FOULPLAY, :LASERFOCUS, :LOWSWEEP, :MUDSHOT, :NATUREPOWER, :PINMISSILE, :POWERGEM, :REVERSAL, :ROCKBLAST, :ROCKSLIDE, :ROCKTOMB, :ROLEPLAY, :SANDTOMB, :SANDSTORM, :SCORCHINGSANDS, :SMACKDOWN, :SNATCH, :SPIKES, :STEALTHROCK, :SUNNYDAY, :THIEF, :THROATCHOP, :TOXICSPIKES, :UPROAR, :VACUUMWAVE, :WEATHERBALL, :MUDBARRAGE])
              .set_dex_entry("Having to suddenly adapt to the desert climate after the calamity lead to Budew drying out but barely surviving. It hides itself in sand dunes from predators.")
              .asset_override(asset: "UniLib/Assets/Battlers/budew-aevian.png", asset_egg: "UniLib/Assets/Battlers/budew-aevian_egg.png", icon: "UniLib/Assets/Icons/budew-aevian.png", icon_egg: "UniLib/Assets/Icons/budew-aevian_egg.png")
              .get_form

  ROSERADE_AEVIAN = PokeModifier.add_form(:ROSERADE, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GROUND, :Type2 => :FIGHTING})
              .set_ev([0, 0, 0, 3, 0, 0])
              .set_preevo({:species=>:ROSELIA, :form=>1})
              .level_moves([[1, :EARTHPOWER], [1, :ROTOTILLER], [1, :POWERGEM], [1, :ROCKSMASH], [1, :ROCKTHROW], [1, :MUDSHOT], [1, :VACUUMWAVE]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :ARENITEWALL, :AURASPHERE, :BEATUP, :BRICKBREAK, :BRUTALSWING, :BULLDOZE, :CHARM, :CLOSECOMBAT, :COACHING, :COVET, :CUT, :DARKPULSE, :DEFOG, :DIG, :DRAINPUNCH, :DUALCHOP, :DYNAMICPUNCH, :EARTHPOWER, :EARTHQUAKE, :ECHOEDVOICE, :ENCORE, :ENDEAVOR, :FIREPUNCH, :FOCUSBLAST, :FOCUSPUNCH, :FOULPLAY, :GIGAIMPACT, :GUNKSHOT, :HYPERBEAM, :KNOCKOFF, :LASERFOCUS, :LASTRESORT, :LOWKICK, :LOWSWEEP, :MEGAPUNCH, :METRONOME, :MUDSHOT, :NATUREPOWER, :PAYBACK, :PINMISSILE, :PLAYROUGH, :POISONJAB, :POISONSWEEP, :POWERGEM, :POWERUPPUNCH, :RETALIATE, :RETURN, :REVERSAL, :ROCKBLAST, :ROCKSMASH, :ROCKTOMB, :ROCKSLIDE, :ROLEPLAY, :SANDTOMB, :SANDSTORM, :SCORCHINGSANDS, :SHADOWBALL, :SLEEPTALK, :SMACKDOWN, :SNARL, :SNATCH, :SPIKES, :STACKINGSHOT, :STEALTHROCK, :STOMPINGTANTRUM, :STONEEDGE, :STOREDPOWER, :STRENGTH, :SUCKERPUNCH, :SUNNYDAY, :SUPERPOWER, :THIEF, :THROATCHOP, :TORMENT, :TOXICSPIKES, :UPROAR, :VACUUMWAVE, :WEATHERBALL, :WORKUP, :ARENITEWALL, :MUDBARRAGE, :POISONSWEEP, :STACKINGSHOT])
              .set_dex_entry("Now predator instead of prey, Roserade hunts for resources during sandstorms, its sand cloak allowing for perfect camouflage. It defends its territory fiercely.")
              .asset_override(asset: "UniLib/Assets/Battlers/roserade-aevian.png", asset_f: "UniLib/Assets/Battlers/roserade-aevian_f.png", icon: "UniLib/Assets/Icons/roserade-aevian.png", icon_f: "UniLib/Assets/Icons/roserade-aevian_f.png")
              .get_form

  MISMAGIUS_AEVIAN = PokeModifier.add(:MISMAGIUS, "Aevian Form")
              .remove_level_moves(:SHADOWCLAW)
              .level_moves([0, :HEXINGSLASH])

  MoveBuilder.add(:HEXINGSLASH, "Hexing Slash", "A relentless attack using cursed tendrils. Drains HP and has a chance to poison.", :GHOST, :physical, 15, 90, 100, 0x208)

  class PokeBattle_Move_208 < PokeBattle_Move

    def pbEffect(attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
      damage = super(attacker, opponent, hitnum, alltargets, showanimation)
      if opponent.damagestate.calcdamage > 0 && !opponent.damagestate.disguise
        hpgain = ((damage + 1) / 2).floor
        hpgain = ((damage + 1) * 3 / 4).floor if Rejuv && @battle.FE == :ELECTERRAIN && @move == :PARABOLICCHARGE
        hpgain = ((damage + 1) * 3 / 4).floor if Rejuv && @battle.FE == :GRASSY && [:ABSORB, :MEGADRAIN, :GIGADRAIN, :HORNLEECH].include?(@move)
        if opponent.ability == :LIQUIDOOZE
          hpgain *= 2 if [:WASTELAND, :MURKWATERSURFACE, :CORRUPTED].include?(@battle.FE)
          attacker.pbReduceHP(hpgain, true)
          @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", attacker.pbThis))
        else
          hpgain = (hpgain * (Rejuv && @battle.FE == :GRASSY ? 1.6 : 1.3)).floor if attacker.hasWorkingItem(:BIGROOT)
          hpgain = (hpgain * 1.3).floor if attacker.crested == :SHIINOTIC
          attacker.pbRecoverHP(hpgain, true)
          @battle.pbDisplay(_INTL("{1} had its energy drained!", opponent.pbThis))
        end
      end
      damage
    end

    def pbAdditionalEffect(attacker,opponent)
      return false unless opponent.pbCanPoison?(false)
      opponent.pbPoison(attacker)
      @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
      true
    end

    def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
      return unless showanimation
      @battle.pbAnimation(:SHADOWCLAW, attacker, opponent, hitnum)
    end

  end

  BRONZOR_AEVIAN = PokeModifier.add_form(:BRONZOR, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :STEEL, :Type2 => :STEEL})
              .set_ev([0, 0, 1, 0, 0, 0])
              .level_moves([[1, :FLASH], [1, :NIGHTSHADE], [5, :FLASH], [9, :METALSOUND], [11, :MIRRORSHOT], [15, :MAGICCOAT], [19, :MIMIC], [21, :SIGNALBEAM], [25, :NIGHTSHADE], [29, :MEFIRST], [31, :METALSOUND], [35, :GYROBALL], [39, :FLASHCANNON], [41, :PAYBACK], [45, :HEALBLOCK], [49, :MIRRORCOAT]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :ALLYSWITCH, :ASSURANCE, :AURASPHERE, :BLOCK, :CALMMIND, :CHARGEBEAM, :DARKPULSE, :DAZZLINGGLEAM, :DREAMEATER, :EERIEIMPULSE, :EXPLOSION, :FLASH, :FLASHCANNON, :FUTURESIGHT, :GRASSKNOT, :GRAVITY, :GUARDSWAP, :GYROBALL, :HAIL, :HEAVYSLAM, :HEX, :ICEBEAM, :IRONDEFENSE, :IRONHEAD, :LIGHTSCREEN, :MAGICCOAT, :MAGICROOM, :MAGICALLEAF, :MYSTICALFIRE, :PAYBACK, :PSYCHUP, :PSYCHIC, :PSYSHOCK, :RAINDANCE, :RECYCLE, :REFLECT, :ROCKPOLISH, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :ROLEPLAY, :SAFEGUARD, :SANDSTORM, :SELFDESTRUCT, :SHADOWBALL, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SNATCH, :STEALTHROCK, :STEELBEAM, :SUNNYDAY, :TERRAINPULSE, :THUNDERWAVE, :THUNDERBOLT, :TORMENT, :TRIATTACK, :TRICK, :TRICKROOM, :WATERPULSE, :WEATHERBALL, :WONDERROOM, :ARENITEWALL])
              .set_dex_entry("The energy of Black Shards has created a mirror surface on its body. If the cave suddenly changes appearance, it's likely one has passed by an active crystal.")
              .asset_override(asset: "UniLib/Assets/Battlers/bronzor-aevian.png", asset_egg: "UniLib/Assets/Battlers/bronzor-aevian_egg.png", icon: "UniLib/Assets/Icons/bronzor-aevian.png", icon_egg: "UniLib/Assets/Icons/bronzor-aevian_egg.png")
              .get_form

  BRONZONG_AEVIAN = PokeModifier.add_form(:BRONZONG, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :STEEL, :Type2 => :STEEL})
              .stats([67, 79, 116, 89, 116, 33])
              .abilities({0 => :REFLECTOR, 1 => nil, 2 => :REFLECTOR})
              .set_ev([0, 0, 1, 0, 1, 0])
              .set_preevo({:species=>:BRONZOR, :form=>1})
              .level_moves([[0, :MIRRORBEAM], [1, :MIRRORMOVE], [1, :COPYCAT], [1, :CONFUSERAY], [1, :SPOTLIGHT], [1, :FLASH], [1, :NIGHTSHADE], [5, :FLASH], [9, :METALSOUND], [11, :MIRRORSHOT], [15, :MAGICCOAT], [19, :MIMIC], [21, :SIGNALBEAM], [25, :NIGHTSHADE], [29, :MEFIRST], [31, :METALSOUND], [33, :REFLECT], [33, :LIGHTSCREEN], [36, :GYROBALL], [42, :FLASHCANNON], [46, :PAYBACK], [52, :HEALBLOCK], [58, :MIRRORCOAT]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :ALLYSWITCH, :ASSURANCE, :AURASPHERE, :BLOCK, :BODYPRESS, :CALMMIND, :CHARGEBEAM, :DARKPULSE, :DAZZLINGGLEAM, :DREAMEATER, :EERIEIMPULSE, :EXPLOSION, :FLASH, :FLASHCANNON, :FUTURESIGHT, :GIGAIMPACT, :GRASSKNOT, :GRAVITY, :GUARDSWAP, :GYROBALL, :HAIL, :HEAVYSLAM, :HEX, :HYPERBEAM, :ICEBEAM, :IRONDEFENSE, :IRONHEAD, :LIGHTSCREEN, :MAGICCOAT, :MAGICROOM, :MAGICALLEAF, :MYSTICALFIRE, :PAYBACK, :PSYCHUP, :PSYCHIC, :PSYSHOCK, :RAINDANCE, :RECYCLE, :REFLECT, :ROCKPOLISH, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :ROLEPLAY, :SAFEGUARD, :SANDSTORM, :SELFDESTRUCT, :SHADOWBALL, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SNATCH, :STEALTHROCK, :STEELBEAM, :STEELROLLER, :STRENGTH, :SUNNYDAY, :TERRAINPULSE, :THUNDERWAVE, :THUNDERBOLT, :TORMENT, :TRIATTACK, :TRICK, :TRICKROOM, :WATERPULSE, :WEATHERBALL, :WONDERROOM, :ARENITEWALL, :QUICKSILVERSPEAR])
              .set_dex_entry("It is said that looking at your reflection in Bronzong's mirror will show you your destiny. The accuracy of this is still debated.")
              .asset_override(asset: "UniLib/Assets/Battlers/bronzong-aevian.png", icon: "UniLib/Assets/Icons/bronzong-aevian.png")
              .get_form

  FROSLASS_AEVIAN = PokeModifier.add_form(:FROSLASS, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GRASS, :Type2 => :WATER})
              .set_ev([0, 0, 0, 0, 0, 2])
              .set_preevo({:species=>:SNORUNT, :form=>1})
              .level_moves([[1, :GRASSYTERRAIN], [1, :MUDDYWATER], [1, :ABSORB], [1, :LEER], [1, :BUBBLEBEAM], [1, :WORRYSEED], [0, :MUDDYWATER], [5, :WORRYSEED], [10, :BUBBLEBEAM], [14, :RAZORLEAF], [19, :AQUARING], [23, :LEAFTORNADO], [28, :TOXIC], [32, :CONFUSERAY], [37, :SOAK], [41, :HYDROPUMP], [42, :RAINDANCE], [48, :GIGADRAIN], [54, :GRASSYTERRAIN], [61, :WATERSPOUT]])
              .egg_moves([])
              .compatible_moves([:AGILITY, :ALLYSWITCH, :ASSURANCE, :BODYSLAM, :BRINE, :BULLETSEED, :DELUGE, :DIVE, :DRAININGKISS, :ENERGYBALL, :FAKETEARS, :FLASH, :FLING, :FLIPTURN, :GIGADRAIN, :GIGAIMPACT, :GRASSKNOT, :GRASSYGLIDE, :GRASSYTERRAIN, :GUNKSHOT, :HELPINGHAND, :HYDROPUMP, :HYPERBEAM, :ICEPUNCH, :ICYWIND, :INFESTATION, :IRONHEAD, :LASTRESORT, :LEAFSTORM, :LEECHLIFE, :LIQUIDATION, :MAGICALLEAF, :MAGNETRISE, :MUDSHOT, :MUDDYWATER, :NASTYPLOT, :NATUREPOWER, :PAYBACK, :POWERGEM, :POWERSWAP, :POWERWHIP, :RAINDANCE, :RETALIATE, :ROCKBLAST, :ROCKSLIDE, :ROCKTOMB, :SANDSTORM, :SCALD, :SEEDBOMB, :SHADOWBALL, :SIGNALBEAM, :SLASHANDBURN, :SLUDGEWAVE, :SNATCH, :SOLARBEAM, :SPIKES, :STEELROLLER, :SUCKERPUNCH, :SUNNYDAY, :SURF, :SYNTHESIS, :TORMENT, :TOXICSPIKES, :VENOSHOCK, :WATERPULSE, :WATERFALL, :WEATHERBALL, :WHIRLPOOL, :WORRYSEED, :ZENHEADBUTT, :DELUGE, :IRRITATION, :MUDBARRAGE])
              .set_dex_entry("The folktale of the 'Lurking Lady' warns of how this Pokémon hides among algae, waiting to drown unsuspecting bystanders.")
              .asset_override(asset: "UniLib/Assets/Battlers/froslass-aevian.png", icon: "UniLib/Assets/Icons/froslass-aevian.png")
              .get_form

  MUNNA_AEVIAN = PokeModifier.add_form(:MUNNA, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :DARK, :Type2 => :FAIRY})
              .stats([76, 67, 45, 25, 45, 24])
              .abilities({0 => :BADDREAMS, 1 => :SHEDSKIN, 2 => :TOUGHCLAWS})
              .set_ev([1, 0, 0, 0, 0, 0])
              .set_evolutions([[:MUSHARNA, :Item, :NIGHTMAREFUEL]])
              .level_moves([[1, :DRAININGKISS], [1, :LEER], [5, :SCRATCH], [7, :YAWN], [11, :ASSURANCE], [13, :NIGHTMARE], [17, :MOONLIGHT], [19, :HYPNOSIS], [23, :NIGHTSLASH], [25, :SLASH], [29, :PLAYROUGH], [31, :SHADOWCLAW], [35, :HONECLAWS], [37, :THROATCHOP], [41, :LOVELYKISS], [43, :GLARE]])
              .egg_moves([:ASSIST, :CURSE, :DISABLE, :ENCORE, :MEANLOOK, :MEMENTO, :NIGHTSHADE, :SNORE, :SONICBOOM])
              .compatible_moves([:AERIALACE, :AMNESIA, :ASSURANCE, :AURASPHERE, :BATONPASS, :CHARGEBEAM, :CUT, :DARKPULSE, :DAZZLINGGLEAM, :DRAININGKISS, :DREAMEATER, :ENCORE, :FAKETEARS, :FALSESWIPE, :FLING, :FUTURESIGHT, :GASTROACID, :GIGAIMPACT, :GRAVITY, :GYROBALL, :HAIL, :HONECLAWS, :HYPERBEAM, :KNOCKOFF, :LASERFOCUS, :LASHOUT, :LEECHLIFE, :MAGICCOAT, :MAGICROOM, :PAINSPLIT, :PAYBACK, :PLAYROUGH, :POWERSWAP, :PSYCHIC, :PSYCHUP, :QUASH, :ROCKTOMB, :SANDSTORM, :SCARYFACE, :SCREECH, :SHADOWBALL, :SHADOWCLAW, :SKILLSWAP, :SMACKDOWN, :SNARL, :SNATCH, :SPITE, :SWORDSDANCE, :TAUNT, :THROATCHOP, :TORMENT, :TRICK, :TRICKROOM, :UPROAR, :WATERPULSE, :WONDERROOM, :WORKUP, :WORRYSEED])
              .set_weight(101)
              .set_dex_entry("Since it's attracted to the negative emotions nightmares induce, Aevian Munna has gotten a false reputation as a harbinger of nightmares.")
              .asset_override(asset: "UniLib/Assets/Battlers/munna-aevian.png", asset_egg: "UniLib/Assets/Battlers/munna-aevian_egg.png", icon: "UniLib/Assets/Icons/munna-aevian.png", icon_egg: "UniLib/Assets/Icons/munna-aevian_egg.png")
              .get_form

  MUSHARNA_AEVIAN = PokeModifier.add_form(:MUSHARNA, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :DARK, :Type2 => :FAIRY})
              .stats([116, 107, 85, 65, 85, 29])
              .abilities({0 => :BADDREAMS, 1 => :SHEDSKIN, 2 => :TOUGHCLAWS})
              .set_ev([2, 0, 0, 0, 0, 0])
              .set_preevo({:species=>:MUNNA, :form=>1})
              .level_moves([[1, :MISTYTERRAIN], [1, :DRAININGKISS], [1, :LEER], [1, :ASSURANCE], [1, :LOVELYKISS]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :AMNESIA, :ASSURANCE, :AURASPHERE, :BATONPASS, :BEATUP, :BLOCK, :BODYPRESS, :BODYSLAM, :BREAKINGSWIPE, :BRUTALSWING, :CHARGEBEAM, :CROSSPOISON, :CUT, :DARKESTLARIAT, :DARKPULSE, :DAZZLINGGLEAM, :DRAININGKISS, :DREAMEATER, :DUALCHOP, :EERIEIMPULSE, :ENCORE, :EXPLOSION, :FAKETEARS, :FALSESWIPE, :FLING, :FLY, :FOULPLAY, :FUTURESIGHT, :GASTROACID, :GIGAIMPACT, :GRAVITY, :GYROBALL, :HAIL, :HONECLAWS, :HYPERBEAM, :KNOCKOFF, :LASERFOCUS, :LASHOUT, :LEECHLIFE, :MAGICCOAT, :MAGICROOM, :MISTYTERRAIN, :PAINSPLIT, :PAYBACK, :PHANTOMFORCE, :PLAYROUGH, :POISONJAB, :POWERGEM, :POWERSWAP, :PSYCHIC, :PSYCHOCUT, :PSYCHUP, :QUASH, :ROCKCLIMB, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDSTORM, :SCARYFACE, :SCREECH, :SELFDESTRUCT, :SHADOWBALL, :SHADOWCLAW, :SKILLSWAP, :SLASHANDBURN, :SMACKDOWN, :SNARL, :SNATCH, :SPITE, :STOREDPOWER, :STRENGTH, :SWORDSDANCE, :SUCKERPUNCH, :TAUNT, :THROATCHOP, :TORMENT, :TRICK, :TRICKROOM, :UPROAR, :VENOMDRENCH, :WATERPULSE, :WILLOWISP, :WONDERROOM, :WORKUP, :WORRYSEED, :XSCISSOR, :ZENHEADBUTT])
              .set_dex_entry("The mist it produces causes nightmares when inhaled, but can also be manipulated by Musharna to solidify and work as a sharp claw. It feeds on the fear of those it scares.")
              .asset_override(asset: "UniLib/Assets/Battlers/musharna-aevian.png", icon: "UniLib/Assets/Icons/musharna-aevian.png")
              .get_form

  SEWADDLE_AEVIAN = PokeModifier.add_form(:SEWADDLE, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :BUG, :Type2 => :DRAGON})
              .stats([45, 63, 65, 40, 55, 42])
              .abilities({0 => :SWARM, 1 => :UNNERVE, 2 => :INTIMIDATE})
              .set_ev([0, 0, 1, 0, 0, 0])
              .level_moves([[1, :BITE], [1, :STRINGSHOT], [8, :BUGBITE], [15, :TWISTER], [22, :STRUGGLEBUG], [29, :ENDURE], [31, :STICKYWEB], [36, :BUGBUZZ], [43, :FLAIL]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :AGILITY, :AIRSLASH, :BATONPASS, :BUGBITE, :BUGBUZZ, :BULLETSEED, :CALMMIND, :CRUNCH, :CUT, :DRACOMETEOR, :DRAGONPULSE, :DREAMEATER, :ELECTROWEB, :ENDEAVOR, :FLASH, :FOCUSENERGY, :GIGADRAIN, :HEALBELL, :INFESTATION, :IRONDEFENSE, :IRRITATION, :LEECHLIFE, :NATUREPOWER, :OUTRAGE, :PAYBACK, :PINMISSILE, :POLLENPUFF, :PSYCHUP, :REFLECT, :ROAR, :SAFEGUARD, :SCALESHOT, :SCARYFACE, :SCREECH, :SIGNALBEAM, :SKITTERSMACK, :STRINGSHOT, :STRUGGLEBUG, :SUNNYDAY, :TOXIC, :IRRITATION])
              .set_dex_entry("Driven into a corner by increasing urbanisation, this Sewaddle started turning its leaves into shapes resembling more of a skull to scare off any unwanted predators.")
              .asset_override(asset: "UniLib/Assets/Battlers/sewaddle-aevian.png", asset_egg: "UniLib/Assets/Battlers/sewaddle-aevian_egg.png", icon: "UniLib/Assets/Icons/sewaddle-aevian.png", icon_egg: "UniLib/Assets/Icons/sewaddle-aevian_egg.png")
              .get_form

  SWADLOON_AEVIAN = PokeModifier.add_form(:SWADLOON, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :BUG, :Type2 => :DRAGON})
              .stats([55, 73, 85, 50, 75, 42])
              .abilities({0 => :SWARM, 1 => :UNNERVE, 2 => :INTIMIDATE})
              .set_ev([0, 0, 2, 0, 0, 0])
              .set_evolutions([[:LEAVANNY, :HasMove, :DRAGONCLAW]])
              .set_preevo({:species=>:SEWADDLE, :form=>1})
              .level_moves([[1, :PROTECT], [1, :GRASSWHISTLE], [1, :BITE], [1, :STRINGSHOT], [1, :BUGBITE], [1, :TWISTER], [0, :PROTECT], [23, :BREAKINGSWIPE], [27, :CAMOUFLAGE], [32, :DRAGONCLAW]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :AGILITY, :AIRSLASH, :ASSURANCE, :BATONPASS, :BREAKINGSWIPE, :BUGBITE, :BUGBUZZ, :BULLETSEED, :CALMMIND, :CRUNCH, :CUT, :DRACOMETEOR, :DRAGONCLAW, :DRAGONPULSE, :DREAMEATER, :ELECTROWEB, :ENDEAVOR, :FLASH, :FOCUSENERGY, :GIGADRAIN, :HEALBELL, :INFESTATION, :IRONDEFENSE, :IRRITATION, :LEECHLIFE, :NATUREPOWER, :OUTRAGE, :PAYBACK, :PINMISSILE, :POLLENPUFF, :PSYCHUP, :REFLECT, :ROAR, :SAFEGUARD, :SCALESHOT, :SCARYFACE, :SCREECH, :SIGNALBEAM, :SKITTERSMACK, :STRINGSHOT, :STRUGGLEBUG, :SUNNYDAY, :TOXIC, :IRRITATION])
              .set_dex_entry("Using its silhouette to ward off enemies, it prefers hiding in darker spots where visibility isn't as high. It's prone to attacking anyone that gets too close while it's eating.")
              .asset_override(asset: "UniLib/Assets/Battlers/swadloon-aevian.png", icon: "UniLib/Assets/Icons/swadloon-aevian.png")
              .get_form

  LEAVANNY_AEVIAN = PokeModifier.add_form(:LEAVANNY, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :BUG, :Type2 => :DRAGON})
              .stats([75, 108, 75, 70, 75, 97])
              .abilities({0 => :SWARM, 1 => :UNNERVE, 2 => :INTIMIDATE})
              .set_ev([0, 3, 0, 0, 0, 0])
              .set_preevo({:species=>:SWADLOON, :form=>1})
              .level_moves([[1, :SLASH], [1, :FALSESWIPE], [1, :BITE], [1, :STRINGSHOT], [1, :BUGBITE], [1, :TWISTER], [0, :SLASH], [8, :BUGBITE], [15, :TWISTER], [22, :STRUGGLEBUG], [29, :NATURALGIFT], [32, :RAGEPOWDER], [36, :DUALCHOP], [39, :FELLSTINGER], [43, :XSCISSOR], [46, :SWORDSDANCE], [50, :DRAGONRUSH]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :AFTERYOU, :AGILITY, :AIRSLASH, :AQUATAIL, :ASSURANCE, :BATONPASS, :BEATUP, :BREAKINGSWIPE, :BUGBITE, :BUGBUZZ, :BULLETSEED, :CALMMIND, :CRUNCH, :CUT, :DRACOMETEOR, :DRAGONCLAW, :DRAGONDANCE, :DRAGONPULSE, :DRAGONTAIL, :DREAMEATER, :DUALCHOP, :DUALWINGBEAT, :ELECTROWEB, :ENCORE, :ENDEAVOR, :FALSESWIPE, :FLASH, :FLING, :FOCUSENERGY, :GIGADRAIN, :GIGAIMPACT, :HEALBELL, :HYPERBEAM, :INFESTATION, :IRONDEFENSE, :IRONTAIL, :IRRITATION, :LASERFOCUS, :LEECHLIFE, :MEGAHORN, :NATUREPOWER, :OUTRAGE, :PAYBACK, :PINMISSILE, :POISONJAB, :POLLENPUFF, :PSYCHUP, :REFLECT, :ROAR, :SAFEGUARD, :SCALESHOT, :SCARYFACE, :SCREECH, :SHADOWCLAW, :SIGNALBEAM, :SKITTERSMACK, :SOLARBEAM, :SOLARBLADE, :STRINGSHOT, :STRUGGLEBUG, :SUNNYDAY, :SWORDSDANCE, :THROATCHOP, :WEATHERBALL, :XSCISSOR, :IRRITATION, :SLASHANDBURN])
              .set_dex_entry("It is fiercely protective of smaller Pokémon, but avoids conflict if possible and will try to intimidate predators instead. The leaves on Leavanny's arms are razor sharp.")
              .asset_override(asset: "UniLib/Assets/Battlers/leavanny-aevian.png", icon: "UniLib/Assets/Icons/leavanny-aevian.png")
              .get_form

  SIGILYPH_AEVIAN = PokeModifier.add_form(:SIGILYPH, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FAIRY, :Type2 => :GHOST})
              .set_ev([0, 0, 0, 2, 0, 0])
              .level_moves([[1, :ASTONISH], [1, :MIRACLEEYE], [4, :HYPNOSIS], [8, :FAIRYWIND], [11, :TAILWIND], [14, :WHIRLWIND], [18, :NIGHTSHADE], [21, :DRAININGKISS], [24, :LUCKYCHANT], [28, :SAFEGUARD], [31, :OMINOUSWIND], [34, :NIGHTMARE], [38, :MINDREADER], [41, :HEX], [44, :DREAMEATER], [46, :MYSTICALFIRE], [48, :COSMICPOWER], [50, :MOONBLAST]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :AIRSLASH, :ALLYSWITCH, :AURASPHERE, :CALMMIND, :CHARGEBEAM, :COSMICPOWER, :DARKPULSE, :DAZZLINGGLEAM, :DEFOG, :DRAININGKISS, :DREAMEATER, :DUALWINGBEAT, :ENERGYBALL, :FIRESPIN, :FLAMETHROWER, :FLASH, :FLY, :FUTURESIGHT, :GIGAIMPACT, :GRAVITY, :GUARDSWAP, :HEATWAVE, :HEX, :HYPERBEAM, :ICYWIND, :INCINERATE, :LIGHTSCREEN, :MAGICCOAT, :MAGICROOM, :MISTYEXPLOSION, :MISTYTERRAIN, :MYSTICALFIRE, :PAINSPLIT, :PHANTOMFORCE, :POLTERGEIST, :POWERSWAP, :PSYCHIC, :REFLECT, :ROOST, :SAFEGUARD, :SHADOWBALL, :SHADOWCLAW, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SOLARBEAM, :SPITE, :STEELWING, :STOREDPOWER, :TAILWIND, :THIEF, :THUNDERWAVE, :TRICK, :TRICKROOM, :WILLOWISP, :WONDERROOM, :IRRITATION])
              .set_dex_entry("This alteration of Sigilyph is rarely seen. It appears only to those who have experienced traumatic grief. They feed off terrible dreams.")
              .asset_override(asset: "UniLib/Assets/Battlers/sigilyph-aevian.png", asset_egg: "UniLib/Assets/Battlers/sigilyph-aevian_egg.png", icon: "UniLib/Assets/Icons/sigilyph-aevian.png", icon_egg: "UniLib/Assets/Icons/sigilyph-aevian_egg.png")
              .get_form

  LITWICK_AEVIAN = PokeModifier.add_form(:LITWICK, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GHOST, :Type2 => :FIRE})
              .stats([50, 35, 55, 65, 55, 20])
              .abilities({0 => :ILLUMINATE, 1 => :FLASHFIRE, 2 => :INFILTRATOR})
              .set_ev([0, 0, 0, 1, 0, 0])
              .set_evolutions([[:LAMPENT, :HasMove, :ZAPCANNON]])
              .level_moves([[1, :EMBER], [1, :ASTONISH], [3, :CHARGE], [7, :SMOG], [10, :EMBER], [13, :NIGHTSHADE], [16, :NUZZLE], [20, :FIRESPIN], [24, :EERIEIMPULSE], [28, :HEX], [33, :MEMENTO], [38, :CHARGEBEAM], [40, :ZAPCANNON], [43, :CURSE], [49, :SHADOWBALL], [55, :PAINSPLIT], [60, :DISCHARGE]])
              .egg_moves([:ACID, :ACIDARMOR, :CAPTIVATE, :CLEARSMOG, :ENDURE, :HAZE, :DISCHARGE, :POWERSPLIT])
              .compatible_moves([:ALLYSWITCH, :BURNINGJEALOUSY, :CALMMIND, :DARKPULSE, :DREAMEATER, :EERIEIMPULSE, :ELECTROBALL, :ELECTROWEB, :EMBARGO, :FIRESPIN, :FLAMECHARGE, :FLASH, :FOULPLAY, :FUTURESIGHT, :HEX, :ICYWIND, :IRONDEFENSE, :LASERFOCUS, :MAGICROOM, :MAGNETRISE, :OVERHEAT, :PAINSPLIT, :PAYBACK, :POLTERGEIST, :PSYCHUP, :PSYCHIC, :RECYCLE, :SAFEGUARD, :SHADOWBALL, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SPIKES, :SPITE, :STOREDPOWER, :TAUNT, :TERRAINPULSE, :THIEF, :THUNDER, :THUNDERBOLT, :TORMENT, :TRICK, :TRICKROOM, :UPROAR, :WILLOWISP, :WONDERROOM, :ZAPCANNON])
              .set_dex_entry("It took on this form during the industrial era. If you see one in your house, take a break as these Litwick drain energy from overworked people.")
              .asset_override(asset: "UniLib/Assets/Battlers/litwick-aevian.png", asset_egg: "UniLib/Assets/Battlers/litwick-aevian_egg.png", icon: "UniLib/Assets/Icons/litwick-aevian.png", icon_egg: "UniLib/Assets/Icons/litwick-aevian_egg.png")
              .get_form

  LAMPENT_AEVIAN = PokeModifier.add_form(:LAMPENT, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GHOST, :Type2 => :ELECTRIC})
              .set_ev([0, 0, 0, 2, 0, 0])
              .set_evolutions([[:CHANDELURE, :Item, :THUNDERSTONE]])
              .set_preevo({:species=>:LITWICK, :form=>1})
              .level_moves([[1, :EMBER], [1, :ASTONISH], [3, :CHARGE], [7, :SMOG], [10, :EMBER], [13, :NIGHTSHADE], [16, :NUZZLE], [20, :FIRESPIN], [24, :EERIEIMPULSE], [28, :HEX], [33, :MEMENTO], [38, :CHARGEBEAM], [45, :CURSE], [53, :SHADOWBALL], [61, :PAINSPLIT], [69, :DISCHARGE], [75, :OVERHEAT]])
              .egg_moves([])
              .compatible_moves([:ALLYSWITCH, :BURNINGJEALOUSY, :CALMMIND, :CHARGEBEAM, :DARKPULSE, :DREAMEATER, :EERIEIMPULSE, :ELECTRICTERRAIN, :ELECTROBALL, :ELECTROWEB, :EMBARGO, :FIRESPIN, :FLAMECHARGE, :FLASH, :FLASHCANNON, :FOULPLAY, :FUTURESIGHT, :HEX, :ICYWIND, :IRONDEFENSE, :LASERFOCUS, :MAGICROOM, :MAGNETRISE, :OVERHEAT, :PAINSPLIT, :PAYBACK, :POLTERGEIST, :PSYCHIC, :PSYCHUP, :RAINDANCE, :RECYCLE, :RISINGVOLTAGE, :SAFEGUARD, :SHADOWBALL, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SPIKES, :SPITE, :STOREDPOWER, :TAUNT, :TERRAINPULSE, :THIEF, :THUNDER, :THUNDERWAVE, :THUNDERBOLT, :TORMENT, :TRICK, :TRICKROOM, :UPROAR, :VOLTSWITCH, :WILLOWISP, :WONDERROOM, :ZAPCANNON])
              .set_dex_entry("Often considered by factory workers a bad omen to encounter, these Lampent are thought to be the cause of accidents at the workplace.")
              .asset_override(asset: "UniLib/Assets/Battlers/lampent-aevian.png", icon: "UniLib/Assets/Icons/lampent-aevian.png")
              .get_form

  CHANDELURE_AEVIAN = PokeModifier.add_form(:CHANDELURE, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GHOST, :Type2 => :ELECTRIC})
              .stats([65, 55, 90, 145, 90, 80])
              .abilities({0 => :ILLUMINATE, 1 => :VOLTABSORB, 2 => :LEVITATE})
              .set_ev([0, 0, 0, 3, 0, 0])
              .set_preevo({:species=>:LAMPENT, :form=>1})
              .level_moves([[1, :THUNDERSHOCK], [1, :THUNDERWAVE], [1, :PAINSPLIT], [1, :CONFUSERAY], [1, :HEX], [1, :ZAPCANNON]])
              .egg_moves([])
              .compatible_moves([:ALLYSWITCH, :BURNINGJEALOUSY, :CALMMIND, :CHARGEBEAM, :DARKPULSE, :DREAMEATER, :EERIEIMPULSE, :ELECTRICTERRAIN, :ELECTROBALL, :ELECTROWEB, :EMBARGO, :FIRESPIN, :FLAMECHARGE, :FLASH, :FLASHCANNON, :FOULPLAY, :FUTURESIGHT, :GIGAIMPACT, :HEX, :HYPERBEAM, :ICYWIND, :IRONDEFENSE, :LASERFOCUS, :MAGICROOM, :MAGNETRISE, :OVERHEAT, :PAINSPLIT, :PAYBACK, :POLTERGEIST, :PSYCHUP, :PSYCHIC, :RAINDANCE, :RECYCLE, :RETURN, :RISINGVOLTAGE, :SAFEGUARD, :SHADOWBALL, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SLEEPTALK, :SPIKES, :SPITE, :STOREDPOWER, :TAUNT, :TERRAINPULSE, :THIEF, :THUNDER, :THUNDERWAVE, :THUNDERBOLT, :TORMENT, :TRICK, :TRICKROOM, :UPROAR, :VOLTSWITCH, :WILLOWISP, :WONDERROOM, :ZAPCANNON])
              .set_dex_entry("Found in older streets and buildings that went through rapid modernization, it is said that its eerie light causes people to succumb to dark thoughts and impulses.")
              .asset_override(asset: "UniLib/Assets/Battlers/chandelure-aevian.png", icon: "UniLib/Assets/Icons/chandelure-aevian.png")
              .get_form

  LARVESTA_AEVIAN = PokeModifier.add_form(:LARVESTA, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FLYING, :Type2 => :FLYING})
              .stats([55, 85, 50, 50, 50, 70])
              .abilities({0 => :WONDERSKIN, 1 => :UNNERVE, 2 => :WONDERSKIN})
              .set_ev([0, 1, 0, 0, 0, 0])
              .level_moves([[1, :GUST], [1, :LEER], [10, :TWISTER], [20, :TAKEDOWN], [30, :AERIALACE], [40, :PSYBEAM], [50, :DOUBLEEDGE], [60, :ACROBATICS], [70, :ZENHEADBUTT], [80, :BARRIER], [90, :THRASH], [100, :SKYATTACK]])
              .egg_moves([:ANCIENTPOWER, :FORESIGHT, :HEALBLOCK, :IMPRISON, :MORNINGSUN, :ZENHEADBUTT])
              .compatible_moves([:ACROBATICS, :AERIALACE, :AGILITY, :AIRSLASH, :ALLYSWITCH, :ATTRACT, :BODYSLAM, :BOUNCE, :BUGBITE, :CALMMIND, :CONFIDE, :DAZZLINGGLEAM, :DEFOG, :DIG, :DOUBLETEAM, :DRAGONPULSE, :ECHOEDVOICE, :ELECTROWEB, :FACADE, :FLAMETHROWER, :FLASH, :FOCUSENERGY, :FRUSTRATION, :HAIL, :HEATWAVE, :HELPINGHAND, :HIDDENPOWER, :HURRICANE, :HYPERVOICE, :ICEBEAM, :ICYWIND, :INFESTATION, :LEECHLIFE, :LIGHTSCREEN, :MAGICCOAT, :PROTECT, :PSYCHIC, :PSYCHUP, :PSYSHOCK, :RAINDANCE, :REFLECT, :REST, :RETURN, :ROUND, :SAFEGUARD, :SCREECH, :SECRETPOWER, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SKYATTACK, :SLEEPTALK, :SNORE, :STRUGGLEBUG, :SUBSTITUTE, :SUNNYDAY, :SWAGGER, :THUNDER, :THUNDERBOLT, :THUNDERWAVE, :TOXIC, :UTURN, :WATERPULSE, :WEATHERBALL, :WILDCHARGE, :ZENHEADBUTT])
              .set_egg_groups([:Bug, :Flying])
              .set_dex_entry("It lurks upon holy grounds, maintaining them. It stays hidden by taking on an incomprehensible form that only those pure of heart can decipher.")
              .asset_override(asset: "UniLib/Assets/Battlers/larvesta-aevian.png", asset_egg: "UniLib/Assets/Battlers/larvesta-aevian_egg.png", icon: "UniLib/Assets/Icons/larvesta-aevian.png", icon_egg: "UniLib/Assets/Icons/larvesta-aevian_egg.png")
              .get_form

  VOLCARONA_AEVIAN = PokeModifier.add_form(:VOLCARONA, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FLYING, :Type2 => :FLYING})
              .stats([85, 60, 60, 135, 100, 110])
              .abilities({0 => :SHIELDDUST, 1 => :PRESSURE, 2 => :SHIELDDUST})
              .set_ev([0, 0, 0, 3, 0, 0])
              .set_preevo({:species=>:LARVESTA, :form=>1})
              .level_moves([[1, :ETHEREALTEMPEST], [1, :HURRICANE], [1, :AURASPHERE], [1, :COURTCHANGE], [1, :QUIVERDANCE], [1, :GUST], [1, :LEER], [1, :TWISTER], [1, :TAKEDOWN], [1, :AERIALACE], [1, :PSYBEAM], [1, :DOUBLEEDGE], [1, :ACROBATICS], [1, :ZENHEADBUTT], [1, :BARRIER], [1, :THRASH], [1, :SKYATTACK], [0, :QUIVERDANCE], [10, :GUST], [20, :TWISTER], [30, :AIRSLASH], [40, :WHIRLWIND], [50, :ROOST], [60, :PSYCHIC], [70, :COURTCHANGE], [80, :AURASPHERE], [90, :HURRICANE], [100, :ETHEREALTEMPEST]])
              .egg_moves([])
              .compatible_moves([:ACROBATICS, :AERIALACE, :AGILITY, :AIRSLASH, :ALLYSWITCH, :ATTRACT, :AURASPHERE, :BODYSLAM, :BOUNCE, :BUGBITE, :CALMMIND, :CONFIDE, :COSMICPOWER, :DAZZLINGGLEAM, :DEFOG, :DIG, :DOUBLETEAM, :DRAGONPULSE, :DREAMEATER, :DUALWINGBEAT, :ECHOEDVOICE, :ELECTROWEB, :FACADE, :FLAMETHROWER, :FLASH, :FLY, :FOCUSBLAST, :FOCUSENERGY, :FRUSTRATION, :FUTURESIGHT, :GIGAIMPACT, :HAIL, :HEATWAVE, :HELPINGHAND, :HIDDENPOWER, :HURRICANE, :HYPERBEAM, :HYPERVOICE, :ICEBEAM, :ICYWIND, :INFESTATION, :LEECHLIFE, :LIGHTSCREEN, :MAGICALLEAF, :MAGICCOAT, :MYSTICALFIRE, :PROTECT, :PSYCHIC, :PSYCHUP, :PSYSHOCK, :RAINDANCE, :REFLECT, :REST, :RETURN, :ROOST, :ROUND, :SAFEGUARD, :SCARYFACE, :SCREECH, :SECRETPOWER, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SKYATTACK, :SKYDROP, :SLEEPTALK, :SNORE, :STEELWING, :STRENGTH, :STRUGGLEBUG, :SUBSTITUTE, :SUNNYDAY, :SWAGGER, :TAILWIND, :THUNDER, :THUNDERBOLT, :THUNDERWAVE, :TOXIC, :UTURN, :WATERPULSE, :WEATHERBALL, :WILDCHARGE, :ZENHEADBUTT])
              .set_egg_groups([:Bug, :Flying])
              .set_dex_entry("It valiantly guards places of purity and light. It prefers peace, but when faced with those of vice, attacks without mercy. It gives off a pressuring aura.")
              .asset_override(asset: "UniLib/Assets/Battlers/volcarona-aevian.png", icon: "UniLib/Assets/Icons/volcarona-aevian.png")
              .get_form

  WIMPOD_AEVIAN = PokeModifier.add_form(:WIMPOD, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :BUG, :Type2 => :GROUND})
              .stats([25, 40, 35, 15, 35, 80])
              .abilities({0 => :WIMPOUT, 1 => :RATTLED, 2 => :SANDVEIL})
              .set_ev([0, 0, 0, 0, 0, 1])
              .level_moves([[1, :STRUGGLEBUG], [1, :SANDATTACK], [1, :CAMOUFLAGE]])
              .egg_moves([:ASTONISH, :METALCLAW, :SANDTOMB, :SHADOWSNEAK, :SPIKES, :WIDEGUARD])
              .compatible_moves([:BUGBITE, :BUGBUZZ, :BULLDOZE, :CUT, :DIG, :EARTHPOWER, :EARTHQUAKE, :ELECTROWEB, :FOCUSENERGY, :INFESTATION, :IRRITATION, :LEECHLIFE, :MUDSHOT, :PAINSPLIT, :PINMISSILE, :REVERSAL, :SANDSTORM, :SANDTOMB, :SCORCHINGSANDS, :SIGNALBEAM, :SKITTERSMACK, :SPIKES, :STRUGGLEBUG, :SUNNYDAY, :UTURN])
              .set_color("Brown")
              .set_dex_entry("Losing its home to the calamity forced these Pokemon to adapt to the desert, scavenging for food. Sometimes they'll try to prey on Budew, only to fail and scurry off immediately.")
              .asset_override(asset: "UniLib/Assets/Battlers/wimpod-aevian.png", asset_egg: "UniLib/Assets/Battlers/wimpod-aevian_egg.png", icon: "UniLib/Assets/Icons/wimpod-aevian.png", icon_egg: "UniLib/Assets/Icons/wimpod-aevian_egg.png")
              .get_form

  GOLISOPOD_AEVIAN = PokeModifier.add_form(:GOLISOPOD, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :BUG, :Type2 => :GROUND})
              .stats([75, 125, 130, 50, 100, 50])
              .abilities({0 => :BATTLEARMOR, 1 => :SKILLLINK, 2 => :SANDVEIL})
              .set_ev([0, 0, 2, 0, 0, 0])
              .set_preevo({:species=>:WIMPOD, :form=>1})
              .level_moves([[1, :FIRSTIMPRESSION], [1, :STRUGGLEBUG], [1, :SANDATTACK], [1, :FURYCUTTER], [1, :SKULLBASH], [0, :FIRSTIMPRESSION], [4, :FURYCUTTER], [7, :SKULLBASH], [10, :BUGBITE], [13, :BONECLUB], [16, :SWORDSDANCE], [21, :PINMISSILE], [26, :DIG], [31, :SUCKERPUNCH], [36, :IRONDEFENSE], [41, :BONERUSH], [41, :BONEMERANG], [48, :HEADLONGRUSH]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :ASSURANCE, :BEATUP, :BLOCK, :BODYPRESS, :BODYSLAM, :BRICKBREAK, :BRUTALSWING, :BUGBITE, :BUGBUZZ, :BULKUP, :BULLDOZE, :CLOSECOMBAT, :CROSSPOISON, :CUT, :DIG, :DRILLRUN, :EARTHPOWER, :EARTHQUAKE, :ELECTROWEB, :EMBARGO, :FALSESWIPE, :FLING, :FOCUSENERGY, :GIGAIMPACT, :HYPERBEAM, :INFESTATION, :IRONDEFENSE, :IRONHEAD, :KNOCKOFF, :LASERFOCUS, :LASTRESORT, :LEECHLIFE, :MUDSHOT, :NATUREPOWER, :PAINSPLIT, :PAYBACK, :PINMISSILE, :POISONJAB, :RETALIATE, :REVERSAL, :ROCKBLAST, :ROCKCLIMB, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDSTORM, :SANDTOMB, :SCARYFACE, :SCORCHINGSANDS, :SHADOWCLAW, :SIGNALBEAM, :SKITTERSMACK, :SLUDGEBOMB, :SMACKDOWN, :SPIKES, :SPITE, :STOMPINGTANTRUM, :STONEEDGE, :STRENGTH, :STRUGGLEBUG, :SUCKERPUNCH, :SUNNYDAY, :SUPERPOWER, :SWORDSDANCE, :THIEF, :THROATCHOP, :UTURN, :VENOSHOCK, :XSCISSOR, :ARENITEWALL, :IRRITATION, :SLASHANDBURN])
              .set_color("Brown")
              .set_dex_entry("It will pick the bones of other Pokemon to make armor. It waits in the sand with only the bones exposed, waiting for something unfortunate to walk by. It is not picky with its prey.")
              .asset_override(asset: "UniLib/Assets/Battlers/golisopod-aevian.png", icon: "UniLib/Assets/Icons/golisopod-aevian.png")
              .get_form

  JANGMOO_AEVIAN = PokeModifier.add_form(:JANGMOO, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :DRAGON, :Type2 => :POISON})
              .stats([50, 65, 55, 40, 40, 40])
              .abilities({0 => :ANALYTIC, 1 => :KEENEYE, 2 => :OVERCOAT})
              .set_ev([0, 0, 1, 0, 0, 0])
              .level_moves([[1, :POISONSTING], [1, :LEER], [4, :PROTECT], [8, :DRAGONTAIL], [12, :PURSUIT], [16, :POISONFANG], [20, :WORKUP], [24, :GASTROACID], [28, :ACIDARMOR], [32, :DRAGONCLAW], [36, :NOBLEROAR], [40, :DRAGONDANCE], [44, :OUTRAGE]])
              .egg_moves([])
              .compatible_moves([:ASSURANCE, :BLOCK, :BODYSLAM, :BREAKINGSWIPE, :BRUTALSWING, :BULKUP, :BULLDOZE, :CRUNCH, :CUT, :DIG, :DRACOMETEOR, :DRAGONCLAW, :DRAGONDANCE, :DRAGONPULSE, :DRAGONTAIL, :FALSESWIPE, :FIREFANG, :FLAMETHROWER, :GASTROACID, :GUNKSHOT, :HONECLAWS, :ICEFANG, :IRONHEAD, :IRONTAIL, :KNOCKOFF, :LEECHLIFE, :OUTRAGE, :PAYBACK, :POISONJAB, :POISONSWEEP, :REVERSAL, :ROAR, :ROCKCLIMB, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDTOMB, :SANDSTORM, :SCALESHOT, :SCARYFACE, :SCREECH, :SHADOWCLAW, :SKITTERSMACK, :SLUDGEBOMB, :SLUDGEWAVE, :SNARL, :SNATCH, :STACKINGSHOT, :STEALTHROCK, :SUNNYDAY, :TAUNT, :THIEF, :THUNDERFANG, :UPROAR, :VENOMDRENCH, :VENOSHOCK, :WORKUP, :MAGMADRIFT, :POISONSWEEP])
              .set_dex_entry("Their fangs are laced with a toxin that is not very powerful, but it is enough to slow prey down and disorient them for it to catch up to them. Many joke that this toxin is connected to their mean personality.")
              .asset_override(asset: "UniLib/Assets/Battlers/jangmoo-aevian.png", asset_egg: "UniLib/Assets/Battlers/jangmoo-aevian_egg.png", icon: "UniLib/Assets/Icons/jangmoo-aevian.png", icon_egg: "UniLib/Assets/Icons/jangmoo-aevian_egg.png")
              .get_form

  HAKAMOO_AEVIAN = PokeModifier.add_form(:HAKAMOO, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :DRAGON, :Type2 => :POISON})
              .stats([70, 85, 85, 60, 60, 60])
              .abilities({0 => :ANALYTIC, 1 => :KEENEYE, 2 => :OVERCOAT})
              .set_ev([0, 0, 2, 0, 0, 0])
              .set_preevo({:species=>:JANGMOO, :form=>1})
              .level_moves([[1, :TOXIC], [1, :POISONSTING], [1, :LEER], [0, :BREAKINGSWIPE], [4, :PROTECT], [8, :DRAGONTAIL], [12, :PURSUIT], [16, :POISONFANG], [20, :WORKUP], [24, :GASTROACID], [28, :ACIDARMOR], [32, :DRAGONCLAW], [38, :NOBLEROAR], [44, :DRAGONDANCE], [50, :OUTRAGE], [56, :GUNKSHOT]])
              .egg_moves([])
              .compatible_moves([:ASSURANCE, :BLOCK, :BODYSLAM, :BREAKINGSWIPE, :BRUTALSWING, :BULKUP, :BULLDOZE, :CRUNCH, :CUT, :DIG, :DRACOMETEOR, :DRAGONCLAW, :DRAGONDANCE, :DRAGONPULSE, :DRAGONTAIL, :DUALCHOP, :EARTHQUAKE, :FALSESWIPE, :FIREFANG, :FIREPUNCH, :FLAMETHROWER, :GASTROACID, :GUNKSHOT, :HONECLAWS, :ICEFANG, :ICEPUNCH, :IRONHEAD, :IRONTAIL, :KNOCKOFF, :LASHOUT, :LEECHLIFE, :MAGMADRIFT, :OUTRAGE, :PAYBACK, :POISONJAB, :POISONSWEEP, :POWERUPPUNCH, :REVERSAL, :ROAR, :ROCKCLIMB, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDTOMB, :SANDSTORM, :SCALESHOT, :SCARYFACE, :SCREECH, :SHADOWCLAW, :SKITTERSMACK, :SLUDGEBOMB, :SLUDGEWAVE, :SNARL, :SNATCH, :STACKINGSHOT, :STEALTHROCK, :STOMPINGTANTRUM, :STONEEDGE, :STRENGTH, :SUNNYDAY, :SWORDSDANCE, :TAUNT, :THIEF, :THROATCHOP, :THUNDERFANG, :THUNDERPUNCH, :UPROAR, :VENOMDRENCH, :VENOSHOCK, :WORKUP, :XSCISSOR, :MAGMADRIFT, :POISONSWEEP, :STACKINGSHOT])
              .set_dex_entry("Hakamo-o are actually quadrupedal, but stand up during battle for intimidation and flexibility. Their main fighting plan is to rush in and swing about wildly until something goes down.")
              .asset_override(asset: "UniLib/Assets/Battlers/hakamoo-aevian.png", icon: "UniLib/Assets/Icons/hakamoo-aevian.png")
              .get_form

  KOMMOO_AEVIAN = PokeModifier.add_form(:KOMMOO, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :DRAGON, :Type2 => :POISON})
              .stats([95, 125, 125, 95, 95, 65])
              .abilities({0 => :ANALYTIC, 1 => :INEXORABLE, 2 => :OVERCOAT})
              .set_ev([0, 0, 3, 0, 0, 0])
              .set_preevo({:species=>:HAKAMOO, :form=>1})
              .level_moves([[1, :BELLYDRUM], [1, :TOXIC], [1, :BREAKINGSWIPE], [1, :POISONSTING], [1, :LEER], [0, :VILEASSAULT], [4, :PROTECT], [8, :DRAGONTAIL], [12, :PURSUIT], [16, :POISONFANG], [20, :WORKUP], [24, :GASTROACID], [28, :ACIDARMOR], [32, :DRAGONCLAW], [38, :NOBLEROAR], [44, :DRAGONDANCE], [52, :OUTRAGE], [60, :GUNKSHOT], [68, :LUNGE], [76, :SUPERPOWER]])
              .egg_moves([])
              .compatible_moves([:ASSURANCE, :BLOCK, :BODYPRESS, :BODYSLAM, :BREAKINGSWIPE, :BRUTALSWING, :BULKUP, :BULLDOZE, :CRUNCH, :CUT, :DARKPULSE, :DARKESTLARIAT, :DIG, :DRACOMETEOR, :DRAGONCLAW, :DRAGONDANCE, :DRAGONPULSE, :DRAGONTAIL, :DUALCHOP, :EARTHQUAKE, :FALSESWIPE, :FIREFANG, :FIREPUNCH, :FLAMETHROWER, :GASTROACID, :GIGAIMPACT, :GUNKSHOT, :HIGHHORSEPOWER, :HONECLAWS, :HYPERBEAM, :ICEFANG, :ICEPUNCH, :IRONHEAD, :IRONTAIL, :KNOCKOFF, :LASHOUT, :LEECHLIFE, :MAGMADRIFT, :OUTRAGE, :PAYBACK, :POISONJAB, :POISONSWEEP, :POWERUPPUNCH, :REVERSAL, :ROAR, :ROCKCLIMB, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDTOMB, :SANDSTORM, :SCALESHOT, :SCARYFACE, :SCREECH, :SHADOWCLAW, :SKITTERSMACK, :SLUDGEBOMB, :SLUDGEWAVE, :SNARL, :SNATCH, :STACKINGSHOT, :STEALTHROCK, :STOMPINGTANTRUM, :STONEEDGE, :STRENGTH, :SUNNYDAY, :SUPERPOWER, :SURF, :SWORDSDANCE, :TAUNT, :THIEF, :THROATCHOP, :THUNDERFANG, :THUNDERPUNCH, :TOXICSPIKES, :UPROAR, :VENOMDRENCH, :VENOSHOCK, :WORKUP, :XSCISSOR, :MAGMADRIFT, :POISONSWEEP, :SLASHANDBURN, :STACKINGSHOT])
              .set_dex_entry("As the apex predator of their habitat, they've grown in size and become slower-moving, and as a response developed a toxin strong enough to cause fainting. It uses the scent of this toxin to track down prey that escaped an assault.")
              .asset_override(asset: "UniLib/Assets/Battlers/kommoo-aevian.png", icon: "UniLib/Assets/Icons/kommoo-aevian.png")
              .get_form

=begin
  TOXTRICITY_AEVIAN = PokeModifier.add_form(:TOXTRICITY, "Aevian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FIRE, :Type2 => :POISON})
              .stats([70, 75, 70, 114, 70, 98])
              .abilities({0 => :GALVANIZE, 1 => :PUNKROCK, 2 => :SOLIDROCK})
              .set_ev([0, 0, 0, 2, 0, 0])
              .level_moves([[1, :FLAMEBURST], [1, :SUNNYDAY], [1, :BELCH], [1, :TEARFULLOOK], [1, :WILLOWISP], [1, :GROWL], [1, :FLAIL], [1, :ACID], [1, :EMBER], [1, :ACIDSPRAY], [1, :LEER], [1, :NOBLEROAR], [4, :EMBER], [8, :INCINERATE], [12, :SCARYFACE], [16, :TAUNT], [20, :VENOSHOCK], [24, :SCREECH], [28, :SWAGGER], [32, :TOXIC], [36, :LAVAPLUME], [40, :POISONJAB], [44, :OVERHEAT], [48, :BOOMBURST], [52, :SHIFTGEAR]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :AGILITY, :BATONPASS, :BLAZEKICK, :BOUNCE, :CORROSIVEGAS, :CROSSPOISON, :DEFOG, :DIG, :DRAGONCLAW, :DRAINPUNCH, :DUALCHOP, :DYNAMICPUNCH, :ECHOEDVOICE, :ENCORE, :ENDEAVOR, :FIREBLAST, :FIREFANG, :FIREPUNCH, :FIRESPIN, :FLAMECHARGE, :FLAMETHROWER, :FLAREBLITZ, :GASTROACID, :GIGAIMPACT, :GUNKSHOT, :HEATCRASH, :HEATWAVE, :HYPERBEAM, :HYPERVOICE, :INCINERATE, :KNOCKOFF, :LASERFOCUS, :MEGAKICK, :MEGAPUNCH, :MYSTICALFIRE, :OUTRAGE, :OVERHEAT, :PAYBACK, :POISONJAB, :POWERUPPUNCH, :PSYCHUP, :ROAR, :ROCKCLIMB, :ROCKSMASH, :ROLEPLAY, :SCARYFACE, :SCORCHINGSANDS, :SCREECH, :SIGNALBEAM, :SLUDGEBOMB, :SLUDGEWAVE, :SNARL, :SOLARBEAM, :SOLARBLADE, :STOMPINGTANTRUM, :STONEEDGE, :STOREDPOWER, :STRENGTH, :SUCKERPUNCH, :SUNNYDAY, :TERRAINPULSE, :THROATCHOP, :THUNDER, :THUNDERFANG, :THUNDERPUNCH, :UPROAR, :VENOMDRENCH, :VENOSHOCK, :WILDCHARGE, :WILLOWISP, :WORKUP, :MAGMADRIFT, :POISONSWEEP, :STACKINGSHOT])
              .set_dex_entry("This form of Toxtricity is newly discovered as Toxel only started appearing in Aevium in the last ten years. It burns the poison in its body and spews out the toxic fumes to attack.")
              .asset_override(asset: "UniLib/Assets/Battlers/toxtricity-aevian.png", icon: "UniLib/Assets/Icons/toxtricity-aevian.png")
              .get_form
=end

end unless UniLib.cached(UniLib::AEVIAN_PORTS)