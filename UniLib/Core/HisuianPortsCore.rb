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

  ItemBuilder.add(:ANCIENTTEACH, "Ancient Teachings", "An ancient book that has specific teachings about swordsmanship, archery, and necromancy.", 2100)
             .no_use_in_battle

  ItemBuilder.add(:BLACKAUGURITE, "Black Augurite", "A glassy black stone that produces a sharp cutting edge when split. It’s loved by a certain Pokémon.", 2100)
             .no_use_in_battle

end unless UniLib.cached(UniLib::ITEM)

ItemHandlers::UseOnPokemon.copy(:FIRESTONE, :ANCIENTTEACH)

if Reborn

  GROWLITHE_HISUIAN = PokeModifier.add_form(:GROWLITHE, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FIRE, :Type2 => :ROCK})
              .stats([60, 75, 45, 65, 50, 55])
              .abilities({0 => :INTIMIDATE, 1 => :FLASHFIRE, 2 => :ROCKHEAD})
              .set_ev([0, 1, 0, 0, 0, 0])
              .set_evolutions(proc { [{:species => :ARCANINE, :method => :Item, :parameter => :FIRESTONE, :form => ARCANINE_HISUIAN}] })
              .level_moves([[1, :EMBER], [1, :LEER], [4, :HOWL], [8, :BITE], [12, :FLAMEWHEEL], [16, :HELPINGHAND], [24, :FIREFANG], [28, :RETALIATE], [32, :CRUNCH], [36, :TAKEDOWN], [40, :FLAMETHROWER], [44, :ROAR], [48, :ROCKSLIDE], [52, :REVERSAL], [56, :FLAREBLITZ]])
              .egg_moves([:BODYSLAM, :BURNUP, :CLOSECOMBAT, :COVET, :CRUNCH, :DOUBLEKICK, :DOUBLEEDGE, :FIRESPIN, :FLAREBLITZ, :HEATWAVE, :HOWL, :IRONTAIL, :MORNINGSUN, :THRASH])
              .compatible_moves([:AERIALACE, :AGILITY, :BODYSLAM, :CLOSECOMBAT, :COVET, :CRUNCH, :DIG, :DOUBLEEDGE, :FIREBLAST, :FIREFANG, :FIRESPIN, :FLAMECHARGE, :FLAMETHROWER, :FLAREBLITZ, :HEATWAVE, :HELPINGHAND, :IRONTAIL, :OUTRAGE, :OVERHEAT, :PLAYROUGH, :POWERGEM, :PSYCHICFANGS, :RETALIATE, :REVERSAL, :ROAR, :ROCKBLAST, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDSTORM, :SCARYFACE, :SMARTSTRIKE, :SNARL, :STEALTHROCK, :STONEEDGE, :SUNNYDAY, :TAKEDOWN, :THUNDERFANG, :WILDCHARGE, :WILLOWISP, :ARENITEWALL, :MAGMADRIFT, :SLASHANDBURN])
              .set_height(8)
              .set_weight(227)
              .set_dex_entry("They patrol their territory in pairs. It is believed the igneous rock components in the fur of this species are the result of volcanic activity in its habitat.")
              .asset_override(asset: "UniLib/Assets/Battlers/growlithe-hisuian.png", asset_egg: "UniLib/Assets/Battlers/growlithe-hisuian_egg.png", icon: "UniLib/Assets/Icons/growlithe-hisuian.png", icon_egg: "UniLib/Assets/Icons/growlithe-hisuian_egg.png")
              .get_form

  ARCANINE_HISUIAN = PokeModifier.add_form(:ARCANINE, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FIRE, :Type2 => :ROCK})
              .stats([95, 115, 80, 95, 80, 90])
              .abilities({0 => :INTIMIDATE, 1 => :FLASHFIRE, 2 => :ROCKHEAD})
              .set_ev([0, 2, 0, 0, 0, 0])
              .set_preevo(proc { {:species => :GROWLITHE, :form => GROWLITHE_HISUIAN} })
              .level_moves([[0, :EXTREMESPEED], [1, :FLAMEWHEEL], [1, :HELPINGHAND], [1, :AGILITY], [1, :FIREFANG], [1, :RETALIATE], [1, :CRUNCH], [1, :TAKEDOWN], [1, :ROAR], [1, :ROCKSLIDE], [1, :REVERSAL], [1, :FLAREBLITZ], [1, :ROCKTOMB], [1, :EMBER], [1, :LEER], [1, :HOWL], [1, :BITE], [5, :FLAMETHROWER], [64, :RAGINGFURY]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :AGILITY, :BODYSLAM, :BULLDOZE, :CLOSECOMBAT, :COVET, :CRUNCH, :DIG, :DOUBLEEDGE, :DRAGONPULSE, :FIREBLAST, :FIREFANG, :FIRESPIN, :FLAMECHARGE, :FLAMETHROWER, :FLAREBLITZ, :GIGAIMPACT, :HEATWAVE, :HELPINGHAND, :HYPERBEAM, :HYPERVOICE, :IRONHEAD, :IRONTAIL, :OUTRAGE, :OVERHEAT, :PLAYROUGH, :POWERGEM, :PSYCHICFANGS, :RETALIATE, :REVERSAL, :ROAR, :ROCKBLAST, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDSTORM, :SCARYFACE, :SMARTSTRIKE, :SNARL, :SOLARBEAM, :STEALTHROCK, :STONEEDGE, :SUNNYDAY, :TAKEDOWN, :THIEF, :THUNDERFANG, :WILDCHARGE, :WILLOWISP, :ARENITEWALL, :MAGMADRIFT, :SLASHANDBURN])
              .set_height(20)
              .set_weight(1680)
              .set_dex_entry("Snaps at its foes with fangs cloaked in blazing flame. Despite its bulk, it deftly feints every which way, leading opponents on a deceptively merry chase as it all but dances around them.")
              .asset_override(asset: "UniLib/Assets/Battlers/arcanine-hisuian.png", icon: "UniLib/Assets/Icons/arcanine-hisuian.png")
              .get_form

  VOLTORB_HISUIAN = PokeModifier.add_form(:VOLTORB, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :ELECTRIC, :Type2 => :GRASS})
              .set_evolutions(proc { [{:species => :ELECTRODE, :method => :Item, :parameter => :LEAFSTONE, :form => ELECTRODE_HISUIAN}] })
              .level_moves([[1, :CHARGE], [1, :TACKLE], [4, :THUNDERSHOCK], [6, :STUNSPORE], [9, :BULLETSEED], [11, :ROLLOUT], [13, :SCREECH], [16, :CHARGEBEAM], [20, :SWIFT], [22, :ELECTROBALL], [26, :SELFDESTRUCT], [29, :ENERGYBALL], [34, :SEEDBOMB], [34, :DISCHARGE], [41, :EXPLOSION], [46, :GYROBALL], [50, :GRASSYTERRAIN]])
              .egg_moves([])
              .compatible_moves([:AGILITY, :BULLETSEED, :CHARGEBEAM, :ELECTRICTERRAIN, :ELECTROBALL, :ENERGYBALL, :EXPLOSION, :FOULPLAY, :GIGADRAIN, :GRASSKNOT, :GRASSYTERRAIN, :GYROBALL, :ICEBALL, :LEAFSTORM, :MAGICALLEAF, :RAINDANCE, :RECYCLE, :REFLECT, :ROLLOUT, :SCREECH, :SEEDBOMB, :SELFDESTRUCT, :SOLARBEAM, :SWIFT, :TAKEDOWN, :TAUNT, :THIEF, :THUNDER, :THUNDERBOLT, :THUNDERWAVE, :VOLTSWITCH, :WILDCHARGE, :WORRYSEED])
              .set_weight(130)
              .set_dex_entry("An enigmatic Pokémon that happens to bear a resemblance to a Poké Ball. When excited, it discharges the electric current it has stored in its belly, then lets out a great, uproarious laugh.")
              .asset_override(asset: "UniLib/Assets/Battlers/voltorb-hisuian.png", asset_egg: "UniLib/Assets/Battlers/voltorb-hisuian_egg.png", icon: "UniLib/Assets/Icons/voltorb-hisuian.png", icon_egg: "UniLib/Assets/Icons/voltorb-hisuian_egg.png")
              .get_form

  ELECTRODE_HISUIAN = PokeModifier.add_form(:ELECTRODE, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :ELECTRIC, :Type2 => :GRASS})
              .set_preevo(proc { {:species => :VOLTORB, :form => VOLTORB_HISUIAN} })
              .level_moves([[0, :CHLOROBLAST], [1, :CHARGE], [1, :TACKLE], [4, :THUNDERSHOCK], [6, :STUNSPORE], [9, :BULLETSEED], [11, :ROLLOUT], [13, :SCREECH], [16, :CHARGEBEAM], [20, :SWIFT], [22, :ELECTROBALL], [26, :SELFDESTRUCT], [29, :ENERGYBALL], [34, :SEEDBOMB], [34, :DISCHARGE], [41, :EXPLOSION], [46, :GYROBALL], [50, :GRASSYTERRAIN]])
              .egg_moves([])
              .compatible_moves([:AGILITY, :BULLETSEED, :CHARGEBEAM, :ELECTRICTERRAIN, :ELECTROBALL, :ENERGYBALL, :EXPLOSION, :FOULPLAY, :GIGADRAIN, :GIGAIMPACT, :GRASSKNOT, :GRASSYTERRAIN, :GYROBALL, :HYPERBEAM, :ICEBALL, :LEAFSTORM, :MAGICALLEAF, :RAINDANCE, :RECYCLE, :REFLECT, :ROLLOUT, :SCARYFACE, :SCREECH, :SEEDBOMB, :SELFDESTRUCT, :SOLARBEAM, :SWIFT, :TAKEDOWN, :TAUNT, :THIEF, :THUNDER, :THUNDERBOLT, :THUNDERWAVE, :VOLTSWITCH, :WILDCHARGE, :WORRYSEED])
              .set_weight(710)
              .set_dex_entry("The tissue on the surface of its body is curiously similar in composition to an Apricorn. When irritated, this Pokémon lets loose an electric current equal to 20 lightning bolts.")
              .asset_override(asset: "UniLib/Assets/Battlers/electrode-hisuian.png", icon: "UniLib/Assets/Icons/electrode-hisuian.png")
              .get_form

  MoveBuilder.add(:CHLOROBLAST, "Chloroblast", "The user launches its amassed chlorophyll to inflict damage on the target. This also damages the user.",
                  :GHOST, :special, 5, 150, 95, 0x175)
             .flag(:effect, 30)
             .flag(:kingrock, true)

  PokeModifier.add(:QUILAVA)
              .add_evolution({ :species => :TYPHLOSION, :method => :Item, :parameter => :ANCIENTTEACH })
              .add_evo_override { |_, item| TYPHLOSION_HISUIAN if item == :ANCIENTTEACH }

  TYPHLOSION_HISUIAN = PokeModifier.add_form(:TYPHLOSION, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FIRE, :Type2 => :GHOST})
              .stats([73, 84, 78, 119, 85, 95])
              .abilities({0 => :BLAZE, 1 => :FRISK, 2 => :BLAZE})
              .set_ev([0, 0, 0, 3, 0, 0])
              .level_moves([[0, :INFERNALPARADE], [1, :ERUPTION], [1, :DOUBLEEDGE], [1, :GYROBALL], [1, :TACKLE], [1, :LEER], [1, :SMOKESCREEN], [1, :EMBER], [13, :QUICKATTACK], [20, :FLAMEWHEEL], [24, :DEFENSECURL], [31, :SWIFT], [35, :FLAMECHARGE], [43, :LAVAPLUME], [48, :FLAMETHROWER], [56, :INFERNO], [61, :ROLLOUT], [74, :OVERHEAT]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :BLASTBURN, :BODYSLAM, :BRICKBREAK, :BULLDOZE, :CALMMIND, :COVET, :CUT, :CURSE, :DETECT, :DIG, :DOUBLEEDGE, :DRAINPUNCH, :EARTHQUAKE, :FIREBLAST, :FIREFANG, :FIREPLEDGE, :FIREPUNCH, :FIRESPIN, :FLAMECHARGE, :FLAMETHROWER, :FLAREBLITZ, :FOCUSBLAST, :FOCUSPUNCH, :FURYCUTTER, :GIGAIMPACT, :GYROBALL, :HEADBUTT, :HEATWAVE, :HEX, :HYPERBEAM, :INCINERATE, :IRONHEAD, :IRONTAIL, :LOWKICK, :MIMIC, :MUDSLAP, :MYSTICALFIRE, :NATUREPOWER, :NIGHTSHADE, :OMINOUSWIND, :OVERHEAT, :PLAYROUGH, :REVERSAL, :ROAR, :ROCKSLIDE, :ROCKSMASH, :ROLLOUT, :SHADOWBALL, :SHADOWCLAW, :SOLARBEAM, :STOMPINGTANTRUM, :STRENGTH, :SUNNYDAY, :SUBMISSION, :SWIFT, :TAKEDOWN, :THUNDERPUNCH, :WILDCHARGE, :WILLOWISP, :WORKUP, :ZENHEADBUTT, :IRRITATION, :MAGMADRIFT, :MUDBARRAGE])
              .set_height(16)
              .set_weight(698)
              .set_dex_entry("Said to purify lost, forsaken souls with its flames and guide them to the afterlife. It is believed its form has been influenced by the energy of the sacred mountain towering at Hisuis center.")
              .asset_override(asset: "UniLib/Assets/Battlers/typhlosion-hisuian.png", icon: "UniLib/Assets/Icons/typhlosion-hisuian.png")
              .get_form

  MoveBuilder.add(:INFERNALPARADE, "Infernal Parade",
                  "The user attacks with myriad fireballs. This may also leave the target with a burn. This move’s power is doubled if the target has a status condition.",
                  :GHOST, :special, 15, 60, 100, 0x504)
             .flag(:effect, 30)
             .flag(:kingrock, true)

  class PokeBattle_Move_504 < PokeBattle_Move

    def pbBaseDamage(basedmg, attacker, opponent)
      return basedmg * 2 if @battle.FE == :HAUNTED || ((!opponent.status.nil? ||
        (opponent.ability == :COMATOSE && @battle.FE != :ELECTERRAIN)) && opponent.effects[:Substitute]==0)
      basedmg
    end

    def pbAdditionalEffect(attacker, opponent)
      return false unless opponent.pbCanBurn?(false)
      opponent.pbBurn(attacker)
      @battle.pbDisplay(_INTL("{1} was burned!", opponent.pbThis))
      true
    end

    def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
      return unless showanimation
      @battle.pbAnimation(id == :INFERNALPARADE ? :WILLOWISP : id,attacker,opponent,hitnum)
    end

  end

  QWILFISH_HISUIAN = PokeModifier.add_form(:QWILFISH, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :DARK, :Type2 => :POISON})
              .set_evolutions([{:species => :OVERQWIL, :method => :HasMove, :parameter => :BARBBARRAGE}])
              .add_evo_override { 0 }
              .level_moves([[1, :POISONSTING], [1, :TACKLE], [4, :HARDEN], [8, :BITE], [12, :FELLSTINGER], [16, :MINIMIZE], [20, :SPIKES], [24, :BRINE], [28, :BARBBARRAGE], [32, :PINMISSILE], [36, :TOXICSPIKES], [40, :STOCKPILE], [40, :SPITUP], [44, :TOXIC], [48, :CRUNCH], [52, :ACUPRESSURE], [56, :DESTINYBOND]])
              .egg_moves([:ACIDSPRAY, :AQUAJET, :ASTONISH, :BRINE, :BUBBLEBEAM, :FLAIL, :HAZE, :SIGNALBEAM, :SUPERSONIC, :WATERPULSE])
              .compatible_moves([:AGILITY, :AQUATAIL, :BLIZZARD, :BRINE, :BUBBLEBEAM, :CRUNCH, :DARKPULSE, :DOUBLEEDGE, :FELLSTINGER, :GIGAIMPACT, :GUNKSHOT, :HEX, :HYDROPUMP, :ICEBALL, :ICEBEAM, :ICYWIND, :LIQUIDATION, :MUDSHOT, :PINMISSILE, :POISONJAB, :RAINDANCE, :REVERSAL, :SCARYFACE, :SELFDESTRUCT, :SHADOWBALL, :SLUDGEBOMB, :SPIKES, :SURF, :SWIFT, :SWORDSDANCE, :TAKEDOWN, :TAUNT, :TOXICSPIKES, :VENOSHOCK, :WATERFALL, :WATERPULSE, :DELUGE, :IRRITATION, :MUDBARRAGE, :QUICKSILVERSPEAR])
              .set_dex_entry("Fishers detest this troublesome Pokémon because it sprays poison from its spines, getting it everywhere. A different form of Qwilfish lives in other regions.")
              .asset_override(asset: "UniLib/Assets/Battlers/qwilfish-hisuian.png", asset_egg: "UniLib/Assets/Battlers/qwilfish-hisuian_egg.png", icon: "UniLib/Assets/Icons/qwilfish-hisuian.png", icon_egg: "UniLib/Assets/Icons/qwilfish-hisuian_egg.png")
              .get_form

  MoveBuilder.add(:BARBBARRAGE, "Barb Barrage",
                  "The user launches countless toxic barbs to inflict damage. This may also poison the target. This move's power is doubled if the target is already poisoned.",
                  :POISON, :physical, 10, 60, 100, 0x502)
             .flag(:effect, 30)
             .flag(:kingrock, true)

  class PokeBattle_Move_502 < PokeBattle_Move

    def pbBaseDamage(basedmg, attacker, opponent)
      (@battle.FE == :CORROSIVE || @battle.FE == :CORROSIVEMIST || @battle.FE == :WASTELAND || @battle.FE == :MURKWATERSURFACE) ||
             (opponent.status == :POISON && opponent.effects[:Substitute] == 0) ? basedmg * 2 : basedmg
    end

    def pbAdditionalEffect(attacker, opponent)
      return false unless opponent.pbCanPoison?(false)
      opponent.pbPoison(attacker)
      @battle.pbDisplay(_INTL("{1} was poisoned!", opponent.pbThis))
      true
    end

    def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
      @battle.pbAnimation(id == :BARBBARRAGE ? :PINMISSILE: id, attacker,opponent,hitnum) if showanimation
    end

  end

  SNEASEL_HISUIAN = PokeModifier.add_form(:SNEASEL, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FIGHTING, :Type2 => :POISON})
              .abilities({0 => :INNERFOCUS, 1 => :KEENEYE, 2 => :PICKPOCKET})
              .set_ev([0, 0, 0, 0, 0, 1])
              .set_evolutions([{:species => :SNEASLER, :method => :DayHoldItem, :parameter => :RAZORCLAW}])
              .add_evo_override { 0 }
              .level_moves([[1, :SCRATCH], [1, :LEER], [1, :ROCKSMASH], [6, :TAUNT], [12, :QUICKATTACK], [18, :METALCLAW], [24, :POISONJAB], [30, :BRICKBREAK], [36, :HONECLAWS], [42, :SLASH], [48, :AGILITY], [54, :SCREECH], [60, :CLOSECOMBAT]])
              .egg_moves([:ASSIST, :AVALANCHE, :BITE, :COUNTER, :CRUSHCLAW, :DOUBLEHIT, :FAKEOUT, :FEINT, :FORESIGHT, :ICEPUNCH, :ICESHARD, :ICICLECRASH, :PUNISHMENT, :PURSUIT, :SPITE, :THROATCHOP])
              .compatible_moves([:AERIALACE, :AGILITY, :BRICKBREAK, :BULKUP, :CALMMIND, :CLOSECOMBAT, :COUNTER, :DIG, :DRAINPUNCH, :FALSESWIPE, :FLING, :FOCUSBLAST, :FOCUSENERGY, :GIGAIMPACT, :GRASSKNOT, :GUNKSHOT, :HONECLAWS, :IRONTAIL, :LOWKICK, :LOWSWEEP, :NASTYPLOT, :POISONJAB, :RAINDANCE, :REVERSAL, :ROCKSMASH, :SCREECH, :SHADOWBALL, :SHADOWCLAW, :SLUDGEBOMB, :SNARL, :SUNNYDAY, :SWIFT, :SWORDSDANCE, :TAKEDOWN, :TAUNT, :THIEF, :TOXICSPIKES, :VENOSHOCK, :XSCISSOR, :DELUGE, :POISONSWEEP, :SLASHANDBURN, :STACKINGSHOT])
              .set_weight(270)
              .set_dex_entry("Its sturdy, curved claws are ideal for traversing precipitous cliffs. From the tips of these claws drips a venom that infiltrates the nerves of any prey caught in Sneasel’s grasp.")
              .asset_override(asset: "UniLib/Assets/Battlers/sneasel-hisuian.png", asset_egg: "UniLib/Assets/Battlers/sneasel-hisuian_egg.png", asset_egg_f: "UniLib/Assets/Battlers/sneasel-hisuian_egg_f.png", icon: "UniLib/Assets/Icons/sneasel-hisuian.png", icon_egg: "UniLib/Assets/Icons/sneasel-hisuian_egg.png", icon_egg_f: "UniLib/Assets/Icons/sneasel-hisuian_egg_f.png")
              .get_form

  PokeModifier.add(:DEWOTT)
              .add_evolution({ :species => :SAMUROTT, :method => :Item, :parameter => :ANCIENTTEACH })
              .add_evo_override { |_, item| SAMUROTT_HISUIAN if item == :ANCIENTTEACH }

  SAMUROTT_HISUIAN = PokeModifier.add_form(:SAMUROTT, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :WATER, :Type2 => :DARK})
              .stats([90, 108, 80, 100, 65, 85])
              .abilities({0 => :TORRENT, 1 => :SHARPNESS, 2 => :TORRENT})
              .set_ev([0, 3, 0, 0, 0, 0])
              .level_moves([[0, :CEASELESSEDGE], [1, :SUCKERPUNCH], [1, :SLASH], [1, :MEGAHORN], [1, :TACKLE], [1, :TAILWHIP], [1, :WATERGUN], [13, :FOCUSENERGY], [18, :RAZORSHELL], [21, :FURYCUTTER], [25, :WATERPULSE], [29, :AERIALACE], [34, :AQUAJET], [39, :ENCORE], [46, :AQUATAIL], [51, :RETALIATE], [58, :SWORDSDANCE], [63, :HYDROPUMP]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :AIRSLASH, :AQUATAIL, :AVALANCHE, :BLIZZARD, :BODYSLAM, :BRICKBREAK, :BULLDOZE, :COVET, :CUT, :DARKPULSE, :DIG, :DIVE, :DRILLRUN, :ENCORE, :FALSESWIPE, :FLING, :FOCUSENERGY, :FURYCUTTER, :GIGAIMPACT, :GRASSKNOT, :HAIL, :HELPINGHAND, :HYDROCANNON, :HYDROPUMP, :HYPERBEAM, :ICEBEAM, :ICYWIND, :IRONTAIL, :LIQUIDATION, :MEGAHORN, :POISONJAB, :PSYCHOCUT, :RAINDANCE, :RAZORSHELL, :RETALIATE, :ROCKSMASH, :SCALD, :SCARYFACE, :SMARTSTRIKE, :SNARL, :SUCKERPUNCH, :SURF, :SWIFT, :SWORDSDANCE, :TAKEDOWN, :TAUNT, :THIEF, :WATERFALL, :WATERPLEDGE, :WATERPULSE, :WORKUP, :XSCISSOR, :DELUGE, :QUICKSILVERSPEAR, :SLASHANDBURN, :STACKINGSHOT])
              .set_weight(582)
              .set_dex_entry("Hard of heart and deft of blade, this rare form of Samurott is a product of the Pokémon's evolution in the region of Hisui. Its turbulent blows crash into foes like ceaseless pounding waves.")
              .asset_override(asset: "UniLib/Assets/Battlers/samurott-hisuian.png", icon: "UniLib/Assets/Icons/samurott-hisuian.png")
              .get_form

  MoveBuilder.add(:CEASELESSEDGE, "Ceaseless Edge",
                  "The user slashes its shell blade at the target. This also leaves a layer of spikes around the target.",
                  :DARK, :physical, 15, 65, 90, 0x103)
             .flag(:effect, 100)
             .flag(:contact, :true)
             .flag(:sharpmove, true)
             .flag(:kingrock, true)

  LILLIGANT_HISUIAN_EVO_LOCS = []

  PokeModifier.add(:PETILIL)
              .add_evo_override { LILLIGANT_HISUIAN if LILLIGANT_HISUIAN_EVO_LOCS.include?($game_map.map_id) }

  LILLIGANT_HISUIAN = PokeModifier.add_form(:LILLIGANT, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GRASS, :Type2 => :FIGHTING})
              .stats([70, 105, 75, 50, 75, 105])
              .abilities({0 => :CHLOROPHYLL, 1 => :HUSTLE, 2 => :LEAFGUARD})
              .set_ev([0, 1, 0, 0, 0, 1])
              .level_moves([[0, :VICTORYDANCE], [1, :PETALBLIZZARD], [1, :TEETERDANCE], [1, :DEFOG], [1, :LEAFBLADE], [1, :MEGAKICK], [1, :SOLARBLADE], [1, :MEGADRAIN], [1, :MAGICALLEAF], [1, :SLEEPPOWDER], [1, :GIGADRAIN], [1, :LEECHSEED], [1, :AFTERYOU], [1, :ENERGYBALL], [1, :SYNTHESIS], [1, :SUNNYDAY], [1, :ENTRAINMENT], [1, :LEAFSTORM], [1, :ABSORB], [1, :GROWTH], [1, :HELPINGHAND], [1, :STUNSPORE], [5, :AXEKICK]])
              .egg_moves([])
              .compatible_moves([:ACROBATICS, :AERIALACE, :AFTERYOU, :AIRSLASH, :BABYDOLLEYES, :BRICKBREAK, :BULLETSEED, :CHARM, :CLOSECOMBAT, :COVET, :CUT, :DEFOG, :DRAINPUNCH, :DREAMEATER, :ENCORE, :ENERGYBALL, :FLASH, :FOCUSENERGY, :GIGADRAIN, :GIGAIMPACT, :GRASSKNOT, :GRASSYGLIDE, :GRASSYTERRAIN, :HEALBELL, :HELPINGHAND, :HURRICANE, :HYPERBEAM, :LASERFOCUS, :LEAFBLADE, :LEAFSTORM, :LOWKICK, :LOWSWEEP, :MAGICALLEAF, :MEGADRAIN, :MEGAKICK, :METRONOME, :NATUREPOWER, :POISONJAB, :POLLENPUFF, :RAINDANCE, :ROCKSMASH, :SAFEGUARD, :SEEDBOMB, :SOLARBEAM, :SOLARBLADE, :SUNNYDAY, :SWORDSDANCE, :SYNTHESIS, :TAKEDOWN, :WORRYSEED])
              .set_height(12)
              .set_weight(192)
              .set_dex_entry("I suspect that its well-developed legs are the result of a life spent on mountains covered in deep snow. The scent it exudes from its flower crown heartens those in proximity.")
              .asset_override(asset: "UniLib/Assets/Battlers/lilligant-hisuian.png", icon: "UniLib/Assets/Icons/lilligant-hisuian.png")
              .get_form

  MoveBuilder.add(:VICTORYDANCE, "Victory Dance",
                  "The user performs an intense dance to usher in victory, boosting its Attack, Defense, and Speed stats.",
                  :FIGHTING, :status, 10, 0, 0, 0x501, :User)
             .flag(:effect, 100)
             .flag(:kingrock, true)

  class PokeBattle_Move_501 < PokeBattle_Move

    def pbEffect(attacker, opponent, hitnum=0, alltargets = nil, showanimation = true)
      if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK, false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE, false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::SPEED, false)
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", attacker.pbThis))
        return -1
      end
      pbShowAnimation(@move, attacker, nil, hitnum, alltargets, showanimation)
      boost_amount = @battle.FE == :BIGTOP || @battle.FE == :DANCEFLOOR ? 2 : 1
      [PBStats::ATTACK, PBStats::DEFENSE, PBStats::SPEED].each { |stat|
        if attacker.pbCanIncreaseStatStage?(stat, false)
          attacker.pbIncreaseStat(stat, boost_amount, abilitymessage: false)
        end
      }
      0
    end

    def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
      @battle.pbAnimation(id == :VICTORYDANCE ? :QUIVERDANCE : id, attacker, opponent, hitnum) if showanimation
    end

  end

  MoveBuilder.add(:AXEKICK, "Axe Kick",
                  "The user attacks by kicking up into the air and slamming its heel down upon the target. This may also confuse the target. If it misses, the user takes damage instead.",
                  :FIGHTING, :physical, 10, 120, 90, 0x506)
             .flag(:effect, 30)
             .flag(:contact, true)
             .flag(:kingrock, true)
             .flag(:gravityblocked, true)

  BASCULIN_WHITE_STRIPED = PokeModifier.add_form(:BASCULIN, "White-Striped")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .set_ev([0, 0, 0, 0, 0, 2])
              .set_evolutions([{:species => :BASCULEGION, :method => :HasMove, :parameter => :DOUBLEEDGE}])
              .level_moves([[1, :WATERGUN], [1, :TAILWHIP], [4, :TACKLE], [8, :FLAIL], [12, :AQUAJET], [16, :BITE], [20, :SCARYFACE], [24, :HEADBUTT], [28, :SOAK], [32, :CRUNCH], [36, :TAKEDOWN], [40, :UPROAR], [44, :WAVECRASH], [48, :THRASH], [52, :DOUBLEEDGE], [56, :HEADSMASH]])
              .egg_moves([:AGILITY, :BRINE, :BUBBLEBEAM, :ENDEAVOR, :HEADSMASH, :MUDSHOT, :MUDDYWATER, :RAGE, :REVENGE, :SWIFT, :WHIRLPOOL])
              .compatible_moves([:AGILITY, :AQUATAIL, :BLIZZARD, :CRUNCH, :DOUBLEEDGE, :ENDEAVOR, :HEADBUTT, :HYDROPUMP, :ICEBEAM, :ICEFANG, :ICYWIND, :LIQUIDATION, :MUDSHOT, :PSYCHICFANGS, :RAINDANCE, :SCARYFACE, :SURF, :SWIFT, :TAKEDOWN, :UPROAR, :WATERFALL, :WATERPULSE, :ZENHEADBUTT, :DELUGE])
              .asset_override(asset: "UniLib/Assets/Battlers/basculin-white-striped.png", asset_egg: "UniLib/Assets/Battlers/basculin-white-striped_egg.png", asset_egg_f: "UniLib/Assets/Battlers/basculin-white-striped_egg_f.png", icon: "UniLib/Assets/Icons/basculin-white-striped.png", icon_egg: "UniLib/Assets/Icons/basculin-white-striped_egg.png", icon_egg_f: "UniLib/Assets/Icons/basculin-white-striped_egg_f.png")
              .get_form

  ZORUA_HISUIAN = PokeModifier.add_form(:ZORUA, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :NORMAL, :Type2 => :GHOST})
              .set_evolutions(proc { [{:species => :ZOROARK, :method => :Level, :parameter => 30, :form => ZOROARK_HISUIAN}] })
              .level_moves([[1, :SCRATCH], [1, :LEER], [4, :TORMENT], [8, :HONECLAWS], [12, :SHADOWSNEAK], [16, :CURSE], [20, :TAUNT], [24, :KNOCKOFF], [28, :SPITE], [32, :AGILITY], [36, :SHADOWBALL], [40, :BITTERMALICE], [44, :NASTYPLOT], [48, :FOULPLAY]])
              .egg_moves([:CAPTIVATE, :COMEUPPANCE, :COPYCAT, :COUNTER, :DARKPULSE, :DETECT, :EXTRASENSORY, :MEMENTO, :SNATCH, :SUCKERPUNCH])
              .compatible_moves([:AERIALACE, :AGILITY, :CALMMIND, :CURSE, :DARKPULSE, :DIG, :FAKETEARS, :FLING, :FOULPLAY, :GIGAIMPACT, :HEX, :HONECLAWS, :HYPERBEAM, :ICYWIND, :IMPRISON, :KNOCKOFF, :NASTYPLOT, :NIGHTSHADE, :PHANTOMFORCE, :RAINDANCE, :SHADOWBALL, :SHADOWCLAW, :SLUDGEBOMB, :SNARL, :SPITE, :SWIFT, :TAKEDOWN, :TAUNT, :THIEF, :TORMENT, :TRICK, :UTURN, :WILLOWISP, :IRRITATION])
              .set_dex_entry("An once-departed soul returned to life. Derives power from resentment, which rises as energy atop its head and takes on the forms of foes. In this way, Zorua vents lingering malice.")
              .asset_override(asset: "UniLib/Assets/Battlers/zorua-hisuian.png", asset_egg: "UniLib/Assets/Battlers/zorua-hisuian_egg.png", asset_egg_f: "UniLib/Assets/Battlers/zorua-hisuian_egg_f.png", asset_f: "UniLib/Assets/Battlers/zorua-hisuian_f.png", icon: "UniLib/Assets/Icons/zorua-hisuian.png", icon_egg: "UniLib/Assets/Icons/zorua-hisuian_egg.png", icon_egg_f: "UniLib/Assets/Icons/zorua-hisuian_egg_f.png", icon_f: "UniLib/Assets/Icons/zorua-hisuian_f.png")
              .get_form

  ZOROARK_HISUIAN = PokeModifier.add_form(:ZOROARK, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :NORMAL, :Type2 => :GHOST})
              .stats([55, 100, 60, 125, 60, 110])
              .set_preevo(proc { {:species => :ZORUA, :form => ZORUA_HISUIAN} })
              .level_moves([[1, :SHADOWCLAW], [1, :UTURN], [1, :SCRATCH], [1, :LEER], [1, :TORMENT], [1, :HONECLAWS], [12, :SHADOWSNEAK], [16, :CURSE], [20, :TAUNT], [24, :KNOCKOFF], [28, :SPITE], [34, :AGILITY], [40, :SHADOWBALL], [46, :BITTERMALICE], [52, :NASTYPLOT], [58, :FOULPLAY]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :AGILITY, :BODYSLAM, :BRICKBREAK, :CALMMIND, :CURSE, :CRUNCH, :DARKPULSE, :DIG, :FAKETEARS, :FLAMETHROWER, :FLING, :FOCUSBLAST, :FOULPLAY, :GIGAIMPACT, :GRASSKNOT, :HELPINGHAND, :HEX, :HONECLAWS, :HYPERBEAM, :HYPERVOICE, :ICYWIND, :IMPRISON, :KNOCKOFF, :LOWKICK, :LOWSWEEP, :NASTYPLOT, :NIGHTSHADE, :OMINOUSWIND, :PHANTOMFORCE, :PSYCHIC, :RAINDANCE, :ROCKSMASH, :SCARYFACE, :SHADOWBALL, :SHADOWCLAW, :SLUDGEBOMB, :SNARL, :SPITE, :SWIFT, :SWORDSDANCE, :TAKEDOWN, :TAUNT, :THIEF, :TORMENT, :TRICK, :UTURN, :WILLOWISP, :IRRITATION, :SLASHANDBURN])
              .set_weight(730)
              .set_dex_entry("With its disheveled white fur, it looks like an embodiment of death. Heedless of its own safety, Zoroark attacks its nemeses with a bitter energy so intense, it lacerates Zoroark’s own body.")
              .asset_override(asset: "UniLib/Assets/Battlers/zoroark-hisuian.png", asset_f: "UniLib/Assets/Battlers/zoroark-hisuian_f.png", icon: "UniLib/Assets/Icons/zoroark-hisuian.png", icon_f: "UniLib/Assets/Icons/zoroark-hisuian_f.png")
              .get_form

  MoveBuilder.add(:BITTERMALICE, "Bitter Malice",
                  "The user attacks the target with spine-chilling resentment. This also lowers the target's Attack stat.",
                  :GHOST, :special, 10, 75, 100, 0x042, :SingleNonUser)
             .flag(:effect, 100)
             .flag(:kingrock, true)

  BRAVIARY_HISUIAN_EVO_LOCS = []

  PokeModifier.add(:RUFFLET)
              .add_evo_override { BRAVIARY_HISUIAN if BRAVIARY_HISUIAN_EVO_LOCS.include?($game_map.map_id) }

  BRAVIARY_HISUIAN = PokeModifier.add_form(:BRAVIARY, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :PSYCHIC, :Type2 => :FLYING})
              .stats([110, 83, 70, 112, 70, 65])
              .abilities({0 => :KEENEYE, 1 => :SHEERFORCE, 2 => :TINTEDLENS})
              .set_ev([0, 0, 0, 2, 0, 0])
              .level_moves([[0, :ESPERWING], [1, :SUPERPOWER], [1, :SKYATTACK], [1, :PECK], [1, :LEER], [1, :HONECLAWS], [1, :WINGATTACK], [18, :TAILWIND], [24, :SCARYFACE], [30, :AERIALACE], [36, :SLASH], [42, :WHIRLWIND], [48, :CRUSHCLAW], [57, :AIRSLASH], [64, :DEFOG], [72, :THRASH], [80, :HURRICANE]])
              .egg_moves([])
              .compatible_moves([:ACROBATICS, :AERIALACE, :AGILITY, :AIRCUTTER, :AIRSLASH, :ASSURANCE, :BODYSLAM, :BRAVEBIRD, :BULKUP, :CALMMIND, :CLOSECOMBAT, :CUT, :DAZZLINGGLEAM, :DEFOG, :DOUBLEEDGE, :DUALWINGBEAT, :FLY, :GIGAIMPACT, :HEATWAVE, :HELPINGHAND, :HONECLAWS, :HURRICANE, :HYPERBEAM, :HYPERVOICE, :ICYWIND, :MYSTICALFIRE, :NIGHTSHADE, :OMINOUSWIND, :PLUCK, :PSYCHIC, :PSYCHICTERRAIN, :PSYSHOCK, :RAINDANCE, :RETALIATE, :REVERSAL, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :ROOST, :SCARYFACE, :SHADOWBALL, :SHADOWCLAW, :SKYATTACK, :SKYDROP, :SNARL, :STEELWING, :STOREDPOWER, :STRENGTH, :SUNNYDAY, :SUPERPOWER, :SWIFT, :TAILWIND, :TAKEDOWN, :TWISTER, :UTURN, :WHIRLWIND, :WORKUP, :ZENHEADBUTT])
              .set_height(17)
              .set_weight(434)
              .set_dex_entry("Screaming a bloodcurdling battle cry, this huge and ferocious bird Pokémon goes out on the hunt. It blasts lakes with shock waves, then scoops up any prey that float to the water’s surface.")
              .asset_override(asset: "UniLib/Assets/Battlers/braviary-hisuian.png", icon: "UniLib/Assets/Icons/braviary-hisuian.png")
              .get_form

  MoveBuilder.add(:ESPERWING, "Esper Wing",
                  "The user slashes the target with aura-enriched wings. This also boosts the user's Speed stat. This move has a heightened chance of landing a critical hit.",
                  :PSYCHIC, :special, 10, 80, 100, 0x01F, :SingleNonUser)
             .flag(:highcrit, true)
             .flag(:kingrock, true)

  SLIGGOO_HISUIAN_EVO_LOCS = []

  PokeModifier.add(:GOOMY)
              .add_evo_override { SLIGGOO_HISUIAN if SLIGGOO_HISUIAN_EVO_LOCS.include?($game_map.map_id) }

  SLIGGOO_HISUIAN = PokeModifier.add_form(:SLIGGOO, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :STEEL, :Type2 => :DRAGON})
              .stats([58, 75, 83, 83, 113, 40])
              .abilities({0 => :SAPSIPPER, 1 => :SHELLARMOR, 2 => :GOOEY})
              .set_ev([0, 0, 0, 0, 2, 0])
              .set_evolutions(proc { [{:species => :GOODRA, :method => :LevelRain, :parameter => 50, :form => GOODRA_HISUIAN}] })
              .level_moves([[0, :SHELTER], [1, :ACIDARMOR], [1, :ABSORB], [1, :TACKLE], [1, :WATERGUN], [1, :DRAGONBREATH], [15, :PROTECT], [20, :FLAIL], [25, :WATERPULSE], [30, :RAINDANCE], [35, :DRAGONPULSE], [43, :CURSE], [49, :IRONHEAD], [56, :MUDDYWATER]])
              .egg_moves([])
              .compatible_moves([:BIDE, :BLIZZARD, :BODYSLAM, :CHARM, :COUNTER, :CURSE, :DRACOMETEOR, :DRAGONBREATH, :DRAGONPULSE, :FLASHCANNON, :HEAVYSLAM, :HYDROPUMP, :ICEBEAM, :INFESTATION, :IRONHEAD, :IRONTAIL, :MUDDYWATER, :MUDSHOT, :OUTRAGE, :RAINDANCE, :ROCKSLIDE, :ROCKTOMB, :SANDSTORM, :SHOCKWAVE, :SKITTERSMACK, :SLUDGEBOMB, :SLUDGEWAVE, :STEELBEAM, :SUNNYDAY, :TAKEDOWN, :THUNDER, :THUNDERBOLT, :WATERGUN, :WATERPULSE, :DELUGE, :IRRITATION, :MAGMADRIFT, :MUDBARRAGE, :QUICKSILVERSPEAR])
              .set_height(7)
              .set_weight(685)
              .set_dex_entry("A creature given to melancholy. I suspect its metallic shell developed as a result of the mucus on its skin reacting with the iron in Hisui's water.")
              .asset_override(asset: "UniLib/Assets/Battlers/sliggoo-hisuian.png", icon: "UniLib/Assets/Icons/sliggoo-hisuian.png")
              .get_form

  GOODRA_HISUIAN = PokeModifier.add_form(:GOODRA, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :STEEL, :Type2 => :DRAGON})
              .stats([80, 100, 100, 110, 150, 60])
              .abilities({0 => :SAPSIPPER, 1 => :SHELLARMOR, 2 => :GOOEY})
              .set_ev([0, 0, 0, 0, 3, 0])
              .set_preevo(proc { {:species => :SLIGGOO, :form => SLIGGOO_HISUIAN} })
              .level_moves([[0, :IRONTAIL], [1, :SHELTER], [1, :ACIDSPRAY], [1, :TEARFULLOOK], [1, :FEINT], [1, :ABSORB], [1, :TACKLE], [1, :WATERGUN], [1, :DRAGONBREATH], [15, :PROTECT], [20, :FLAIL], [25, :WATERPULSE], [30, :RAINDANCE], [35, :DRAGONPULSE], [43, :CURSE], [49, :IRONHEAD], [49, :BODYSLAM], [58, :MUDDYWATER], [67, :HEAVYSLAM]])
              .egg_moves([])
              .compatible_moves([:BIDE, :BLIZZARD, :BODYPRESS, :BODYSLAM, :BULLDOZE, :CHARM, :COUNTER, :CURSE, :DRACOMETEOR, :DRAGONBREATH, :DRAGONCLAW, :DRAGONPULSE, :DRAGONTAIL, :EARTHQUAKE, :FIREBLAST, :FIREPUNCH, :FLAMETHROWER, :FLASHCANNON, :GIGAIMPACT, :HEAVYSLAM, :HYDROPUMP, :HYPERBEAM, :ICEBEAM, :INFESTATION, :IRONHEAD, :IRONTAIL, :MUDDYWATER, :MUDSHOT, :OUTRAGE, :RAINDANCE, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SANDSTORM, :SCARYFACE, :SHOCKWAVE, :SKITTERSMACK, :SLUDGEBOMB, :SLUDGEWAVE, :STEELBEAM, :STOMPINGTANTRUM, :SUNNYDAY, :SURF, :TAKEDOWN, :THUNDER, :THUNDERBOLT, :THUNDERPUNCH, :WATERGUN, :WATERPULSE, :DELUGE, :IRRITATION, :MAGMADRIFT, :MUDBARRAGE, :QUICKSILVERSPEAR])
              .set_height(17)
              .set_weight(3341)
              .set_dex_entry("Able to freely control the hardness of its metallic shell. It loathes solitude and is extremely clingy—it will fume and run riot if those dearest to it ever leave its side.")
              .asset_override(asset: "UniLib/Assets/Battlers/goodra-hisuian.png", icon: "UniLib/Assets/Icons/goodra-hisuian.png")
              .get_form

  MoveBuilder.add(:SHELTER, "Shelter",
                  "The user makes its skin as hard as an iron shield, sharply boosting its Defense stat.",
                  :STEEL, :status, 10, 0, 0, 0x02F, :User)
             .flag(:snatchable, true)
             .flag(:nonmirror, true)

  AVALUGG_HISUIAN_EVO_LOCS = []

  PokeModifier.add(:BERGMITE)
              .add_evolution({ :species => :AVALUGG, :method => :Item, :parameter => :FIRESTONE })
              .add_evo_override { |_, item| AVALUGG_HISUIAN if item == :FIRESTONE || AVALUGG_HISUIAN_EVO_LOCS.include?($game_map.map_id) }

  AVALUGG_HISUIAN = PokeModifier.add_form(:AVALUGG, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :ICE, :Type2 => :ROCK})
              .stats([95, 127, 184, 34, 36, 38])
              .abilities({0 => :STRONGJAW, 1 => :ICEBODY, 2 => :STURDY})
              .set_ev([0, 0, 2, 0, 0, 0])
              .level_moves([[0, :ROCKSLIDE], [1, :WIDEGUARD], [1, :RAPIDSPIN], [1, :HARDEN], [1, :TACKLE], [1, :POWDERSNOW], [9, :CURSE], [12, :ICYWIND], [15, :PROTECT], [18, :AVALANCHE], [21, :BITE], [24, :ICEFANG], [27, :IRONDEFENSE], [30, :RECOVER], [33, :CRUNCH], [36, :TAKEDOWN], [41, :BLIZZARD], [46, :DOUBLEEDGE], [51, :STONEEDGE], [61, :MOUNTAINGALE]])
              .egg_moves([])
              .compatible_moves([:AFTERYOU, :AURORAVEIL, :AVALANCHE, :BLIZZARD, :BODYPRESS, :BODYSLAM, :BULLDOZE, :CRUNCH, :CURSE, :DIG, :DOUBLEEDGE, :EARTHPOWER, :EARTHQUAKE, :FLASH, :FLASHCANNON, :FROSTBREATH, :GIGAIMPACT, :GYROBALL, :HAIL, :HEAVYSLAM, :HIGHHORSEPOWER, :HYPERBEAM, :ICEBALL, :ICEBEAM, :ICEFANG, :ICICLESPEAR, :ICYWIND, :IRONDEFENSE, :IRONHEAD, :RAINDANCE, :ROCKBLAST, :ROCKPOLISH, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SAFEGUARD, :SANDSTORM, :SCARYFACE, :STEALTHROCK, :STOMPINGTANTRUM, :STONEEDGE, :STRENGTH, :SURF, :TAKEDOWN, :WATERPULSE, :DELUGE])
              .set_height(14)
              .set_weight(2624)
              .set_dex_entry("The armor of ice covering its lower jaw puts steel to shame and can shatter rocks with ease. This Pokémon barrels along steep mountain paths, cleaving through the deep snow.")
              .asset_override(asset: "UniLib/Assets/Battlers/avalugg-hisuian.png", icon: "UniLib/Assets/Icons/avalugg-hisuian.png")
              .get_form

  MoveBuilder.add(:MOUNTAINGALE, "Mountain Gale",
                  "The user hurls giant chunks of ice at the target to inflict damage. This may also make the target flinch.",
                  :ICE, :physical, 10, 100, 85, 0x00F, :AllNonUsers)
             .flag(:effect, 30)

  PokeModifier.add(:DARTRIX)
              .add_evolution({ :species => :DECIDUEYE, :method => :Item, :parameter => :ANCIENTTEACH })
              .add_evo_override { |_, item| DECIDUEYE_HISUIAN if item == :ANCIENTTEACH }

  DECIDUEYE_HISUIAN = PokeModifier.add_form(:DECIDUEYE, "Hisuian Form")
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :GRASS, :Type2 => :FIGHTING})
              .stats([88, 112, 80, 95, 95, 60])
              .abilities({0 => :OVERGROW, 1 => :SCRAPPY, 2 => :OVERGROW})
              .set_ev([0, 3, 0, 0, 0, 0])
              .level_moves([[0, :TRIPLEARROWS], [1, :LEAFSTORM], [1, :UTURN], [1, :TACKLE], [1, :GROWL], [1, :LEAFAGE], [9, :PECK], [12, :SHADOWSNEAK], [15, :RAZORLEAF], [20, :SYNTHESIS], [25, :PLUCK], [30, :BULKUP], [37, :SUCKERPUNCH], [44, :LEAFBLADE], [51, :FEATHERDANCE], [58, :BRAVEBIRD]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :AIRCUTTER, :AIRSLASH, :AURASPHERE, :BATONPASS, :BRAVEBIRD, :BRICKBREAK, :BULKUP, :BULLETSEED, :CLOSECOMBAT, :COVET, :CURSE, :DEFOG, :DUALWINGBEAT, :ECHOEDVOICE, :ENERGYBALL, :FALSESWIPE, :FOCUSBLAST, :FOCUSENERGY, :FRENZYPLANT, :GIGADRAIN, :GIGAIMPACT, :GRASSKNOT, :GRASSPLEDGE, :GRASSYGLIDE, :GRASSYTERRAIN, :HELPINGHAND, :HYPERBEAM, :KNOCKOFF, :LEAFBLADE, :LEAFSTORM, :LIGHTSCREEN, :LOWKICK, :LOWSWEEP, :MAGICALLEAF, :NASTYPLOT, :NATUREPOWER, :OMINOUSWIND, :PLUCK, :PSYCHOCUT, :RAINDANCE, :REVERSAL, :ROCKSMASH, :ROCKTOMB, :ROOST, :SAFEGUARD, :SCARYFACE, :SEEDBOMB, :SHADOWCLAW, :SKYATTACK, :SOLARBEAM, :SPIKES, :STEELWING, :SUCKERPUNCH, :SUNNYDAY, :SWIFT, :SWORDSDANCE, :SYNTHESIS, :TAKEDOWN, :TAILWIND, :TAUNT, :UTURN, :WORKUP, :WORRYSEED, :POISONSWEEP, :SLASHANDBURN, :STACKINGSHOT])
              .set_weight(370)
              .set_dex_entry("Hard of heart and deft of blade, this rare form of Samurott is a product of the Pokémon’s evolution in the region of Hisui. Its turbulent blows crash into foes like ceaseless pounding waves.")
              .asset_override(asset: "UniLib/Assets/Battlers/decidueye-hisuian.png", icon: "UniLib/Assets/Icons/decidueye-hisuian.png")
              .get_form

  MoveBuilder.add(:TRIPLEARROWS, "Triple Arrows",
                  "The user kicks, then fires three arrows. This move has a heightened critical hit ratio and may also lower the target's Defense stat or make it flinch.",
                  :PSYCHIC, :physical, 10, 90, 100, 0x503)
             .flag(:effect, 50)
             .flag(:moreeffect, 30)
             .flag(:highcrit, true)

  class PokeBattle_Move_503 < PokeBattle_Move

    def pbAdditionalEffect(attacker, opponent)
      opponent.pbReduceStat(PBStats::DEFENSE, 1, abilitymessage: false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::DEFENSE, false)
      true
    end

    def pbSecondAdditionalEffect(attacker, opponent)
      return (opponent.effects[:Flinch] = true) if opponent.ability != :INNERFOCUS && !opponent.damagestate.substitute
      false
    end

    def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
      @battle.pbAnimation(id == :TRIPLEARROWS ? :THOUSANDARROWS : id, attacker, opponent, hitnum) if showanimation
    end

  end

  PokeModifier.add(:STANTLER)
              .add_evolution({ :species => :WYRDEER, :method => :HasMove, :parameter => :PSYSHIELDBASH })
              .level_moves([31,:PSYSHIELDBASH])

  PokeBuilder.add(:WYRDEER, "Wyrdeer", 899)
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :NORMAL, :Type2 => :PSYCHIC})
              .stats([103, 105, 72, 105, 75, 65])
              .abilities({0 => :INTIMIDATE, 1 => :FRISK, 2 => :INTIMIDATE})
              .set_ev([0, 0, 0, 1, 0, 0])
              .set_growth_rate(:Slow)
              .set_gender_ratio(:FemHalf)
              .set_base_exp(163)
              .set_catch_rate(45)
              .set_happiness(70)
              .set_egg_steps(5355)
              .set_preevo({:species => :STANTLER, :form => 0})
              .level_moves([[0, :PSYSHIELDBASH], [1, :TACKLE], [3, :LEER], [7, :ASTONISH], [10, :HYPNOSIS], [13, :STOMP], [16, :SANDATTACK], [21, :TAKEDOWN], [23, :CONFUSERAY], [27, :CALMMIND], [32, :ROLEPLAY], [37, :ZENHEADBUTT], [49, :IMPRISON], [55, :DOUBLEEDGE], [62, :MEGAHORN]])
              .egg_moves([])
              .compatible_moves([:AGILITY, :BODYSLAM, :BOUNCE, :BULLDOZE, :CALMMIND, :CHARGEBEAM, :CURSE, :DETECT, :DIG, :DOUBLEEDGE, :DREAMEATER, :EARTHPOWER, :EARTHQUAKE, :ENERGYBALL, :FLASH, :GIGAIMPACT, :GRAVITY, :HEADBUTT, :HELPINGHAND, :HYPERBEAM, :HYPNOSIS, :IMPRISON, :IRONTAIL, :LASTRESORT, :LIGHTSCREEN, :MAGICROOM, :MEGAHORN, :MIMIC, :MUDSLAP, :NIGHTMARE, :PSYCHIC, :PSYCHUP, :PSYSHOCK, :RAINDANCE, :RETALIATE, :REFLECT, :ROAR, :ROLEPLAY, :SCARYFACE, :SHADOWBALL, :SHOCKWAVE, :SIGNALBEAM, :SKILLSWAP, :SOLARBEAM, :SPITE, :STOREDPOWER, :SUCKERPUNCH, :SUNNYDAY, :SWIFT, :TAKEDOWN, :THIEF, :THROATCHOP, :THUNDER, :THUNDERBOLT, :THUNDERWAVE, :TRICK, :TRICKROOM, :UPROAR, :WILDCHARGE, :WORKUP, :ZENHEADBUTT, :POISONSWEEP, :QUICKSILVERSPEAR])
              .set_color("White")
              .set_egg_groups([:Field])
              .set_height(18)
              .set_weight(951)
              .set_dex_entry("The black orbs shine with an uncanny light when the Pokémon is erecting invisible barriers. The fur shed from its beard retains heat well and is a highly useful material for winter clothing.")
              .set_kind("Seed")
              .set_battler_player_y(21)
              .set_battler_enemy_y(10)
              .set_battler_altitude(0)
              .asset_override(asset: "UniLib/Assets/Battlers/wyrdeer.png", icon: "UniLib/Assets/Icons/wyrdeer.png", cry: "UniLib/Assets/Audio/Cry/wyrdeer.ogg")

  MoveBuilder.add(:PSYSHIELDBASH, "Psyshield Bash",
                  "The user performs a psychic slam into the target. This boosts the user’s Defense stat.",
                  :PSYCHIC, :physical, 10, 70, 90, 0x01D)
             .flag(:effect, 100)
             .flag(:contact, :true)
             .flag(:kingrock, true)

  PokeModifier.add(:SCYTHER)
              .add_evolution({ :species => :KLEAVOR, :method => :Item, :parameter => :BLACKAUGURITE })

  PokeBuilder.add(:KLEAVOR, "Kleavor", 900)
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :BUG, :Type2 => :ROCK})
              .stats([70, 135, 95, 45, 70, 85])
              .abilities({0 => :SWARM, 1 => :SHEERFORCE, 2 => :SWARM})
              .set_ev([0, 0, 0, 1, 0, 0])
              .set_growth_rate(:MediumFast)
              .set_gender_ratio(:FemHalf)
              .set_base_exp(163)
              .set_catch_rate(45)
              .set_happiness(70)
              .set_egg_steps(5355)
              .set_preevo({:species => :SCYTHER, :form => 0})
              .level_moves([[0, :STONEAXE], [1, :QUICKATTACK], [1, :LEER], [4, :FURYCUTTER], [8, :FALSESWIPE], [12, :SMACKDOWN], [16, :DOUBLETEAM], [20, :DOUBLEHIT], [24, :SLASH], [28, :FOCUSENERGY], [32, :AGILITY], [36, :ROCKSLIDE], [40, :XSCISSOR], [44, :SWORDSDANCE]])
              .egg_moves([])
              .compatible_moves([:ACROBATICS, :AERIALACE, :AIRCUTTER, :AIRSLASH, :AGILITY, :ASSURANCE, :BATONPASS, :BRICKBREAK, :BRUTALSWING, :BUGBITE, :BUGBUZZ, :CALMMIND, :CLOSECOMBAT, :COUNTER, :CROSSPOISON, :CUT, :DEFOG, :DETECT, :DUALWINGBEAT, :FALSESWIPE, :FOCUSENERGY, :FURYCUTTER, :GIGAIMPACT, :HEADBUTT, :HELPINGHAND, :HYPERBEAM, :KNOCKOFF, :LASERFOCUS, :LIGHTSCREEN, :OMINOUSWIND, :PSYCHOCUT, :RAGE, :RAINDANCE, :RAZORWIND, :REVERSAL, :ROCKBLAST, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :ROOST, :SAFEGUARD, :SANDSTORM, :SCARYFACE, :SILVERWIND, :SKULLBASH, :SMACKDOWN, :STEELWING, :STONEEDGE, :STEALTHROCK, :STRUGGLEBUG, :SUNNYDAY, :SWIFT, :SWORDSDANCE, :TAKEDOWN, :TAILWIND, :THIEF, :UTURN, :VACUUMWAVE, :XSCISSOR, :IRRITATION, :SLASHANDBURN, :STACKINGSHOT])
              .set_color("Brown")
              .set_egg_groups([:Bug])
              .set_height(18)
              .set_weight(890)
              .set_dex_entry("A violent creature that fells towering trees with its crude axes and shields itself with hard stone. If one should chance upon this Pokémon in the wilds, one's only recourse is to flee.")
              .set_kind("Axe")
              .set_battler_player_y(28)
              .set_battler_enemy_y(15)
              .set_battler_altitude(0)
              .asset_override(asset: "UniLib/Assets/Battlers/kleavor.png", cry: "UniLib/Assets/Audio/Cry/kleavor.ogg", icon: "UniLib/Assets/Icons/kleavor.png")

  MoveBuilder.add(:STONEAXE, "Stone Axe",
                  "The user swings its stone axes at the target, aiming to land a critical hit. Stone splinters left behind by this attack float around the target.",
                  :ROCK, :physical, 15, 65, 90, 0x105)
             .flag(:effect, 100)
             .flag(:contact, :true)
             .flag(:highcrit, true)
             .flag(:sharpmove, true)
             .flag(:kingrock, true)

  PokeBuilder.add(:URSALUNA, "Ursaluna", 901)
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :NORMAL, :Type2 => :GROUND})
              .stats([130, 140, 105, 45, 80, 50])
              .abilities({0 => :GUTS, 1 => :BULLETPROOF, 2 => :GUTS})
              .set_ev([0, 2, 0, 0, 0, 0])
              .set_growth_rate(:MediumFast)
              .set_gender_ratio(:FemHalf)
              .set_base_exp(175)
              .set_catch_rate(60)
              .set_happiness(70)
              .set_egg_steps(5355)
              .set_preevo({:species => :URSARING, :form => 0})
              .level_moves([[0, :HEADLONGRUSH], [1, :COVET], [1, :SCRATCH], [1, :LEER], [1, :LICK], [1, :FAKETEARS], [8, :FURYSWIPES], [13, :PAYBACK], [17, :SWEETSCENT], [22, :SLASH], [25, :PLAYNICE], [29, :PLAYROUGH], [35, :SCARYFACE], [41, :REST], [41, :SNORE], [48, :HIGHHORSEPOWER], [56, :THRASH], [64, :HAMMERARM]])
              .egg_moves([])
              .compatible_moves([:AERIALACE, :AVALANCHE, :BABYDOLLEYES, :BODYPRESS, :BODYSLAM, :BRICKBREAK, :BULKUP, :BULLDOZE, :CHARM, :CLOSECOMBAT, :COVET, :CUT, :CRUNCH, :DIG, :DOUBLEEDGE, :DRAINPUNCH, :DYNAMICPUNCH, :EARTHPOWER, :EARTHQUAKE, :FAKETEARS, :FIREPUNCH, :FLING, :FOCUSBLAST, :FOCUSENERGY, :FOCUSPUNCH, :FURYCUTTER, :GIGAIMPACT, :GUNKSHOT, :HEADBUTT, :HEAVYSLAM, :HELPINGHAND, :HIGHHORSEPOWER, :HONECLAWS, :HYPERBEAM, :HYPERVOICE, :ICEPUNCH, :LASERFOCUS, :LASTRESORT, :LOWKICK, :MEGAPUNCH, :MEGAKICK, :METRONOME, :MIMIC, :MUDSLAP, :PAYBACK, :PLAYROUGH, :POWERUPPUNCH, :RAINDANCE, :ROAR, :ROCKCLIMB, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :ROLLOUT, :SCARYFACE, :SEEDBOMB, :SHADOWCLAW, :SMACKDOWN, :STOMPINGTANTRUM, :STONEEDGE, :STRENGTH, :SUNNYDAY, :SUPERPOWER, :SWIFT, :SWORDSDANCE, :TAKEDOWN, :TAUNT, :THIEF, :THROATCHOP, :THUNDERPUNCH, :TORMENT, :UPROAR, :WORKUP, :ZAPCANNON, :POISONSWEEP, :STACKINGSHOT])
              .set_color("Brown")
              .set_egg_groups([:Field])
              .set_height(18)
              .set_weight(1258)
              .set_dex_entry("I believe it was Hisui's swampy terrain that gave Ursaluna its burly physique and newfound capacity to manipulate peat at will.")
              .set_kind("Peat")
              .set_battler_player_y(13)
              .set_battler_enemy_y(8)
              .set_battler_altitude(0)
              .asset_override(asset: "UniLib/Assets/Battlers/ursaluna.png", cry: "UniLib/Assets/Audio/Cry/ursaluna.ogg", icon: "UniLib/Assets/Icons/ursaluna.png")

  MoveBuilder.add(:HEADLONGRUSH, "Headlong Rush",
                  "The user smashes into the target in a full-body tackle. This also lowers the user's Defense and Sp. Def stats.",
                  :GROUND, :physical, 5, 120, 100, 0x03C)
             .flag(:contact, true)
             .flag(:punchmove, true)
             .flag(:kingrock, true)

  PokeBuilder.add(:BASCULEGION, "Basculegion", 902)
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :WATER, :Type2 => :GHOST})
              .stats([120, 112, 65, 80, 75, 78])
              .abilities({0 => :SWIFTSWIM, 1 => :ADAPTABILITY, 2 => :MOLDBREAKER})
              .set_ev([0, 0, 0, 0, 0, 2])
              .set_growth_rate(:MediumFast)
              .set_gender_ratio(:FemHalf)
              .set_base_exp(161)
              .set_catch_rate(25)
              .set_happiness(70)
              .set_egg_steps(10240)
              .set_preevo({:species => :BASCULIN, :form => 2})
              .level_moves([[1, :SHADOWBALL], [1, :PHANTOMFORCE], [1, :WATERGUN], [1, :TAILWHIP], [4, :TACKLE], [8, :FLAIL], [12, :AQUAJET], [16, :BITE], [20, :SCARYFACE], [24, :HEADBUTT], [28, :SOAK], [32, :CRUNCH], [36, :TAKEDOWN], [40, :UPROAR], [44, :WAVECRASH], [48, :THRASH], [52, :DOUBLEEDGE], [56, :HEADSMASH], [100, :LASTRESPECTS]])
              .egg_moves([])
              .compatible_moves([:AGILITY, :AQUATAIL, :BLIZZARD, :CALMMIND, :CRUNCH, :DOUBLEEDGE, :ENDEAVOR, :GIGAIMPACT, :HEADBUTT, :HEX, :HYDROPUMP, :HYPERBEAM, :ICEBEAM, :ICEFANG, :ICYWIND, :LIQUIDATION, :MUDSHOT, :NIGHTSHADE, :OMINOUSWIND, :OUTRAGE, :PHANTOMFORCE, :PSYCHIC, :PSYCHICFANGS, :RAINDANCE, :SCARYFACE, :SHADOWBALL, :SURF, :SWIFT, :TAKEDOWN, :UPROAR, :WATERFALL, :WATERPULSE, :ZENHEADBUTT, :DELUGE])
              .set_color("Green")
              .set_egg_groups([:Water2])
              .set_height(10)
              .set_weight(180)
              .set_dex_entry("Clads itself in the souls of comrades that perished before fulfilling their goals of journeying upstream. No other species throughout all Hisui's rivers is Basculegion's equal.")
              .set_kind("Hostile")
              .set_battler_player_y(30)
              .set_battler_enemy_y(5)
              .set_battler_altitude(5)
              .asset_override(form: :ALL, asset: "UniLib/Assets/Battlers/basculegion.png", asset_f: "UniLib/Assets/Battlers/basculegion_f.png", cry: "UniLib/Assets/Audio/Cry/basculegion.ogg", icon: "UniLib/Assets/Icons/basculegion.png", icon_f: "UniLib/Assets/Icons/basculegion_f.png")

  PokeModifier.add_form(:BASCULEGION, "Female")
              .stats([120, 92, 65, 100, 75, 78])

  MoveBuilder.add(:WAVECRASH, "Wave Crash",
                  "The user shrouds itself in water and slams into the target with its whole body to inflict damage. This also damages the user quite a lot.",
                  :WATER, :physical, 5, 120, 100)
             .flag(:contact, true)
             .flag(:kingrock, true)
             .flag(:recoil, 0.33)

  MoveBuilder.add(:LASTRESPECTS, "Last Respects",
                  "The user attacks to avenge its allies. The more defeated allies there are in the user's party, the greater the move's power.",
                  :GHOST, :physical, 10, 50, 100, 0xFCF)
             .flag(:kingrock, true)

  class PokeBattle_Move_FCF < PokeBattle_Move

    def pbBaseDamage(basedmg, attacker, opponent)
      50 + 50 * attacker.battle.pbParty(attacker.index).reduce(0) { |mul, member| !member.nil? and member.fainted ? mul + 0.5 : mul}
    end

  end

  PokeBuilder.add(:SNEASLER, "Sneasler", 903)
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :POISON, :Type2 => :FIGHTING})
              .stats([80, 130, 60, 40, 80, 120])
              .abilities({0 => :PRESSURE, 1 => :UNBURDEN, 2 => :PRESSURE})
              .set_ev([0, 0, 0, 0, 0, 3])
              .set_growth_rate(:MediumSlow)
              .set_gender_ratio(:FemHalf)
              .set_base_exp(86)
              .set_catch_rate(60)
              .set_happiness(35)
              .set_egg_steps(5355)
              .set_preevo({:species => :SNEASEL, :form => 1})
              .level_moves([[0, :DIRECLAW], [1, :FLING], [1, :SCRATCH], [1, :LEER], [1, :ROCKSMASH], [6, :TAUNT], [12, :QUICKATTACK], [18, :METALCLAW], [24, :POISONJAB], [30, :BRICKBREAK], [36, :HONECLAWS], [42, :SLASH], [48, :AGILITY], [54, :SCREECH], [60, :CLOSECOMBAT]])
              .egg_moves([])
              .compatible_moves([:ACROBATICS, :AERIALACE, :AGILITY, :BRICKBREAK, :BULKUP, :CALMMIND, :CLOSECOMBAT, :COUNTER, :DIG, :DRAINPUNCH, :FALSESWIPE, :FIREPUNCH, :FLING, :FOCUSBLAST, :FOCUSENERGY, :GIGAIMPACT, :GRASSKNOT, :GUNKSHOT, :HONECLAWS, :HYPERBEAM, :IRONTAIL, :LOWKICK, :LOWSWEEP, :NASTYPLOT, :POISONJAB, :RAINDANCE, :REVERSAL, :ROCKSLIDE, :ROCKSMASH, :ROCKTOMB, :SCREECH, :SHADOWBALL, :SHADOWCLAW, :SLUDGEBOMB, :SNARL, :SUNNYDAY, :SWIFT, :SWORDSDANCE, :TAKEDOWN, :TAUNT, :THIEF, :SPIKES, :UTURN, :VENOSHOCK, :XSCISSOR, :DELUGE, :POISONSWEEP, :SLASHANDBURN, :STACKINGSHOT])
              .set_color("Blue")
              .set_egg_groups([:Field])
              .set_height(13)
              .set_weight(280)
              .set_dex_entry("Because of Sneasler's virulent poison and daunting physical prowess, no other species could hope to best it on the frozen highlands. Preferring solitude, this species does not form packs.")
              .set_kind("Sharp Claw")
              .set_battler_player_y(26)
              .set_battler_enemy_y(12)
              .set_battler_altitude(0)
              .asset_override(asset: "UniLib/Assets/Battlers/sneasler.png", cry: "UniLib/Assets/Audio/Cry/sneasler.ogg", icon: "UniLib/Assets/Icons/sneasler.png")

  MoveBuilder.add(:DIRECLAW, "Dire Claw",
                  "The user lashes out with ruinous claws, aiming to land a critical hit. It may leave the target poisoned, paralyzed, or asleep.",
                  :POISON, :physical, 15, 80, 100, 0x500)
             .flag(:effect, 50)
             .flag(:contact, true)
             .flag(:kingrock, true)

  class PokeBattle_Move_500 < PokeBattle_Move

    def pbAdditionalEffect(attacker, opponent)
      case @battle.pbRandom(3)
      when 0
        return false unless opponent.pbCanSleep?(false)
        opponent.pbSleep
        @battle.pbDisplay(_INTL("{1} fell asleep!", opponent.pbThis))
      when 1
        return false unless opponent.pbCanPoison?(false)
        opponent.pbPoison(attacker)
        @battle.pbDisplay(_INTL("{1} was poisoned!", opponent.pbThis))
      else
        return false unless opponent.pbCanParalyze?(false)
        opponent.pbParalyze(attacker)
        @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!", opponent.pbThis))
      end
      true
    end

    def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true)
      @battle.pbAnimation(id == :DIRECLAW ? :CROSSPOISON : id, attacker, opponent, hitnum) if showanimation
    end

  end

  PokeBuilder.add(:OVERQWIL, "Overqwil", 904)
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :DARK, :Type2 => :POISON})
              .stats([85, 115, 95, 65, 65, 85])
              .abilities({0 => :POISONPOINT, 1 => :SWIFTSWIM, 2 => :POISONPOINT})
              .set_ev([0, 3, 0, 0, 0, 0])
              .set_growth_rate(:MediumFast)
              .set_gender_ratio(:FemHalf)
              .set_base_exp(86)
              .set_catch_rate(45)
              .set_happiness(70)
              .set_egg_steps(5355)
              .set_preevo({:species => :QWILFISH, :form => 1})
              .level_moves([[1, :POISONSTING], [1, :TACKLE], [4, :HARDEN], [8, :BITE], [12, :FELLSTINGER], [16, :MINIMIZE], [20, :SPIKES], [24, :BRINE], [28, :BARBBARRAGE], [32, :PINMISSILE], [36, :TOXICSPIKES], [40, :STOCKPILE], [40, :SPITUP], [44, :TOXIC], [48, :CRUNCH], [52, :ACUPRESSURE], [56, :DESTINYBOND]])
              .egg_moves([])
              .compatible_moves([:AGILITY, :AQUATAIL, :BLIZZARD, :BRINE, :BUBBLEBEAM, :CRUNCH, :DARKPULSE, :DOUBLEEDGE, :FELLSTINGER, :GIGAIMPACT, :GUNKSHOT, :HEX, :HYDROPUMP, :HYPERBEAM, :ICEBALL, :ICEBEAM, :ICYWIND, :LIQUIDATION, :MUDSHOT, :PINMISSILE, :POISONJAB, :RAINDANCE, :REVERSAL, :SCARYFACE, :SELFDESTRUCT, :SHADOWBALL, :SLUDGEBOMB, :SMARTSTRIKE, :SPIKES, :SURF, :SWIFT, :SWORDSDANCE, :TAKEDOWN, :TAUNT, :TOXICSPIKES, :VENOSHOCK, :WATERFALL, :WATERPULSE, :DELUGE, :IRRITATION, :MUDBARRAGE, :QUICKSILVERSPEAR])
              .set_color("Gray")
              .set_egg_groups([:Water2])
              .set_height(5)
              .set_weight(39)
              .set_dex_entry("Its lancelike spikes and savage temperament have earned it the nickname 'sea fiend'. It slurps up poison to nourish itself.")
              .set_kind("Balloon")
              .set_battler_player_y(25)
              .set_battler_enemy_y(17)
              .set_battler_altitude(12)
              .asset_override(asset: "UniLib/Assets/Battlers/overqwil.png", cry: "UniLib/Assets/Audio/Cry/overqwil.ogg", icon: "UniLib/Assets/Icons/overqwil.png")

  PokeBuilder.add(:ENAMORUS, "Enamorus", 905)
              .level_moves_overwrite
              .egg_moves_overwrite
              .compatible_moves_overwrite
              .types({:Type1 => :FAIRY, :Type2 => :FLYING})
              .stats([74, 115, 70, 135, 80, 106])
              .abilities({0 => :CUTECHARM, 1 => :CONTRARY, 2 => :CUTECHARM})
              .set_ev([0, 0, 0, 3, 0, 0])
              .set_growth_rate(:Slow)
              .set_gender_ratio(:MaleZero)
              .set_base_exp(270)
              .set_catch_rate(3)
              .set_happiness(90)
              .set_egg_steps(30720)
              .level_moves([[1, :ASTONISH], [1, :FAIRYWIND], [5, :TORMENT], [10, :FLATTER], [15, :TWISTER], [20, :DRAININGKISS], [25, :IRONDEFENSE], [30, :IMPRISON], [35, :MYSTICALFIRE], [40, :DAZZLINGGLEAM], [45, :EXTRASENSORY], [50, :UPROAR], [55, :SUPERPOWER], [60, :HEALINGWISH], [65, :MOONBLAST], [70, :OUTRAGE], [75, :SPRINGTIDESTORM]])
              .egg_moves([])
              .compatible_moves([:AGILITY, :BODYSLAM, :CALMMIND, :CRUNCH, :DAZZLINGGLEAM, :DRAININGKISS, :EARTHPOWER, :FLY, :FOCUSBLAST, :GIGAIMPACT, :GRASSKNOT, :GRASSYTERRAIN, :HYPERBEAM, :IMPRISON, :IRONDEFENSE, :IRONHEAD, :MISTYTERRAIN, :MYSTICALFIRE, :OUTRAGE, :PLAYROUGH, :PSYCHIC, :RAINDANCE, :ROCKSMASH, :SCARYFACE, :SLUDGEBOMB, :SUNNYDAY, :SUPERPOWER, :TAILWIND, :TAKEDOWN, :TAUNT, :TORMENT, :TWISTER, :ZENHEADBUTT, :MUDBARRAGE, :STACKINGSHOT])
              .set_color("Pink")
              .set_egg_groups([:Undiscovered])
              .set_height(15)
              .set_weight(680)
              .set_dex_entry("When it flies to this land from across the sea, the bitter winter comes to an end. According to legend, this Pokémon's love gives rise to the budding of fresh life across Hisui.")
              .set_kind("Love-Hate")
              .set_battler_player_y(14)
              .set_battler_enemy_y(8)
              .set_battler_altitude(10)
              .asset_override(asset: "UniLib/Assets/Battlers/enamorus.png", cry: "UniLib/Assets/Audio/Cry/enamorus.ogg", icon: "UniLib/Assets/Icons/enamorus.png")

  ENAMORUS_THERIAN = PokeModifier.add_form(:ENAMORUS, "Therian Form")
              .stats([74, 115, 110, 135, 100, 46])
              .abilities({0 => :OVERCOAT, 1 => nil, 2 => :OVERCOAT})
              .set_ev([0, 0, 0, 3, 0, 0])
              .set_dex_entry("A different guise from its feminine humanoid form. From the clouds, it descends upon those who treat any form of life with disrespect and metes out wrathful, ruthless punishment.")
              .asset_override(asset: "UniLib/Assets/Battlers/enamorus-therian.png", icon: "UniLib/Assets/Icons/enamorus-therian.png")
              .get_form

  MoveBuilder.add(:SPRINGTIDESTORM, "Springtide Storm",
                  "Shoots its own armor out as blazing projectiles. Lowers user's Def and SpDef.",
                  :FAIRY, :special, 5, 100, 80, 0x042)
             .flag(:kingrock, true)
             .flag(:windmove, true)

end unless UniLib.cached(UniLib::HISUIAN_PORTS)