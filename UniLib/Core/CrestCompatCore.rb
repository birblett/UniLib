# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Crest"
UniLib.include "Move"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

if Reborn

  CrestBuilder.add(:ARIADOS, "1.5x Speed. Guaranteed critical on poisoned targets.")

  CrestBuilder.add(:BASTIODON, "Restore half of damage taken and reflect it on the attacker.")

  CrestBuilder.add(:BEHEEYEM, "Faster foes deal 0.67x damage and are disabled if possible.")

  # no boltund (gen 8)

  CrestBuilder.add(:CASTFORM, "Castform uses weather moves in its first slot. Grants additional stats.")

  # buggy stat boost, include Fixes if using
  CrestBuilder.add(:CHERRIM, "Activates Flower Gift.")
              .add_receiver(:CHERRIM, "Sunshine")

  CrestBuilder.add(:CINCCINO, "All moves hit 2-5 times at 0.3x power.")

  CrestBuilder.add(:CLAYDOL, "Attacks use the Defense stat and beam moves are boosted.")

  CrestBuilder.add(:COFAGRIGUS, "1.25x Sp. Attack/Defense.")
              .battle_stat_mods { |_, bs| bs[3].mul(1.25); bs[4].mul(1.25) }

  CrestBuilder.add(:CRABOMINABLE, "1.5x damage if damage is already taken in a turn. 1.2x defenses.")
              .battle_stat_mods { |_, bs| bs[2].mul(1.2); bs[4].mul(1.2) }

  CrestBuilder.add(:CRYOGONAL, "1.2x Sp. Defense. Other stats are boosted by Sp. Defense.")
              .battle_stat_mods { |_, bs|
                bs[4].mul(1.2)
                val = (bs[4].value * 0.1).to_i
                bs.each_with_index { |stat, i| stat.add(val) unless i == 4 or i == 0 }
              }

  CrestBuilder.add(:DARMANITAN, "Forces user into Zen Mode.")

  # fix zenmode reset at end of turn with crest
  if Reborn

    UniLib.replace_in_method(:PokeBattle_Battler, :pbCheckFormRoundEnd, "if self.crested == :DARMANITAN && self.form == 0",
                             "if self.crested == :DARMANITAN")

    UniLib.replace_in_method(:PokeBattle_Battler, :pbCheckFormRoundEnd, "zenModeTransform",
                             "zenModeTransform if self.form == 0")

  end

  CrestBuilder.add(:DEDENNE, "Physical attacks use the Speed stat.")

  CrestBuilder.add(:DELCATTY, "Delcatty's non-KO'd allies boost its stats.")
              .on_battle_entry { |pkmn, _, _| UniLib.display_if_visible(pkmn.battle, _INTL("{1} gained strength from The Power of Friendship!", pkmn.pbThis)) }
              .battle_stat_mods { |pkmn, bs|
                pkmn.battle.pbParty(pkmn.index).each { |member|
                  next if member.nil? or member == pkmn or member.hp <= 0
                  bs[1].add(member.attack * 0.1)
                  bs[2].add(member.defense * 0.1)
                  bs[3].add(member.spatk * 0.1)
                  bs[4].add(member.spdef * 0.1)
                  bs[5].add(member.speed * 0.1)
                }
              }

  CrestBuilder.add(:DRUDDIGON, "Heals in the sun. 1.3x damage to Dragon and Fire moves.")

  # internally bugged in rejuv, so this uses the internal 1.5x attack instead of the listed 1.2x to be faithful.
  CrestBuilder.add(:DUSKNOIR, "1.5x Attack. 1.5x damage on weaker moves.")
              .battle_stat_mods { |_, bs| bs[1].mul(1.5) }

  CrestBuilder.add(:ELECTRODE, "0.5x target Defense while attacking.")

  CrestBuilder.add(:EMPOLEON, "STAB on Ice moves and 2x Speed while hailing or on Ice Fields.")

  CrestBuilder.add(:FEAROW, "1.5x damage on stabbing moves, and +1 crit ratio.")

  CrestBuilder.add(:FURRET, "Substitute on switch-in.")
              .on_battle_entry { |pkmn, battle, _|
                if pkmn.hp <= (sublife = [(pkmn.totalhp / 4.0).floor, 1].max)
                  @battle.pbDisplay(_INTL("It was too weak to make a substitute!"))
                else
                  pkmn.pbReduceHP(sublife, false, false)
                  pkmn.effects[:UsingSubstituteRightNow] = true
                  battle.pbAnimation(:SUBSTITUTE, pkmn, pkmn, 1)
                  pkmn.effects[:UsingSubstituteRightNow] = false
                  pkmn.effects[:Substitute] = sublife
                  UniLib.display_if_visible(battle, _INTL("{1} put up a substitute!", pkmn.pbThis))
                end
              }

  CrestBuilder.add(:FERALIGATR, "First moves gains priority if damaging. 1.5x damage on biting moves.")

  CrestBuilder.add(:GLACEON, "Grants resistances to Rock and Fighting.")

  CrestBuilder.add(:GOTHITELLE, "Dark and Psychic moves change Gothitelle's type. Recovers HP.")

  CrestBuilder.add(:HYPNO, "1.5x Sp. Attack and accuracy.")
              .battle_stat_mods { |_, bs| bs[3].mul(1.5) }
              .accuracy_mod { |_, _, acc, _, _| acc.mul(1.5); next nil }

  CrestBuilder.add(:INFERNAPE, "Swaps attacking and defensive stats. Recovers HP.")
              .battle_stat_mods { |_, bs|
                a, s = bs[1].value, bs[3].value
                bs[1].set(bs[2].value)
                bs[2].set(a)
                bs[3].set(bs[4].value)
                bs[4].set(s)
              }

  CrestBuilder.add(:LEAFEON, "Grants resistances to Fire and Flying.")

  CrestBuilder.add(:LEDIAN, "Punching moves hit 2-4 times.")

  CrestBuilder.add(:LUVDISC, "Base power of all attacks matches happiness.")

  CrestBuilder.add(:LUXRAY, "Dark STAB and resistances. 1.2x damage and Electric conversion for Normal moves.")

  CrestBuilder.add(:MAGCARGO, "Swap Defense and Speed. 1.1x Sp. Attack.")
              .battle_stat_mods { |_, bs|
                d = bs[1]
                bs[1].set(bs[5])
                bs[5].set(d)
                bs[4].mul(1.1)
              }

  CrestBuilder.add(:MEGANIUM, "User and allies take 0.8x damage and heal every turn.")

  CrestBuilder.add(:NOCTOWL, "Boost Sp. Defense when hit. 1.2x Defense.")
              .battle_stat_mods { |_, bs| bs[2].mul(1.2) }

  CrestBuilder.add(:ORICORIO, "1.25x Sp. Attack and Speed.")
              .add_receiver(:ORICORIO, 1).add_receiver(:ORICORIO, 2).add_receiver(:ORICORIO, 3)
              .battle_stat_mods { |_, bs| bs[3].mul(1.25); bs[5].mul(1.25) }

  CrestBuilder.add(:PHIONE, "1.5x defenses. Aqua Ring on entry.")
              .battle_stat_mods { |_, bs| bs[2].mul(1.5); bs[4].mul(1.5) }
              .on_battle_entry { |pkmn, battle, _|
                pkmn.effects[:AquaRing] = true
                battle.pbAnimation(:AQUARING, pkmn, nil)
              }

  CrestBuilder.add(:PROBOPASS, "Uses Magnet Rise on entry. Follow up attacks with attacks from 3 mini-noses.")
              .on_battle_entry { |pkmn, battle, _|
                pkmn.effects[:MagnetRise] = 8
                battle.pbAnimation(:MAGNETRISE, pkmn, nil)
              }

  MoveBuilder.add(:PROBOPOG, "Probopass PogChampion", "Please don't hack it in, it's a bad move on its own, don't be weirdchamp",
                  :NORMAL, :special, 15, 20, 100, 0x1000, :SingleNonUser, 0, { kingrock: true })

  class PokeBattle_Move_1000 < PokeBattle_Move

    def pbEffect(attacker, opponent, hitnum=0, alltargets=nil, showanimation=true)
      self.type = case hitnum
      when 0 then :STEEL
      when 1 then :ROCK
      else :ELECTRIC
      end
      super(attacker, opponent, hitnum, alltargets, showanimation)
    end

    def pbIsMultiHit = true

    def pbNumHits(attacker) = 3

    # Replacement animation till a proper one is made
    def pbShowAnimation(id, attacker, opponent, hitnum = 0, alltargets = nil, showanimation = true) = (@battle.pbAnimation(:BULLETSEED, attacker, opponent, hitnum) if showanimation)

  end

  CrestBuilder.add(:RAMPARDOS, "Always hang on with 1 HP once per battle. No recoil taken.")

  class PokeBattle_Pokemon

    attr_accessor :rampCrestUsed

    def rampCrestUsed
      @rampCrestUsed = false if !@rampCrestUsed
      @rampCrestUsed
    end

  end if Reborn

  CrestBuilder.add(:RELICANTH, "1.2x Attack, 1.3x Sp. Defense.")
              .battle_stat_mods { |_, bs| bs[1].mul(1.2); bs[4].mul(1.3) }

  CrestBuilder.add(:REUNICLUS, "Fighting and Psychic moves change form. First move determines initial form.")

  CrestBuilder.add(:SAMUROTT, "Fighting STAB and resistances. Slicing moves always crit.")

  CrestBuilder.add(:SAWSBUCK, "Replaces base type and Normal moves with a seasonal type.")
              .add_receiver(:SAWSBUCK, 1).add_receiver(:SAWSBUCK, 2).add_receiver(:SAWSBUCK, 3)
              .primary_type { |pkmn|
                case pkmn.form
                when 0 then :WATER
                when 1 then :FIRE
                when 2 then :GROUND
                else :ICE
                end
              }

  CrestBuilder.add(:SEVIPER, "1.5x Speed. More damage against healthier foes.")

  CrestBuilder.add(:SHIINOTIC, "Drains 1/16th hp from statused pokemon. 1.3x drain effect recovery.")

  CrestBuilder.add(:SIMIPOUR, "Grass STAB and resistances, Normal moves become Grass, offenses boosted by 1.2x.")
              .battle_stat_mods { |_, bs| (bs[1].mul(1.2); bs[3].mul(1.2)) if Reborn }

  CrestBuilder.add(:SIMISAGE, "Fire STAB and resistances, Normal moves become Fire, offenses boosted by 1.2x.")
              .battle_stat_mods { |_, bs| (bs[1].mul(1.2); bs[3].mul(1.2)) if Reborn }

  CrestBuilder.add(:SIMISEAR, "Water STAB and resistances, Normal moves become Water, offenses boosted by 1.2x.")
              .battle_stat_mods { |_, bs| (bs[1].mul(1.2); bs[3].mul(1.2)) if Reborn }

  CrestBuilder.add(:SILVALLY, "Memories grant abilities and boost their respective type.")
  CrestBuilder.add_hook { |pkmn, battle|
    next CrestHolder.new([:SILVALLY]) if $PokemonBag.pbQuantity(:SILVALLYCREST) > 0 && pkmn.species == :SILVALLY && battle.pbOwnedByPlayer?(pkmn.index) ||
                                           battle.pbGetOwnerItems(pkmn.index).include?(:SILVALLYCREST) && pkmn.species == :SILVALLY && !battle.pbOwnedByPlayer?(pkmn.index)
  }

  CrestBuilder.add(:SKUNTANK, "Ground moves deal no damage and boost Attack. Boosts offenses by 20%.")
              .battle_stat_mods { |_, bs| bs[1].mul(1.2); bs[3].mul(1.2) }

  CrestBuilder.add(:SPIRITOMB, "Boosts damage by 20% for every KO'd ally. Heals based on KO'd foes.")
              .role_provider { :ACE }

  CrestBuilder.add(:STANTLER, "1.5x Attack and Accuracy.")
              .add_receiver(:WYRDEER)
              .battle_stat_mods { |_, bs| bs[1].mul(1.5) }
              .accuracy_mod { |_, _, acc, _, _| acc.mul(1.5); next nil }

  CrestBuilder.add(:SWALOT, "Stockpile after every move. Belch is always usable and followed by Spit Up.")

  # no thievul (gen 8)

  CrestBuilder.add(:TORTERRA, "Resistances and weaknesses are swapped, retaining immunities. Attacks restore HP.")
  UniLib.replace_in_method(:PokeBattle_Move, :pbTypeModifierNonBattler, "if opponent.species == :TORTERRA && opponent.item == :TORCREST",
                           "if opponent.species == :TORTERRA && opponent.item == :TORTERRACREST")

  CrestBuilder.add(:TYPHLOSION, "Attack equals Sp. Attack and contact moves hit twice.")
              .battle_stat_mods { |_, bs| bs[1].set(bs[3].value) }

  CrestBuilder.add(:VESPIQUEN, "Attack/Defend Order grant +1 offenses and defenses respectively. Same boost can't be triggered consecutively.")

  CrestBuilder.add(:WHISCASH, "Grass moves deal no damage and boost Attack. Boosts offenses by 20%.")
              .battle_stat_mods { |_, bs| bs[1].mul(1.2); bs[3].mul(1.2) }

  CrestBuilder.add(:ZANGOOSE, "Poisons on entry, and poison restores HP.")
              .on_battle_entry { |pkmn, _, _|
                pkmn.status = :POISON
                pkmn.battle.pbCommonAnimation("Poison", pkmn, nil)
                UniLib.display_if_visible(pkmn.battle, _INTL("{1} was poisoned by its {2}!", pkmn.pbThis,getItemName(pkmn.item)))
              }

  CrestBuilder.add(:ZOROARK, "Gains ability and STAB of the copied Pokemon.")
              .on_battle_entry { |pkmn, _, _| UniLib.zoroark_crest_handler(pkmn) }
              .conditional_stab_override { |pkmn, move| UniLib.zoroark_crest_handler(pkmn)[1].include?(move) }

  def UniLib.zoroark_crest_handler(pkmn, m = nil)
    pkmn.battle.pbParty(pkmn.index).each { |member| m = member if member }
    return [nil, []] if m.nil? or m == pkmn
    pkmn.set_permanent_effect(:ZOROARK_CREST, [m.ability, m.type2 ? [m.type1, m.type2] : [m.type1]]) unless pkmn.permanent_effect(:ZOROARK_CREST)
    pkmn.ability = pkmn.ability + pkmn.permanent_effect(:ZOROARK_CREST)[0]
    pkmn.permanent_effect(:ZOROARK_CREST)
  end

end

