# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Pokemon"
UniLib.include "Ability"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

unless UniLib.cached(UniLib::FORM_PORTS)

  AbilityModifier.add(:BATTLEBOND)
              .set_all_desc("KO's strengthen the Pokémon's bond...")
              .set_full_desc("KO's strengthen the Pokémon's bond with its trainer.")
              .on_ko { |user, _, _|
                if user.form == 1 and user.species == :GRENINJA
                  user.battle.permanenteffects[user.pokemon][:BattleBond] = true
                  user.form = GRENINJA_ASH_FORM
                  user.battle.pbCommonAnimation("SchoolForm", user, nil)
                  user.pbUpdate(true)
                  user.battle.scene.pbChangePokemon(user, user.pokemon)
                  user.battle.pbDisplay(_INTL("{1} became fully charged due to the bond with its trainer!", user.pbThis))
                end
              }
              .damage_mod { |user, _, move, _, _| 4/3 if user.species == :GRENINJA and user.form == 2 and move.move == :WATERSHURIKEN }

  UniLib.insert_in_method(:PokeBattle_Move_0C0, :pbNumHits, :HEAD,
    "return 3 if attacker.species == :GRENINJA and attacker.form == 2")

  GRENINJA_ASH_FORM = PokeModifier.add_form(:GRENINJA, "Ash Form")
              .abilities({ 0 => :BATTLEBOND, 1 => nil, 2 => :BATTLEBOND })
              .stats(0, 145, 0, 153, 0, 132)
              .asset_override(asset: "UniLib/Assets/Battlers/greninja-ash.png", icon: "UniLib/Assets/Icons/greninja-ash.png")
              .end_of_battle_reset(1)
              .form

end