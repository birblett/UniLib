# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Crest"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

# fix jaw lock not being considered a bite move
PBStuff::BITEMOVE |= [:JAWLOCK]

# fix claydol and dedenne crest stat change + stat usage behaviors
CrestBuilder.add_existing(:CLAYCREST)
            .add_receiver(:CLAYDOL)
            .move_stat_override { |_, _, move| next :def if move.pbIsSpecial?(move) } if Rejuv

CrestBuilder.add_existing(:DEDECREST)
            .add_receiver(:DEDENNE)
            .move_stat_override { |_, _, move| next :spe unless move.pbIsSpecial?(move) } if Rejuv

# no longer replace their raw spa stat with def/atk stat with spe
UniLib.delete_in_method(:PokeBattle_Battler, :crestStats, "@spatk = @defense") if Rejuv
UniLib.delete_in_method(:PokeBattle_Battler, :crestStats, "@attack = @speed") if Rejuv

# move calculation to crest/itembuilder internals
UniLib.replace_in_method(:PokeBattle_Move, :pbCalcDamage, "case attacker.crested", "case nil", 1)

# fix cherrim crest attack boost not applied
CrestBuilder.add_existing(Reborn ? :CHERRIMCREST : :CHERCREST)
            .add_receiver(:CHERRIM, "Sunshine")
            .damage_mod { |_, _, move, _, is_ai| next 1.5 if !is_ai and move.pbIsPhysical?(move) }

# fix silent exception when sleep talk called with less than 4 moves in moveset
UniLib.replace_in_method(:PokeBattle_Move_0B4, :pbEffect, "choices = (0...4).to_a.select{|i| (attacker.moves[i].move.is_a?(Symbol)) && !blacklist.include?(attacker.moves[i].move) && @battle.pbCanChooseMove?(attacker.index,i,false,{sleeptalk: true})}",
  "choices = (0...attacker.moves.length).to_a.select{|i| (attacker.moves[i].move.is_a?(Symbol)) && !blacklist.include?(attacker.moves[i].move) && @battle.pbCanChooseMove?(attacker.index,i,false,{sleeptalk: true})}") if Rejuv
UniLib.replace_in_method(:PokeBattle_AI, :sleeptalkcode, "for i in 0..3", "for i in 0...@attacker.moves.length")

# fix no fail message for stuff cheeks
UniLib.insert_in_method_before(:PokeBattle_Move_17A, :pbEffect, "return -1", "@battle.pbDisplay(\"But it failed!\")")

# fix redundant pulse camerupt check
UniLib.replace_in_method(:PokeBattle_AI, :getMoveScore, "if (@battle.opponent.trainertype==:CAMERUPT)", "if false") if Rejuv

# stop ai from attacking protection
UniLib.insert_in_method(:PokeBattle_AI, :pbTypeModNoMessages, :HEAD,
  "return -1 if opponent.pbOwnSide.effects[:MatBlock] || opponent.effects[:Protect] || opponent.effects[:KingsShield] || opponent.effects[:Obstruct] || opponent.effects[:SpikyShield] || opponent.effects[:BanefulBunker] unless opponent.ability == :UNSEENFIST or [0xad, 0xcd, 0x157, 0x159].include? move.function")

# fixes primal reversion
UniLib.insert_in_method(:PokeBattle_Battler, :pbAbilitiesOnSwitchIn, "@pokemon.makePrimal", "self.form = @pokemon.form")

# fix instruct + struggle exception
UniLib.insert_in_method_before(:PokeBattle_AI, :instructcode, "lastmove = @attacker.pbPartner.lastMoveUsed", "return 0 if lastmove  == :STRUGGLE")