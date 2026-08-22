# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

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

# stop ai from attacking protection
UniLib.insert_in_method(:PokeBattle_AI, :pbTypeModNoMessages, :HEAD,
  "return -1 if opponent.pbOwnSide.effects[:MatBlock] || opponent.effects[:Protect] || opponent.effects[:KingsShield] || opponent.effects[:Obstruct] || opponent.effects[:SpikyShield] || opponent.effects[:BanefulBunker] unless opponent.ability == :UNSEENFIST or [0xad, 0xcd, 0x157, 0x159].include? move.function")
