# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  def self.crest? = UniLib.lib_loaded("Crest")

  def self.multibility? = UniLib.lib_loaded("Multibility")

  def self.om? = UniLib.lib_loaded("PokemonOM")

  if Reborn

    BASE_BMP = AnimatedBitmap.new(UniLib.asset_path("Battle/base.png"))

    ICON_BITMAPS = [
      (1..4).map { |i| AnimatedBitmap.new(UniLib.asset_path("Battle/crest_#{i}.png")) },
      (1..4).map { |i| AnimatedBitmap.new(UniLib.asset_path("Battle/camo_#{i}.png")) },
      (1..4).map { |i| AnimatedBitmap.new(UniLib.asset_path("Battle/multibility_#{i}.png")) }
    ]

    def self.draw_icons(bitmap, opp, doubles, camo, crest, multi)
      if doubles
        x, y = opp ? 236 : 42, 42
      else
        x, y = opp ? 236 : 42, 42
      end
      occupied = crest ? [0, 0, 0, 0] : [false, false, false, false]
      occupied = occupied[0] ? [0, 0, 1, 1] : [1, 1, 1, 1] if camo
      if multi
        start, fin = crest ? 3 : 1, 4
        start += (5 - start) / 2 if camo
        (start..fin).each { |i| occupied[i - 1] = 2 }
      end
      occupied.each_with_index { |slot, i| bitmap.blt(x, y, ICON_BITMAPS[slot][i].bitmap, Rect.new(0, 0, 22, 22)) if slot }
      bitmap.blt(x, y, BASE_BMP.bitmap, Rect.new(0, 0, 22, 22))
    end

  end

end

class PokemonDataBox

  def display_crest
    return unless UniLib.crest? or UniLib.multibility? or UniLib.om?
    mon = @battler.effects[:Illusion] ? @battler.effects[:Illusion] : @battler
    camo = UniLib.om? && (UniLib::CAMO_POKEMON[key = [mon.species, mon.form]] == 2 || (UniLib::CAMO_POKEMON[key] == 1 and mon.item == :CATALYZER))
    crest = UniLib.crest? && mon.crested
    multi = UniLib.crest? && mon.ability.is_a?(AbilityContainer) && mon.ability.multiple?
    UniLib.draw_icons(self.bitmap, @battler.index & 1 == 1, @battler.battle.doublebattle, camo, crest, multi) if camo || crest || multi
  end

end unless UniLib.lib_loaded(__FILE__)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method(:PokemonDataBox, :refresh, "pbShowStatsBoosts if loopstop == false", "display_crest", 0, 10000) if Reborn