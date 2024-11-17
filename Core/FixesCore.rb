# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)
UniLib.include "Crest"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

PBStuff::BITEMOVE |= [:JAWLOCK]

# fix claydol and dedenne crest stat change + stat usage behaviors
CrestBuilder.add_existing(:CLAYCREST)
            .add_receiver(:CLAYDOL)
            .move_stat_override { |_, _, move| next :def if move.pbIsSpecial?(move) }

CrestBuilder.add_existing(:DEDECREST)
            .add_receiver(:DEDENNE)
            .move_stat_override { |_, _, move| next :spe unless move.pbIsSpecial?(move) }

# no longer replace their raw spa stat with def/atk stat with spe
UniLib.replace_in_method(:PokeBattle_Battler, :crestStats, "@spatk = @defense", "true")
UniLib.replace_in_method(:PokeBattle_Battler, :crestStats, "@attack = @speed", "true")

# move calculation to crest/itembuilder internals
UniLib.replace_in_method(:PokeBattle_Move, :pbCalcDamage, "case attacker.crested", "case nil", 1)

# fix cherrim crest attack boost not applied
CrestBuilder.add_existing(:CHERCREST)
            .add_receiver(:CHERRIM, "Sunshine")
            .damage_mod { |_, _, move, _, is_ai| next 1.5 if !is_ai and move.pbIsPhysical?(move) }

# fix silent crash when sleep talk called with less than 4 moves in moveset
UniLib.replace_in_method(:PokeBattle_Move_0B4, :pbEffect, "choices = (0...4).to_a.select{|i| (attacker.moves[i].move.is_a?(Symbol)) && !blacklist.include?(attacker.moves[i].move) && @battle.pbCanChooseMove?(attacker.index,i,false,{sleeptalk: true})}",
  "choices = (0...attacker.moves.length).to_a.select{|i| (attacker.moves[i].move.is_a?(Symbol)) && !blacklist.include?(attacker.moves[i].move) && @battle.pbCanChooseMove?(attacker.index,i,false,{sleeptalk: true})}")
UniLib.replace_in_method(:PokeBattle_AI, :sleeptalkcode, "for i in 0..3", "for i in 0...@attacker.moves.length")

# fix no fail message for stuff cheeks
UniLib.insert_in_method_before(:PokeBattle_Move_17A, :pbEffect, "return -1", "@battle.pbDisplay(\"But it failed!\")")