# dragonforce changes the user's secondary type to flying when it uses dragon ascent
# we want the ai to think that it gets a stab damage boost, so we set a multiplier with damage_mod if the caller is ai
AbilityBuilder.add(:DRAGONFORCE, "Dragonforce", "Makes the user's secondary type Flying if Dragon Ascent is used")
              .on_move_attempt { |pkmn, move| UniLib.display_if_visible(pkmn.battle, _INTL("{1} is ascending!", pkmn.pbThis, (pkmn.type2 = move.type).capitalize)) if move.move == :DRAGONASCENT and pkmn.type2 != :FLYING }
              .damage_mod { |pkmn, _, move, _, ai| next 1.5 if ai and move.move == :DRAGONASCENT and pkmn.type2 != :FLYING }