# unilib supports adding crests and also includes a number of rejuv-ported crests in the CrestCompat module

# add the ariados crest - for existing crests, make sure to add the original pokemon as a receiver
# increases crit ratio by 3 on wasteland field
CrestBuilder.add_existing(ARIADOS_CREST)
            .add_receiver(:ARIADOS)
            .crit_mod { |attacker, _, _| next 3 if attacker.battle.FE == :WASTELAND }

# add a rotom crest with a different effect for each form
ROTOM_CREST = CrestBuilder.add(:ROTOM, "Grants innate abilities based on the form.")
                          .add_receiver(:ROTOM, "Heat")
                          .add_receiver(:ROTOM, "Wash")
                          .add_receiver(:ROTOM, "Frost")
                          .add_receiver(:ROTOM, "Fan")
                          .add_receiver(:ROTOM, "Mow")
                          .battle_stat_mods { |_, bs| bs[5].mul(1.1) }
                          .ability_provider { |pkmn, _|
                            case pkmn.form
                            when 1 then [:FLAMEBODY, :REGENERATOR]
                            when 2 then [:DAUNTLESSSHIELD, :RAINDISH]
                            when 3 then [:SLUSHRUSH, :SNOWCOAT, :FILTER]
                            when 4 then [:DELTASTREAM, :SERENEGRACE]
                            when 5 then [:DROUGHT, :SOLARPOWER]
                            else [:ADAPTABILITY, :MAGICGUARD]
                            end
                          }
                          .role_provider { |_, pkmn|
                            case pkmn.form
                            when 1 then :PIVOT
                            when 2 then :TANK if pkmn.battle.weather == :RAIN
                            when 3 then :SWEEPER if pkmn.battle.weather == :HAIL
                            when 5 then :SWEEPER
                            when 0 then :STATUSABSORBER
                            else nil
                            end
                          }
                          .sym