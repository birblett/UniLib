# give magikarp 100 bst across the board
# give it the protean ability in slot 1
# give it dragonforce as its hidden - check out Ability.rb
# let it learn sunsteel strike and dragon ascent by level up
# override its base asset to make it more angry
PokeModifier.add(:MAGIKARP)
            .stats(100, 100, 100 ,100, 100, 100)
            .type2(:GRASS)
            .ability(0, :PROTEAN)
            .ability(2, :DRAGONFORCE)
            .level_moves([[10, :SUNSTEELSTRIKE], [15, :DRAGONASCENT]])
            .asset_override(asset: "ExampleMod/Assets/madgikarp.png")