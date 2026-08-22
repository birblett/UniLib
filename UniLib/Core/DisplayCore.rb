# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  DISPLAY_OVERWRITE = {}

  def self.crest? = UniLib.lib_loaded("Crest")

  def self.aaa? = UniLib.lib_loaded("Ability")

  def self.om? = UniLib.lib_loaded("PokemonOM")

  if Reborn

    BASE_BMP = LazyBitmap.new(UniLib.asset_path("Battle/base.png"))

    ICON_BITMAPS = [
      (1..4).map { |i| LazyBitmap.new(UniLib.asset_path("Battle/crest_#{i}.png")) },
      (1..4).map { |i| LazyBitmap.new(UniLib.asset_path("Battle/type_change_#{i}.png")) },
      (1..4).map { |i| LazyBitmap.new(UniLib.asset_path("Battle/pokebilities_#{i}.png")) },
      (1..4).map { |i| LazyBitmap.new(UniLib.asset_path("Battle/aaa_#{i}.png")) }
    ]

    def self.draw_battle_icons(bitmap, opp, doubles, type_change, crest, poke, multi)
      if doubles
        x, y = opp ? 236 : 42, 42
      else
        x, y = opp ? 236 : 42, 42
      end
      occupied = crest ? [0, 0, 0, 0] : [false, false, false, false]
      occupied = occupied[0] ? [0, 0, 1, 1] : [1, 1, 1, 1] if type_change
      if poke
        start, fin = crest ? 3 : 1, 4
        start += (5 - start) / 2 if type_change
        (start..fin).each { |i| occupied[i - 1] = 2 }
      end
      if multi
        start, fin = crest ? 3 : 1, 4
        start += (5 - start) / 2 if type_change
        start += (5 - start) / 2 if poke
        (start..fin).each { |i| occupied[i - 1] = 3 }
      end
      occupied.each_with_index { |slot, i| bitmap.blt(x, y, ICON_BITMAPS[slot][i].bmp, Rect.new(0, 0, 22, 22)) if slot }
      bitmap.blt(x, y, BASE_BMP.bmp, Rect.new(0, 0, 22, 22))
    end

  end

  def self.display_battle(bitmap, battler)
    doubles = battler.battle.doublebattle
    opp = battler.index & 1 == 1
    DISPLAY_OVERWRITE.each { |_, v| return if v.call(battler, bitmap, doubles, opp) }
    return unless UniLib.crest? or UniLib.aaa? or UniLib.om?
    mon = battler.effects[:Illusion] ? battler.effects[:Illusion] : battler
    type_change = false
    if UniLib.om?
      type_change = (UniLib::CAMO_POKEMON[key = [mon.species, mon.form]] == 2 || (UniLib::CAMO_POKEMON[key] == 1 and mon.item == :CATALYZER))
      type_change = UniLib.plate_type(mon) unless type_change
    end
    crest = UniLib.crest? && mon.crested
    poke = aaa_active = false
    if UniLib.aaa? and mon.ability.is_a?(AbilityContainer) and !mon.ability.suppressed?
      poke = UniLib.om? && UniLib.pokebilities_active(mon)
      aaa_active = (UniLib.aaa_active(mon.pokemon) || UniLib::AAA_POKEMON[key] == 1) && !mon.pokemon.getAbilityList.include?(mon.ability.abilities[0])
    end
    UniLib.draw_battle_icons(bitmap, opp, doubles, type_change, crest, poke, aaa_active) if type_change || crest || poke || aaa_active
  end

  def self.display_summary(mon, imagepos)
    return unless UniLib.crest? or UniLib.aaa? or UniLib.om?
    key = [mon.species, mon.form]
    active = []
    inactive = []
    if UniLib.crest?
      crest = UniLib::VALID_CRESTS[mon.item] && ItemModifier.has_event?(mon, :crest) ? "" : false
      crest = UniLib::CREST_MAP[key] ? "_empty" : false unless crest
      (crest == "" ? active : inactive).push(UniLib.asset_path("Summary/crest#{crest}"), UniLib.asset_path("Summary/base")) if crest
    end
    if UniLib.om?
      type_change = (UniLib::CAMO_POKEMON[key = [mon.species, mon.form]] == 2 || (UniLib::CAMO_POKEMON[key] == 1 && mon.item == :CATALYZER)) ? "" : false
      type_change = UniLib::CAMO_POKEMON[key] == 1 && mon.item != :CATALYZER ? "_empty" : false unless type_change
      unless type_change
        plate = UniLib.plate_type(mon)
        type_change = plate ? "" : "_empty" unless plate.nil?
      end
      (type_change == "" ? active : inactive).push(UniLib.asset_path("Summary/type_change#{type_change}"), UniLib.asset_path("Summary/base")) if type_change
      poke = UniLib.pokebilities_active(mon) ? "" : false
      poke = UniLib::POKEBILITIES_POKEMON[key] == 1 ? "_empty" : false unless poke
      (poke == "" ? active : inactive).push(UniLib.asset_path("Summary/pokebilities#{poke}"), UniLib.asset_path("Summary/base")) if poke
    end
    aaa_active = false
    if UniLib.om?
      aaa_active = UniLib.aaa_active(mon) ? "" : false unless aaa_active
      aaa_active = AAA_POKEMON[key] == 1 ? "_empty" : false unless aaa_active
    end
    (aaa_active == "" ? active : inactive).push(UniLib.asset_path("Summary/aaa#{aaa_active}"), UniLib.asset_path("Summary/base")) if aaa_active
    lpos = 86
    active.each_with_index { |i, idx| imagepos.push([i, (lpos = idx % 2 == 0 ? lpos + 18 : lpos), 330, 0, 0, 44, 16]) }
    inactive.each_with_index { |i, idx| imagepos.push([i, (lpos = idx % 2 == 0 ? lpos + 18 : lpos), 330, 0, 0, 44, 16]) }
  end

end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method_before(:PokemonDataBox, :refresh, "if @showexp", "UniLib.display_battle(self.bitmap, @battler)", 0, 10000) if Reborn

%w[One Two Three Four Five].each { UniLib.insert_in_method(:PokemonSummaryScene, "drawPage#{_1}".to_sym, "imagepos = []", "UniLib.display_summary(@pokemon, imagepos)", 0, 10000) } if Reborn