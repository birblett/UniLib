# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Item"
UniLib.include "Asset"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module MapEvent

  $map_debug = false
  $map_temp = nil

  unless UniLib.cached(UniLib::MAP)

    MAP_EVENTS = {}
    MAP_EVENT_MODIFIERS = {}
    CACHED_MAPS = {}

  end

  def self.apply_map_modifiers(cachedmaps, mapid)
    unless CACHED_MAPS[mapid]
      if MAP_EVENTS[mapid] || MAP_EVENT_MODIFIERS[mapid]
        map = (CACHED_MAPS[mapid] = UniLib.deep_copy(cachedmaps[mapid]))
        MAP_EVENTS[mapid].each { |event|
          if event.is_a?(RPG::Event) || event.is_a?(EventBuilder)
            MapEvent.copy_event_to_map(map, event)
          else
            event.call(map)
          end
        } if MAP_EVENTS[mapid]
        if MAP_EVENT_MODIFIERS[mapid]
          MAP_EVENT_MODIFIERS[mapid][0].each { |idx, fn| fn.call(EventBuilder.new(map, map.events[idx])) }
          by = MAP_EVENT_MODIFIERS[mapid][1]
          map.events.each { |_, event|
            apply = by[event.name]
            apply.call(map, EventBuilder.new(event, use_old: true)) if apply
          }
        end
      else
        CACHED_MAPS[mapid] = nil
      end
    end
    return CACHED_MAPS[mapid]
  end

end

class EventBuilder

  EVENT_INSNS = {
    Done: 0,
    ShowText: 101,
    ShowTextContinued: 401,
    ShowChoices: 102,
    When: 402,
    WhenCancel: 403,
    BranchEndChoices: 404,
    InputNumber: 103,
    ChangeTextOptions: 104,
    ButtonInputProcessing: 105,
    Wait: 106,
    Comment: 108,
    CommentContinued: 408,
    ConditionalBranch: 111,
    BranchEndConditional: 412,
    Else: 411,
    Loop: 112,
    RepeatAbove: 413,
    BreakLoop: 113,
    ExitEventProcessing: 115,
    EraseEvent: 116,
    CallCommonEvent: 117,
    Label: 118,
    JumpToLabel: 119,
    ControlSwitch: 121, # Handled specially
    ControlSwitches: 121,
    ControlVariable: 122, # Handled specially
    ControlVariables: 122,
    ControlSelfSwitch: 123,
    ControlTimer: 124,
    TimerOff: 124, # Handled specially
    TimerOn: 124, # Handled specially
    ChangeGold: 125,
    ChangeItems: 126,
    ChangeWeapons: 127,
    ChangeArmor: 128,
    ChangePartyMember: 129,
    ChangeWindowskin: 131,
    ChangeBattleBackgroundMusic: 132,
    ChangeBattleEndME: 133,
    ChangeSaveAccess: 134,
    ChangeMenuAccess: 135,
    ChangeEncounter: 136,
    TransferPlayer: 201,
    SetEventLocation: 202,
    ScrollMap: 203,
    ChangeMapSettings: 204,
    ChangeFogColorTone: 205,
    ChangeFogOpacity: 206,
    ShowAnimation: 207,
    ChangeTransparentFlag: 208,
    SetMoveRoute: 209,
    SetMoveRouteComment: 509,
    WaitForMovement: 210,
    PrepareForTransition: 221,
    ExecuteTransition: 222,
    ChangeScreenColorTone: 223,
    ScreenFlash: 224,
    ScreenShake: 225,
    ShowPicture: 231,
    MovePicture: 232,
    RotatePicture: 233,
    ChangePictureColorTone: 234,
    ErasePicture: 235,
    SetWeatherEffects: 236,
    PlayBackgroundMusic: 241,
    FadeOutBackgroundMusic: 242,
    PlayBackgroundSound: 245,
    FadeOutBackgroundSound: 246,
    MemorizeBackgroundSound: 247,
    RestoreBackgroundSound: 248,
    PlayMusicEvent: 249,
    PlaySoundEvent: 250,
    StopSoundEvent: 251,
    HealParty: 314,
    IfWin: 601,
    IfEscape: 602,
    IfLose: 603,
    BranchEndBattle: 604,
    CallMenuScreen: 351,
    CallSaveScreen: 352,
    GameOver: 353,
    ReturnToTitleScreen: 354,
    Script: 355,
    ScriptContinued: 655,
    StoreID: 82120456800,
    TestBattle: 82120456801
  }

  MOVE_INSNS = {
    Done: 0,
    MoveDown: 1,
    MoveLeft: 2,
    MoveRight: 3,
    MoveUp: 4,
    MoveDownLeft: 5,
    MoveDownRight: 6,
    MoveUpLeft: 7,
    MoveUpRight: 8,
    MoveRandomly: 9,
    MoveTowardPlayer: 10,
    MoveAwayFromPlayer: 11,
    MoveForward: 12,
    MoveBackward: 13,
    Jump: 14,
    Wait: 15,
    FaceDown: 16,
    FaceLeft: 17,
    FaceRight: 18,
    FaceUp: 19,
    TurnRight: 20,
    TurnLeft: 21,
    TurnAround: 22,
    TurnRandomly: 23,
    FaceRandomly: 24,
    FaceTowardsPlayer: 25,
    FaceAwayFromPlayer: 26,
    SetSwitch: 27,
    UnsetSwitch: 28,
    MoveSpeed: 29,
    MoveFrequency: 30,
    AnimateWalking: 31,
    DontAnimateWalking: 32,
    AnimateSteps: 33,
    DontAnimateSteps: 34,
    FixDirection: 35,
    DontFixDirection: 36,
    SetIntangible: 37,
    SetTangible: 38,
    SetAlwaysForeground: 39,
    UnsetAlwaysForeground: 40,
    SetCharacter: 41,
    SetOpacity: 42,
    BlendType: 43,
    PlaySound: 44,
    Script: 45
  }

  CONDITIONAL_BRANCH_TYPES = {
    Switch: 0,
    Variable: 1,
    SelfSwitch: 2,
    Timer: 3,
    Actor: 4,
    Enemy: 5,
    Character: 6,
    Money: 7,
    Gold: 7, # Alias
    Item: 8,
    Weapon: 9,
    Armor: 10,
    Button: 11,
    Script: 12,
  }

  CONDITIONAL_MODES = {
    Equals: 0,
    :== => 0,
    GreaterOrEquals: 1,
    :>= => 1,
    LessOrEquals: 2,
    :<= => 2,
    Greater: 3,
    :> => 3,
    Less: 4,
    :< => 4,
    NotEquals: 5, # No equivalent for !=
  }

  SET_VAR_NAMES = {
    Constant: 0,
    Variable: 1,
    RandomBetween: 2,
    Item: 3,
    Actor: 4,
    Enemy: 5,
    Character: 6,
    Other: 7,
  }

  SET_CHARACTER_VAR_NAMES = {
    x: 0,
    y: 1,
    direction: 2,
    screen_x: 3,
    screen_y: 4,
    terrain_tag: 5,
  }

  SET_OTHER_VAR_NAMES = {
    map_id: 0,
    party_size: 1,
    gold: 2,
    steps: 3,
    play_time: 4,
    timer: 5,
    save_count: 6,
  }

  SET_MODES = {
    Set: 0,
    :[]= => 0,
    Add: 1,
    :+ => 1,
    Subtract: 2,
    :- => 2,
    Multiply: 3,
    :* => 3,
    Divide: 4,
    :/ => 4,
    Modulus: 5,
    :% => 5,
  }

  FACING_DIRECTIONS = {
    Down: 2,
    Left: 4,
    Right: 6,
    Up: 8,
  }

  APPOINTMENT_METHODS = {
    Constant: 0,
    Variable: 1,
    ExchangeWithEvent: 2
  }

  SPECIAL_EVENT_IDS = {
    Player: -1,
    This: 0
  }

  SUBTRACT_MODE = {
    Add: 0,
    :+ => 0,
    Subtract: 1,
    :- => 1,
  }

  MORE_OR_LESS = {
    OrMore: 0,
    :>= => 0,
    OrLess: 1,
    :<= => 1,
  }

  TRUTH = {
    true => 0,
    false => 1
  }

  DENY = {
    true => 1,
    false => 0
  }

  EVENT_TRIGGER_TYPES = {
    Interact: 0,
    PlayerTouch: 1,
    EventTouch: 2,
    Autorun: 3,
    RunInParallel: 4
  }

  EVENT_MOVE_TYPES = {
    Fixed: 0,
    Random: 1,
    Approach: 2,
    Custom: 3
  }

  BLEND_TYPES = {
    Normal: 0,
    Additive: 1,
    Subtractive: 2
  }

  MESSAGE_POSITIONS = {
    Top: 0,
    Middle: 1,
    Botton: 2
  }

  MAP_SETTINGS = {
    Panorama: 0,
    Fog: 1,
    BattleBack: 2
  }

  PICTURE_ORIGINS = {
    TopLeft: 0,
    Center: 1
  }

  WEATHER = {
    None: 0,
    Rain: 1,
    Storm: 2,
    Snow: 3
  }

  BLOCK_TYPES = {
    When: :BranchEndChoices,
    WhenCancel: :BranchEndChoices,
    ConditionalBranch: :BranchEndConditional,
    IfWin: :BranchEndBattle,
    IfEscape: :BranchEndBattle,
    IfLose: :BranchEndBattle,
    Loop: :RepeatAbove
  }

  def map_value(params, idx, mapper)
    param = params[idx]
    ret = param
    if param.is_a?(Symbol) || [true,false].include?(param)
      params[idx] = mapper[param] unless mapper[param].nil?
    elsif param.is_a?(Numeric)
      ret = mapper.invert[param]
    end
    ret
  end

  def map_switch(params, idx)
    return map_value(params, idx, Switches)
  end

  def map_variable(params, idx)
    return map_value(params, idx, Variables)
  end

  def handle_complex_parameters(sym, params)
    case sym
    when :SetSwitch, :UnsetSwitch
      map_switch(params, 0)
    when :SetCharacter
      map_value(params, 2, FACING_DIRECTIONS)
    when :ConditionalBranch
      case map_value(params, 0, CONDITIONAL_BRANCH_TYPES)
      when :Switch
        map_switch(params, 1)
        map_value(params, 2, TRUTH)
      when :SelfSwitch
        map_value(params, 2, TRUTH)
      when :Variable
        map_variable(params, 1)
        if map_value(params, 2, APPOINTMENT_METHODS) == :Variable
          map_variable(params, 3)
        end
        map_value(params, 4, CONDITIONAL_MODES)
      when :Character
        map_value(params, 1, SPECIAL_EVENT_IDS)
        map_value(params, 2, FACING_DIRECTIONS)
      when :Money, :Gold
        map_value(params, 2, MORE_OR_LESS)
      end
    when :InputNumber
      map_variable(params, 0)
    when :ChangeTextOptions
      map_value(params, 0, MESSAGE_POSITIONS)
      map_value(params, 1, TRUTH)
    when :ShowAnimation
      map_value(params, 0, SPECIAL_EVENT_IDS)
    when :SetEventLocation
      map_value(params, 0, SPECIAL_EVENT_IDS)
      case map_value(params, 1, APPOINTMENT_METHODS)
      when :Variable
        map_variable(params, 2)
        map_variable(params, 3)
      when :Constant
      else
        map_value(params, 2, SPECIAL_EVENT_IDS)
      end
      map_value(params, 4, FACING_DIRECTIONS)
    when :SetMoveRoute
      map_value(params, 0, SPECIAL_EVENT_IDS)
      params[1] = parse_move_route(*params[1][1..], repeat: params[1][0]) if !params[1].nil? && params[1].is_a?(Array)
    when :ControlSwitch, :ControlSwitches
      params.unshift(params[0]) if sym == :ControlSwitch
      map_switch(params, 0)
      map_switch(params, 1)
      map_value(params, 2, TRUTH)
    when :ControlVariable, :ControlVariables
      params.unshift(params[0]) if sym == :ControlVariable

      map_variable(params, 0)
      map_variable(params, 1)
      map_value(params, 2, SET_MODES)
      case map_value(params, 3, SET_VAR_NAMES)
      when :Variable
        map_variable(params, 4)
      when :Character
        map_value(params, 4, SPECIAL_EVENT_IDS)
        map_value(params, 5, SET_CHARACTER_VAR_NAMES)
      when :Other
        map_value(params, 4, SET_OTHER_VAR_NAMES)
      end
    when :ControlSelfSwitch
      map_value(params, 1, TRUTH)
    when :ChangeGold
      if params.size == 2 && params[1].is_a?(Numeric)
        amount = params[1]
        params[1] = amount.abs
        params.unshift(amount.negative? ? :- : :+)
      end

      map_value(params, 0, SUBTRACT_MODE)
      if map_value(params, 1, APPOINTMENT_METHODS) == :Variable
        map_variable(params, 2)
      end
    when :ChangeMapSettings
      if map_value(params, 0, MAP_SETTINGS) == :Fog
        map_value(params, 4, BLEND_TYPES)
      end
    when :TransferPlayer
      if map_value(params, 0, APPOINTMENT_METHODS) == :Variable
        map_variable(params, 1)
        map_variable(params, 2)
        map_variable(params, 3)
      end
      map_value(params, 4, FACING_DIRECTIONS)
      map_value(params, 5, TRUTH)
    when :SetEventLocation
      if map_value(params, 1, APPOINTMENT_METHODS) == :Variable
        map_variable(params, 2)
        map_variable(params, 3)
      end
    when :ScrollMap
      map_value(params, 0, FACING_DIRECTIONS)
    when :ShowPicture, :MovePicture
      map_value(params, 2, PICTURE_ORIGINS)
      if map_value(params, 3, APPOINTMENT_METHODS) == :Variable
        map_variable(params, 4)
        map_variable(params, 5)
      end
      map_value(params, 9, BLEND_TYPES)
    when :SetWeatherEffects
      map_value(params, 0, WEATHER)
    when :ChangeTransparentFlag
      map_value(params, 0, TRUTH)
    when :ChangeSaveAccess, :ChangeMenuAccess, :ChangeEncounter
      map_value(params, 0, DENY)
    when :ControlTimer, :TimerOn, :TimerOff
      params.unshift(true) if sym == :TimerOn && params.size == 1
      params.unshift(false) if sym == :TimerOff && params.size == 0
      map_value(params, 0, TRUTH)
    when :PlaySoundEvent, :PlayMusicEvent, :PlayBackgroundMusic, :PlayBackgroundSound, :ChangeBattleBackgroundMusic, :ChangeBattleEndME, :PlaySound
      if params[0].is_a?(String)
        audio = params[0]
        volume = 100
        volume = params[1] if params[1].is_a?(Numeric)
        pitch = 100
        pitch = params[2] if params[2].is_a?(Numeric)
        params[0] = RPG::AudioFile.new(audio, volume, pitch)
        params.delete_at(2) if params[2].is_a?(Numeric)
        params.delete_at(1) if params[1].is_a?(Numeric)
      end
    end
    params
  end

  def parse_move_command(sym, *params)
    RPG::MoveCommand.new(MOVE_INSNS[sym], handle_complex_parameters(sym, params))
  end

  def parse_move_route(*insns, repeat: false)
    builtInsns = []
    for insn in insns
      sym = nil
      params = []
      if insn.is_a?(Symbol)
        sym = insn
      elsif insn.is_a?(Array)
        sym = insn[0]
        params = insn[1..]
      end

      if sym
        builtInsns.push(parse_move_command(sym, *params))
      else
        raise sprintf('Invalid move instruction %s',insn)
      end
    end

    route = RPG::MoveRoute.new
    route.repeat = repeat
    route.list = builtInsns
    return route
  end

  def parse_event_command(indent, sym, *params)
    RPG::EventCommand.new(EVENT_INSNS[sym], indent, handle_complex_parameters(sym, params))
  end

  def parse_event_commands(*insns, baseIndent: 0)
    builtInsns = []
    currIndent = baseIndent
    blockstack = []
    insns.each { |insn|
      sym = nil
      params = []
      if insn.is_a?(Symbol)
        sym = insn
      elsif insn.is_a?(Array)
        sym = insn[0]
        params = insn[1..]
      elsif insn.is_a?(RPG::EventCommand)
        sym = EVENT_INSNS.invert[insn.code]
        params = insn.parameters
      end

      if sym
        if sym == :Else
          builtInsns.push(parse_event_command(currIndent, :Done))
          currIndent -= 1
        end

        builtInsns.push(parse_event_command(currIndent, sym, *params))

        if sym == :Done && !blockstack.empty?
          currIndent -= 1
          builtInsns.push(parse_event_command(currIndent, blockstack.pop))
        end

        if BLOCK_TYPES[sym]
          currIndent += 1
          blockstack.push(BLOCK_TYPES[sym])
        elsif sym == :Else
          currIndent += 1
        end
      else
        raise sprintf('Invalid event instruction %s', insn)
      end
    }

    if baseIndent != builtInsns[-1].indent
      raise sprintf('Indents did not line up: expected to end on indent %d, ended on %d', baseIndent, builtInsns[-1].indent)
    end
    builtInsns
  end

end

class EventFunctions

  EVENT_MAX = [0] unless UniLib.cached(UniLib::MAP)

  def self.event_max=(other)
    EVENT_MAX[0] = other
  end

  def self.event_max
    EVENT_MAX[0]
  end

  def self.generate_named(sym, &block)
    EventFunctions.define_singleton_method(sym, block)
    "EventFunctions.#{sym}"
  end

  def self.generate_anonymous(&block)
    i = EVENT_MAX[0]
    sym = "anonymous_function_#{i}".to_sym
    EventFunctions.define_singleton_method(sym, block)
    EVENT_MAX[0] = i + 1
    "EventFunctions.#{sym}"
  end

end

class EncounterMod

  include UniLib

  MODIFIERS = {} unless UniLib.cached(UniLib::MAP)
  CACHED_ENCOUNTERS = {} unless defined? CACHED_ENCOUNTERS
  MODIFIED = {}
  FORM_PROVIDERS = {}

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

  # use commands indexed from 82120456800 (base64 -> decimal of UniLib)

  # store current event in map temp variable
  def command_82120456800
    $map_temp = $game_map.events[@event_id]
    return true
  end

  # battle result test (conditional branch)
  def command_82120456801
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
    when 82120456800 then [command_82120456800]
    when 82120456801 then [command_82120456801]
    else nil
    end
  end

end

class MonWrapper

  def formInit = "proc { $game_map && EncounterMod::FORM_PROVIDERS[:#{@mon}] && (f = EncounterMod::FORM_PROVIDERS[:#{@mon}][$game_map.map_id]) ? f : #{@formInit.is_a?(String) ? "#{@formInit}.call" : 0} }"

end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method(:Cache_Game, :map_load, "end",
  "m = MapEvent.apply_map_modifiers(@cachedmaps, mapid)
  UniLib.obj_print(m ? m : @cachedmaps[mapid]) if $map_debug
  return m if m")

UniLib.insert_in_method(:PokemonEncounters, Reborn ? :__hr_setup : :setup, :TAIL,
  "@enctypes, @density = EncounterMod::MODIFIERS[mapID].apply(@enctypes, @density) if EncounterMod::MODIFIERS[mapID]")

UniLib.insert_in_method_before(:Interpreter, :execute_command, "case @list[@index].code",
  "rval = handle_custom
  return rval[0] if rval")