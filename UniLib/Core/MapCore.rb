# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Item"
UniLib.include "Asset"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  $map_debug = false

  $map_temp = nil

  unless UniLib.cached(UniLib::MAP)

    MAP_EVENTS = {}
    FORM_PROVIDERS = {}

  end

  CACHED_MAPS = {}

  NOT_LOST_CMD = 911

end

module MapEvent

  include UniLib

end

class EncounterMod

  include UniLib

  MODIFIERS = {} unless UniLib.cached(UniLib::MAP)
  CACHED_ENCOUNTERS = {} unless defined? CACHED_ENCOUNTERS
  MODIFIED = {}

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

  def apply(enc, density)
    CACHED_ENCOUNTERS[@map_id] = Marshal.load(Marshal.dump(enc)) unless CACHED_ENCOUNTERS[@map_id]
    unless MODIFIED[@map_id]
      encounters = (MODIFIED[@map_id] = Marshal.load(Marshal.dump(CACHED_ENCOUNTERS[@map_id])))
      @modifiers.each { |(target, arg2, arg3, arg4)|
        (target.is_a?(Array) ? target : [target]).each { |i|
          begin
            if i == :DENSITY
              density[arg2] = arg3
            else
              encounters[i] ||= {}
              case arg3
              when :ADD then (encounters[i][arg2] ||= []).push(arg4)
              when :REPLACE
                next unless encounters[i][arg2]
                args = arg4[0].is_a?(Array) ? arg4 : [arg4]
                args.each { |arg| throw Exception.new("") if arg[2] < arg[1] }
                encounters[i][arg2] = args
              when :REMOVE then encounters[i].delete(arg2)
              when :DECREASE then
                next unless encounters[i][arg2]
                enc = encounters[i][arg2]
                proportions = []
                total = enc.sum { |(weight, _, _)| proportions.push(weight); weight }
                target_amount = [total - arg4, 0].max
                proportions.map! { |i| i.to_f / total }
                new_total = enc.each_with_index.sum { |arr, i| arr[0] = (proportions[i] * target_amount).round.to_i }
                enc[0][0] += target_amount - new_total
              else UniLib.dev_log("EncounterMod: attempted to execute unsupported operation :#{arg3}")
              end
            end
          rescue Exception => e
            UniLib.dev_log("EncounterMod: something went wrong with #{arg3} modifier on #{arg2} #{ arg4.nil? ? "" : " with argument #{arg4}"} - #{e}")
          end
        }
      }
      EncounterMod.log_encounters(MODIFIED[@map_id]) if @logging
    end
    [MODIFIED[@map_id], density]
  end

end

class Interpreter

  # store current event in map temp variable
  def command_910
    $map_temp = $game_map.events[@event_id]
    return true
  end

  # battle result test (conditional branch)
  def command_911
    dec = $game_variables[Variables[:BattleResult]]
    result = @parameters.include?(dec)
    @branch[@list[@index].indent] = result
    if @branch[@list[@index].indent] == true
      @branch.delete(@list[@index].indent)
      return true
    end
    command_skip
  end

  def handle_custom
    case @list[@index].code
    when 910 then [command_910]
    when 911 then [command_911]
    else nil
    end
  end

end

class MonWrapper

  def formInit = "proc { $game_map && UniLib::FORM_PROVIDERS[:#{@mon}] && (f = UniLib::FORM_PROVIDERS[:#{@mon}][$game_map.map_id]) ? f : #{@formInit.is_a?(String) ? "#{@formInit}.call" : 0} }"

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
  "@enctypes, @density = EncounterMod::MODIFIERS[mapID].apply(@enctypes, @density) if EncounterMod::MODIFIERS[mapID]
  @enctypes", 1)

UniLib.insert_in_method_before(:Interpreter, :execute_command, "case @list[@index].code",
  "rval = handle_custom
  return rval[0] if rval")