# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Item"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  $map_debug = false
  MAP_EVENTS = {} unless UniLib.cached(UniLib::MAP)
  CACHED_MAPS = {}

end

module MapEvent

  include UniLib

end

class EncounterMod

  MODIFIERS = {} unless UniLib.cached(UniLib::MAP)

  attr_reader(:modifiers)

  def initialize(map_id)
    @map_id = map_id
    @modifiers = []
    @logging = false
  end

  def self.log_encounters(encounters)
    type = ["Land", "Cave", "Water", "Rock Smash", "Old Rod", "Good Rod", "Super Rod", "Headbutt", "Land Morning", "Land Day", "Land Night", "Bug Contest"]
    s = ""
    (0..11).each { |i|
      s += "#{type[i]} - "
      species_weight = {}
      species_levels = {}
      encounters[i] ? encounters[i].each { |species, weights| weights.each { |arr|
        species_weight[species] = (species_weight[species] ||= 0) + arr[0]
        (species_levels[species] ||= []).push(arr)
      } } : nil
      total_weight = species_weight.values.sum
      s += " Total weight: #{total_weight}\n"
      species_weight.each { |species, weight|
        s += "  #{species}: #{weight} (#{'%.2f' % (weight / (total_weight * 1.0) * 100)}%)\n"
        species_levels[species].each { |levels| s += "    Lv. #{levels[1]}-#{levels[2]}: #{levels[0]} (#{'%.2f' % (levels[0] / (total_weight * 1.0) * 100)}%)\n" }
      }
    }
    UniLib.dev_log(s)
  end

  def apply(encounters)
    @modifiers.each { |(target, species, operation, argument)|
      (target.is_a?(Array) ? target : [target]).each { |i|
        begin
          next unless encounters[i]
          case operation
          when :ADD then (encounters[i][species] ||= []).push(argument)
          when :REPLACE
            args = argument[0].is_a?(Array) ? argument : [argument]
            args.each { |arg| throw Exception.new("") if arg[2] < arg[1] }
            encounters[i][species] = args
          when :REMOVE then encounters[i].delete(species)
          else UniLib.dev_log("EncounterMod: attempted to execute unsupported operation :#{operation}")
          end
        rescue Exception => e
          UniLib.dev_log("EncounterMod: something went wrong with #{operation} modifier on#{species} #{ argument.nil? ? "" : " with argument #{argument}"} - #{e}")
        end
      }
    }
    encounters.each { |enc_list|

    }
    EncounterMod.log_encounters(encounters) if @logging
  end

end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method(:Cache_Game, :map_load, "end",
  "UniLib.obj_print(@cachedmaps[mapid]) if $map_debug
  if UniLib::MAP_EVENTS[mapid]
    unless UniLib::CACHED_MAPS[mapid]
      UniLib::CACHED_MAPS[mapid] = UniLib.deep_copy(@cachedmaps[mapid])
      UniLib::MAP_EVENTS[mapid].each { |event| event.call(UniLib::CACHED_MAPS[mapid]) }
    end
    return UniLib::CACHED_MAPS[mapid]
  end")

UniLib.insert_in_method(:PokemonEncounters, :__hr_setup, "]",
  "EncounterMod::MODIFIERS[mapID].apply(@enctypes) if EncounterMod::MODIFIERS[mapID]
  @enctypes", 1)