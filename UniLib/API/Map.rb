# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

class EncounterMod

  <<-DOC
  >> encounter mod targets, can also be passed as an array of targets
  DOC
  LAND = 0
  CAVE = 1
  WATER = 2
  ROCKSMASH = 3
  OLDROD = 4
  GOODROD = 5
  SUPERROD = 6
  HEADBUTT = 7
  LANDMORNING = 8
  LANDDAY = 9
  LANDNIGHT = 10
  BUGCONTEST = 11
  DENSITY = :DENSITY

  ALL_LAND = [LAND, LANDMORNING, LANDDAY, LANDNIGHT]
  ALL_TYPES = [LAND, CAVE, WATER, ROCKSMASH, OLDROD, GOODROD, SUPERROD, HEADBUTT, LANDMORNING, LANDDAY, LANDNIGHT, BUGCONTEST]

  <<-DOC
  >> supported operations:
  >>   - :ADD       - adds to an existing encounter, otherwise creates a new entry. argument must be of [weight, minlevel, maxlevel]
  >>   - :REPLACE   - overwrites existing encounters of the species. argument can either be [weight, minlevel, maxlevel] or array of them
  >>   - :REMOVE    - removes species from target encounter pool. no argument.
  >>   - :DECREASE  - decreases the weight of particular species. if a species has multiple entries then the decrease is split
                      proportionally and rounded. argument must be an integer weight.
  DOC
  def self.add_new(map_id, target, species, operation, argument = nil)
    return EncounterMod.new(map_id) if UniLib.cached(UniLib::MAP)
    target = [target] unless target.is_a? Array
    m = MODIFIERS[map_id] ||= EncounterMod.new(map_id)
    target.each { |t| m.modifiers.push([t, species, operation, argument]) }
    m
  end

  def self.add(map_id)
    return EncounterMod.new(map_id) if UniLib.cached(UniLib::MAP)
    MODIFIERS[map_id] ||= EncounterMod.new(map_id)
  end

  def add(target, species, operation, argument = nil) = EncounterMod.add_new(@map_id, target, species, operation, argument)

  def add_form_override(species, form)
    return EncounterMod.new(@map_id) if UniLib.cached(UniLib::MAP)
    (FORM_PROVIDERS[species] ||= {})[@map_id] = form
    self
  end

  def enable_logging
    @logging = true
    self
  end

end

module MapEvent

  def self.set_debug(default=true)
    $map_debug = default
  end

  def self.event_cmd(code, indent, args)
    RPG::EventCommand.new(code, indent, args)
  end

  def self.add_map_event(mapid, func=nil, &block)
    MAP_EVENTS[mapid] = [] unless MAP_EVENTS[mapid]
    if func.nil? and block.nil?
      print "No function or block provided for event on map #{mapid}"
      exit
    end
    MAP_EVENTS[mapid].push(func.nil? ? block : func)
  end

  def self.add_event(mapid, event)
    (MAP_EVENTS[mapid] ||= []).push(event) unless UniLib.cached(UniLib::MAP)
  end

  def self.add_events(mapid, *events)
    (MAP_EVENTS[mapid] ||= []).push(*events) unless UniLib.cached(UniLib::MAP)
  end

  def self.add_builder(mapid, name, x = 0, y = 0)
    unless UniLib.cached(UniLib::MAP)
      event = EventBuilder.new(name, x, y)
      self.add_event(mapid, event)
      return event
    end
    EventBuilder.new("", 0, 0, pass: true)
  end

  def self.add_item(mapid, item, switch, graphic = Reborn ? "itemball" : "Object ball", name: "Item", x: 0, y: 0, redirect: nil, hue: 0)
    unless UniLib.cached(UniLib::MAP)
      event = EventBuilder.new(name, x, y)
      self.add_event(mapid, event)
      event.add_page(switch_1: UniLib.inverted_switch(switch))
           .set_graphic(graphic, redirect: redirect, hue: hue) {
             script "Kernel.pbItemBall(:#{item})"
             switches[switch] = true
           }
      return event
    end
    EventBuilder.new("", 0, 0, pass: true)
  end

  def self.splice(base, from, base_x, base_y, base_layer, splice_x, splice_y, splice_x_final, splice_y_final, splice_layer)
  end

end

class EventBuilder

  attr_accessor(:event)

  def initialize(name, x = 0, y = 0, pass: false)
    if pass
      @pass = true
      return
    end
    if name.is_a?(String)
      @id = 0
      @event = RPG::Event.new(x, y)
      @event.name = name
      @page = nil
    else
      @page = (@event = name.clone).pages[0]
    end
    @conditionals_left = {}
    @index = {}
  end

  def set_name(name)
    return self if @pass
    end_page if @page
    @event.name = name
    self
  end

  def set_coords(x, y)
    return self if @pass
    end_page if @page
    @event.x, @event.y = x, y
    self
  end

  TRIGGER_INTERACT = 0
  TRIGGER_TOUCH = 1
  TRIGGER_EVENT_TOUCH = 2
  TRIGGER_AUTORUN = 3
  TRIGGER_PARALLEL = 4

  def add_page(switch_1: nil, switch_2: nil, variable: nil, self_switch: nil, trigger: nil, &block)
    return self if @pass
    end_page if @page
    set_page(@event.pages.length, switch_1: switch_1, switch_2: switch_2, variable: variable, self_switch: self_switch, trigger: trigger, &block)
  end

  def set_page(idx, overwrite: false, switch_1: nil, switch_2: nil, variable: nil, self_switch: nil, trigger: nil, &block)
    return self if @pass
    if idx >= @event.pages.length
      idx = @event.pages.length
      overwrite = true
    end
    @event.pages[idx] = RPG::Event::Page.new if overwrite
    @page = @event.pages[idx]
    @current_indent = 0
    if switch_1
      @page.condition.switch1_id = switch_1
      @page.condition.switch1_valid = true
    end
    if switch_2
      @page.condition.switch2_id = switch_2
      @page.condition.switch2_valid = true
    end
    if variable and variable.is_a? Hash
      @page.condition.variable_id = variable[:id]
      @page.condition.variable_value = variable[:value]
      @page.condition.variable_valid = true
    end
    if self_switch and %w[A B C D].include? self_switch
      @page.instance_variable_set(:@self_switch_valid, true)
      @page.instance_variable_set(:@self_switch_ch, self_switch)
    end
    if trigger
      @page.trigger = trigger
    end
    if block_given?
      @page.list.push(*parse_event_commands(*EventBuilder.parse(&block)))
      end_page
    end
    self
  end

  def end_page
    return self if @pass
    return self unless @page
    @page.list.push(RPG::EventCommand.new(0, 0, []))
    @page = nil
    self
  end

  def set_graphic(base = nil, redirect: nil, hue: 0, direction: 2, pattern: 0, opacity: 255, blend_type: 0, &block)
    return self if @pass
    return self unless @page
    @page.graphic.character_name = base if base
    Assets.redirect(:BMP, base, redirect) if base and redirect
    @page.graphic.character_hue = hue
    @page.graphic.direction = direction
    @page.graphic.pattern = pattern
    @page.graphic.opacity = opacity
    @page.graphic.blend_type = blend_type
    if block_given?
      @page.list.push(*parse_event_commands(*EventBuilder.parse(&block)))
      end_page
    end
    self
  end

  def set_movement(move_type: 0, move_speed: 3, move_frequency: 3, walk_anime: true, step_anime: false, direction_fix: false, through: false, always_on_top: false, &block)
    return self if @pass
    return self unless @page
    @page.move_type = move_type
    @page.move_speed = move_speed
    @page.move_frequency = move_frequency
    @page.walk_anime = walk_anime
    @page.step_anime = step_anime
    @page.direction_fix = direction_fix
    @page.through = through
    @page.always_on_top = always_on_top
    if block_given?
      @page.list.push(*parse_event_commands(*EventBuilder.parse(&block)))
      end_page
    end
    self
  end

  def copy
    return self if @pass
    end_page
    UniLib.deep_copy(self)
  end

  def copy_to(map, name, x, y, parameter_mappings: nil)
    return self if @pass
    end_page
    ev = UniLib.deep_copy(self)
    ev.event.pages.each { |page|
      page.list.each { |command|
        command.parameters.each_with_index { |param, idx|
          command.parameters[idx] = parameter_mappings[param] ? parameter_mappings[param] : param
        }
      }
    } if parameter_mappings.is_a? Hash
    ev.set_name(name)
    ev.set_coords(x, y)
    MapEvent.add_event(map, ev)
    ev
  end

  def print_s
    UniLib.obj_print(self)
    self
  end

  def self.parse(params = [], &block)
    list = params.clone
    list.push *Contexts::OrphanedExecutionContext.create(&block).compile
    return list
  end

  module Contexts
    module DSLLike
      def self.included(othermod)
        othermod.define_singleton_method(:create) { |&block|
          inst = self.new
          inst.instance_exec(&block)
          next inst
        }
      end
    end

    class ExecutionContext
      include DSLLike

      def initialize
        @insns = []
      end

      def appoint(isvar)
        isvar ? :Variable : :Constant
      end

      ### ========================
      ###         COMMANDS
      ### ========================

      def script(script)
        parts = script.lines
        commands = parts.map { |text| [:ScriptContinued, text.lstrip.chomp] }
        commands = [[:Script, ""]] if commands == []
        commands[0][0] = :Script
        @insns.push *commands
      end

      def text(*parts)
        commands = parts.map { |text| [:ShowTextContinued, text] }
        commands[0][0] = :ShowText
        @insns.push *commands
      end

      def comment(*parts)
        commands = parts.map { |text| [:CommentContinued, text] }
        commands[0][0] = :Comment
        @insns.push *commands
      end

      def input_number(variable, digits:); @insns << [:InputNumber, unwrap(variable), digits]; end
      def change_text_options(position:, window:); @insns << [:ChangeTextOptions, position, window]; end
      def button_input_processing(variable); @insns << [:ButtonInputProcessing, unwrap(variable)]; end
      def wait(time); @insns << [:Wait, time]; end
      def wait_for_move_completion; @insns << :WaitForMovement; end
      def exit_event_processing; @insns << :ExitEventProcessing; end
      def erase_event; @insns << :EraseEvent; end
      def call_common_event(id); @insns << [:CallCommonEvent, id]; end
      def label(name); @insns << [:Label, name]; end
      def jump_label(name); @insns << [:JumpToLabel, name]; end

      def battle_bgm(param,volume=nil,pitch=nil); @insns << [:ChangeBattleBackgroundMusic, pbResolveAudioFile(param,volume,pitch)]; end
      def battle_me(param,volume=nil,pitch=nil); @insns << [:ChangeBattleEndME, pbResolveAudioFile(param,volume,pitch)]; end
      def play_bgm(param,volume=nil,pitch=nil); @insns << [:PlayBackgroundMusic, pbResolveAudioFile(param,volume,pitch)]; end
      def play_bgs(param,volume=nil,pitch=nil); @insns << [:PlayBackgroundSound, pbResolveAudioFile(param,volume,pitch)]; end
      def play_me(param,volume=nil,pitch=nil); @insns << [:PlayMusicEvent, pbResolveAudioFile(param,volume,pitch)]; end
      def play_se(param,volume=nil,pitch=nil); @insns << [:PlaySoundEvent, pbResolveAudioFile(param,volume,pitch)]; end

      def stop_se; @insns << :StopSoundEvent; end

      def fade_out_bgm(seconds:); @insns << [:FadeOutBackgroundMusic, seconds]; end

      def fade_out_bgs(seconds:); @insns << [:FadeOutBackgroundSound, seconds]; end

      def change_tone(red, green, blue, gray: 0, frames:); @insns << [:ChangeScreenColorTone, Tone.new(red, green, blue, gray), frames]; end

      def change_fog_tone(red, green, blue, gray: 0, frames:); @insns << [:ChangeFogColorTone, Tone.new(red, green, blue, gray), frames]; end

      def change_fog_opacity(opacity:, frames:); @insns << [:ChangeFogOpacity, opacity, frames]; end

      def change_picture_tone(number:, red:, green:, blue:, gray: 0, frames:); @insns << [:ChangePictureColorTone, number, Tone.new(red, green, blue, gray), frames]; end

      def screen_flash(red, green, blue, alpha: 0, frames:); @insns << [:ScreenFlash, Color.new(red, green, blue, alpha), frames]; end

      def screen_shake(power:, speed:, frames:); @insns << [:ScreenShake, power, speed, frames]; end

      def transfer_player(map:, x:, y:, direction:, fade:)
        isvar = any_variable?(map, x, y)
        @insns << [:TransferPlayer, appoint(isvar), unwrap(map), unwrap(x), unwrap(y), direction, fade]
      end

      def set_event_location(character, x:, y:, direction:)
        isvar = any_variable?(x, y)
        @insns << [:SetEventLocation, unwrap(character), appoint(isvar), unwrap(x), unwrap(y), direction]
      end

      def swap_event_locations(character, target:, direction:); @insns << [:SetEventLocation, unwrap(character), :ExchangeWithEvent, unwrap(target), direction]; end

      def branch(on, *args, &block)
        case on
        when EventBuilder::Wrappers::Switch
          @insns << [:ConditionalBranch, :Switch, unwrap(on), args.empty? ? true : args[0]]
        when EventBuilder::Wrappers::SelfSwitch
          @insns << [:ConditionalBranch, :SelfSwitch, unwrap(on), args.empty? ? true : args[0]]
        when EventBuilder::Wrappers::Variable
          operation = args[0]
          state = args[1]
          isvar = any_variable?(state)
          @insns << [:ConditionalBranch, :Variable, unwrap(on), appoint(isvar), unwrap(state), operation]
        when EventBuilder::Wrappers::GoldValue
          @insns << [:ConditionalBranch, :Gold, args[1], args[0]]
        when String
          @insns << [:ConditionalBranch, :Script, on]
        when EventBuilder::Wrappers::EventProxy
          @insns << [:ConditionalBranch, :Character, unwrap(on), args[0]]
        when Numeric
          @insns << [:ConditionalBranch, :Button, on]
        when Symbol
          @insns << [:ConditionalBranch, :Script, EventFunctions.generate_named(on, &args[0])]
        when Proc
          @insns << [:ConditionalBranch, :Script, EventFunctions.generate_anonymous(&on)]
        end

        context = BranchExecutionContext.create(&block)
        @insns << context
        context
      end

      def loop(&block)
        @insns << :Loop
        @insns << LoopExecutionContext.create(&block)
      end

      def show_choices(text=nil, &block)
        @insns << [:ShowText, text] if text
        @insns << ChoiceContext.create(&block)
      end

      def wild_battle(species, level, form = 0, item: nil, can_escape: true, can_lose: false, post_creation: nil, &block)
        variables[545] = 102
        script_anonymous {
          m = pbGenerateWildPokemon(species, level, form)
          m.item = item if item
          post_creation.call(m) if post_creation.is_a? Proc
          pbWildBattleObject(m, Variables[:BattleResult], can_escape, can_lose)
        }
        variables[545] = 0
        @insns << BattleContext.create(&block)
      end

      def set_move_route(character, &block)
        @insns << [:SetMoveRoute, unwrap(character), MoveRouteContext.create(&block).compile]
        EventBuilder::Wrappers::MoveRouteWaiter.new(self)
      end

      def control_variables(start, done, operator = :[]=, *args); @insns << [:ControlVariables, unwrap(start), unwrap(done), operator, *args]; end
      def control_variable(variable, operator = :[]=, *args); control_variables(variable, variable, operator, *args); end
      def control_switches(start, done, value); @insns << [:ControlSwitches, unwrap(start), unwrap(done), value]; end
      def control_switch(switch, value); control_switches(switch, switch, value); end
      def control_self_switch(chr, value); @insns << [:ControlSelfSwitch, chr, value]; end

      def control_self_switch_other(map, id, char, value); @insns << [:Script, "$game_self_switches[[#{map}, #{id}, \"#{char}\"]] = #{value}"]; end

      def change_gold(value, sign: 1)
        isvar = any_variable?(value)
        if !isvar
          sign = value
          value = value.abs
        end

        @insns << [:ChangeGold, sign.negative? ? :- : :+, appoint(isvar), unwrap(value)]
      end

      def scroll_map(direction:, distance:, speed:); @insns << [:ScrollMap, direction, distance, speed]; end
      def change_windowskin(name); @insns << [:ChangeWindowskin, name]; end
      def show_animation(character, animation); @insns << [:ShowAnimation, unwrap(character), animation]; end
      def heal_party(party = 0); @insns << [:HealParty, party]; end

      def change_panorama(graphic:, hue: 0); @insns << [:ChangeMapSettings, :Panorama, graphic, hue]; end
      def change_fog(graphic:, hue: 0, opacity: 0, blending:, zoom:, sx: 0, sy: 0); @insns << [:ChangeMapSettings, :Fog, graphic, hue, opacity, blending, zoom, sx, sy]; end
      def change_battleback(graphic:); @insns << [:ChangeMapSettings, :BattleBack, graphic]; end

      def show_picture(number:, graphic:, origin:, x:, y:, zoom_x:, zoom_y:, opacity: 255, blending:)
        isvar = any_variable?(x, y)
        @insns << [:ShowPicture, number, graphic, origin, appoint(isvar), x, y, zoom_x, zoom_y, opacity, blending]
      end

      def move_picture(number:, frames:, origin:, x:, y:, zoom_x:, zoom_y:, opacity: 255, blending:)
        isvar = any_variable?(x, y)
        @insns << [:MovePicture, number, frames, origin, appoint(isvar), x, y, zoom_x, zoom_y, opacity, blending]
      end

      def rotate_picture(number:, speed:); @insns << [:RotatePicture, number, speed]; end
      def erase_picture(number:); @insns << [:ErasePicture, number]; end
      def weather_effect(weather:, power:, frames:); @insns << [:SetWeatherEffects, weather, power, frames]; end
      def set_transparent_flag(flag); @insns << [:ChangeTransparentFlag, flag]; end
      def disable_save_access(flag); @insns << [:ChangeSaveAccess, flag]; end
      def disable_menu_access(flag); @insns << [:ChangeMenuAccess, flag]; end
      def disable_encounters(flag); @insns << [:ChangeEncounter, flag]; end
      def prepare_for_transition; @insns << :PrepareForTransition; end
      def transition(graphic:); @insns << [:ExecuteTransition, graphic]; end
      def call_menu_screen; @insns << :CallMenuScreen; end
      def call_save_screen; @insns << :CallSaveScreen; end
      def game_over; @insns << :GameOver; end
      def title_screen; @insns << :ReturnToTitleScreen; end
      def memorize_bgm_bgs; @insns << :MemorizeBackgroundSound; end
      def restore_bgm_bgs; @insns << :RestoreBackgroundSound; end
      def timer_on; @insns << [:ControlTimer, true]; end
      def timer_off; @insns << [:ControlTimer, false]; end

      def script_named(name_sym, &block); @insns << [:Script, EventFunctions.generate_named(name_sym, &block)]; end

      def script_anonymous(&block); @insns << [:Script, EventFunctions.generate_anonymous(&block)]; end

      def refresh_map; @insns << [:Script, "$game_map.need_refresh = true"]; end

      def exclaim
        @insns << [:StoreID]
        script("pbExclaim($map_temp)")
      end

      ### ============================
      ###         END COMMANDS
      ### ============================

      def compile_end(list)
        list << :Done
      end

      def compile
        list = []
        for insn in @insns
          if insn.is_a?(Array) || insn.is_a?(Symbol)
            list << insn
          elsif insn.respond_to?("compile")
            list.push *insn.compile
          end
        end

        compile_end(list)

        list
      end
    end

    class BranchExecutionContext < ExecutionContext
      include DSLLike

      ### ========================
      ###         COMMANDS
      ### ========================
      def else(&block); @else = ExecutionContext.create(&block); end
      ### ============================
      ###         END COMMANDS
      ### ============================

      def compile_end(list)
        if @else
          list << :Else
          list.push *@else.compile
        else
          super
        end
      end
    end

    class LoopExecutionContext < ExecutionContext
      include DSLLike
      def break_loop; @insns << :BreakLoop; end

    end

    class OrphanedExecutionContext < ExecutionContext
      include DSLLike

      def compile_end(list)
        # NO-OP
      end
    end

    class ChoiceContext
      include DSLLike

      def initialize
        @choices = []
        @contexts = []
        @cancel = nil
        @cancelcode = nil
      end

      ### ========================
      ###         COMMANDS
      ### ========================

      def choice(name, &block)
        @choices << name
        @contexts << ExecutionContext.create(&block)
      end

      def when_cancel(value = nil, &block)
        if value
          @cancel = value
        elsif block_given?
          @cancelcode = ExecutionContext.create(&block)
        end
      end

      def default_choice(name, &block)
        choice(name, &block)
        when_cancel(name)
      end

      ### ============================
      ###         END COMMANDS
      ### ============================

      def compile
        list = []
        cancelmode = 0

        if @cancelcode
          cancelmode = 4 # Branch
        elsif @cancel.is_a?(Numeric)
          cancelmode = @cancel
        elsif @cancel.is_a?(String)
          cancelmode = (@choices.index(@cancel) || -1) + 1
        end

        list << [:ShowChoices, @choices, cancelmode]
        @choices.each_with_index { |choice, i|
          context = @contexts[i]
          list << [:When, i, choice]
          list.push *context.compile
        }

        if @cancelcode
          list << :WhenCancel
          list.push *@cancelcode.compile
        end

        list
      end
    end

    class BattleContext
      include DSLLike

      def initialize
        @result_mappings = {}
      end

      ### ========================
      ###         COMMANDS
      ### ========================

      def result(*args, &block)
        @result_mappings[args] = BranchExecutionContext.create(&block)
      end

      def win(&block)
        result(win, &block) if block_given?
        1
      end

      def loss(&block)
        result(loss, &block) if block_given?
        2
      end

      def escaped(&block)
        result(escaped, &block) if block_given?
        3
      end

      def caught(&block)
        result(caught, &block) if block_given?
        4
      end

      def draw(&block)
        result(draw, &block) if block_given?
        5
      end

      ### ============================
      ###         END COMMANDS
      ### ============================

      def compile
        contexts = []
        @result_mappings.each { |args, context|
          contexts << [:ConditionalBranch, :Script, "#{args}.include?($game_variables[:BattleResult])"]
          contexts.push *context.compile
        }
        contexts
      end

    end

    class MoveRouteContext
      include DSLLike

      def initialize
        @repeat = false
        @skippable = false
        @insns = []
      end

      ### ========================
      ###         COMMANDS
      ### ========================

      def mark_as_repeat; @repeat = true; end

      def mark_as_skippable; @skippable = true; end


      def move_down; @insns << :MoveDown; end
      def move_left; @insns << :MoveLeft; end
      def move_right; @insns << :MoveRight; end
      def move_up; @insns << :MoveUp; end
      def move_down_left; @insns << :MoveDownLeft; end
      def move_down_right; @insns << :MoveDownRight; end
      def move_up_left; @insns << :MoveUpLeft; end
      def move_up_right; @insns << :MoveUpRight; end
      def move_random; @insns << :MoveRandomly; end
      def move_toward_player; @insns << :MoveTowardPlayer; end
      def move_away_from_player; @insns << :MoveAwayFromPlayer; end
      def move_forward; @insns << :MoveForward; end
      def move_backward; @insns << :MoveBackward; end
      def jump_to(x:, y:); @insns << [:Jump, x, y]; end
      def wait(frames); @insns << [:Wait, frames]; end
      def face_down; @insns << :FaceDown; end
      def face_left; @insns << :FaceLeft; end
      def face_right; @insns << :FaceRight; end
      def face_up; @insns << :FaceUp; end
      def turn_right; @insns << :TurnRight; end
      def turn_left; @insns << :TurnLeft; end
      def turn_around; @insns << :TurnAround; end
      def turn_randomly; @insns << :TurnRandomly; end
      def face_randomly; @insns << :FaceRandomly; end
      def face_toward_player; @insns << :FaceTowardsPlayer; end
      def face_away_from_player; @insns << :FaceAwayFromPlayer; end

      def set_switch(switch, state:); @insns << [state ? :SetSwitch : :UnsetSwitch, unwrap(switch)]; end
      def change_speed(speed); @insns << [:MoveSpeed, speed]; end
      def change_frequency(freq); @insns << [:MoveFrequency, freq]; end

      def animate_walking(state=true); @insns << (state ? :AnimateWalking : :DontAnimateWalking); end
      def animate_steps(state=true); @insns << (state ? :AnimateSteps : :DontAnimateSteps); end
      def lock_direction(state=true); @insns << (state ? :FixDirection : :DontFixDirection); end
      def set_intangible(state=true); @insns << (state ? :SetIntangible : :SetTangible); end
      def set_always_foreground(state=true); @insns << (state ? :SetAlwaysForeground : :UnsetAlwaysForeground); end
      def set_character(name, hue: 0, direction: :Down, pattern: 0); @insns << [:SetCharacter, name, hue, direction, pattern]; end
      def remove_graphic; set_character(""); end
      def set_opacity(opacity); @insns << [:SetOpacity, opacity]; end
      def set_blend_type(blend); @insns << [:BlendType, blend]; end

      def play_se(param,volume=nil,pitch=nil); @insns << [:PlaySound, pbResolveAudioFile(param,volume,pitch)]; end
      def script(script); @insns << [:Script, script]; end

      def script_named(name_sym, &block)
        EventFunctions.define_singleton_method(name_sym, block) if block_given?
        @insns << [:Script, "EventFunctions.#{name_sym}"]
      end

      def refresh_map; @insns << [:Script, "$game_map.need_refresh = true"]; end

      def script_anonymous(&block)
        i = EventFunctions.event_max
        sym = "anonymous_function_#{i}".to_sym
        EventFunctions.define_singleton_method(sym, block)
        @insns << [:Script, "EventFunctions.#{sym}"]
        EventFunctions.event_max = i + 1
      end

      def exclaim
        @insns << [:StoreID]
        script("pbExclaim($map_temp)")
      end

      ### ============================
      ###         END COMMANDS
      ### ============================

      def compile_end(list)
        list << :Done
      end

      def compile
        list = []
        for insn in @insns
          if insn.is_a?(Array) || insn.is_a?(Symbol)
            list.push(insn)
          elsif insn.respond_to?("compile")
            list.push(insn.compile)
          end
        end

        compile_end(list)

        route = InjectionHelper.parse_move_route(*list, repeat: @repeat)
        route.skippable = @skippable

        route
      end
    end

    ### ==========================================
    ###         Syntactic Sugar goes below
    ### ==========================================

    module DSLLike
      def unwrap(holder)
        return holder.event if holder.is_a?(EventBuilder::Wrappers::EventProxy)
        return holder.key if holder.is_a?(EventBuilder::Wrappers::HolderProxy)
        holder
      end

      def any_variable?(*holders)
        holders.any? { |it| it.is_a?(EventBuilder::Wrappers::HolderProxy) }
      end

      def variables; EventBuilder::Wrappers::Variables.new(self); end
      def switches; EventBuilder::Wrappers::Switches.new(self); end
      def events; EventBuilder::Wrappers::EventSourceProxy.new(self); end
      def self_switch; EventBuilder::Wrappers::OwnSelfSwitches.new(self); end

      def map_id; EventBuilder::Wrappers::GlobalValue.new(:map_id); end
      def party_size; EventBuilder::Wrappers::GlobalValue.new(:party_size); end
      def steps; EventBuilder::Wrappers::GlobalValue.new(:steps); end
      def play_time; EventBuilder::Wrappers::GlobalValue.new(:play_time); end
      def timer; EventBuilder::Wrappers::GlobalValue.new(:timer); end
      def save_count; EventBuilder::Wrappers::GlobalValue.new(:save_count); end

      def player; EventBuilder::Wrappers::PlayerEventProxy.new(self); end
      def this; EventBuilder::Wrappers::OwnEventProxy.new(self); end
    end
  end

  module Wrappers

    class HolderProxy
      attr_reader :key

      def initialize(key)
        @key = key
      end
    end

    class EventHolderProxy < HolderProxy
      attr_reader :event

      def initialize(event, key)
        @event = event
        @key = key
      end
    end

    ### End proxies

    class Variables
      attr_reader :dsl

      def initialize(dsl)
        @dsl = dsl
      end

      def [](idx)
        return Variable.new(idx)
      end

      def operate(idx, operator, value)
        if value.is_a?(Variable)
          dsl.control_variable(idx, operator, :Variable, value.key)
        elsif value.is_a?(Range)
          dsl.control_variable(idx, operator, :RandomBetween, value.begin, value.end)
        elsif value.is_a?(CharacterValue)
          dsl.control_variable(idx, operator, :Character, value.event, value.key)
        elsif value.is_a?(GlobalValue)
          dsl.control_variable(idx, operator, :Other, value.key)
        elsif value.is_a?(Numeric)
          dsl.control_variable(idx, operator, :Constant, value)
        end
      end

      def []=(idx, value)
        operator = :[]=
        operator, value = value if value.is_a?(Array)
        operate(idx, operator, value)
      end
    end

    class Switches
      attr_reader :dsl

      def initialize(dsl)
        @dsl = dsl
      end

      def [](idx)
        Switch.new(idx)
      end

      def []=(idx, value)
        dsl.control_switch(idx, value)
      end
    end

    class SelfSwitches
      attr_reader :event
      attr_reader :dsl

      def initialize(event, dsl)
        @event = event
        @dsl = dsl
      end

      def [](idx)
        SelfSwitch.new(event, idx)
      end
    end

    class OwnSelfSwitches < SelfSwitches
      def initialize(dsl)
        super(:This, dsl)
      end

      def []=(idx, value)
        dsl.control_self_switch(idx, value)
      end
    end

    class EventProxy
      attr_reader :event
      attr_reader :dsl

      def initialize(dsl, event)
        @dsl = dsl
        @event = event
      end

      def self_switch; SelfSwitches.new(event, dsl); end

      def x; CharacterValue.new(event, :x); end
      def y; CharacterValue.new(event, :y); end
      def direction; CharacterValue.new(event, :direction); end
      def screen_x; CharacterValue.new(event, :screen_x); end
      def screen_y; CharacterValue.new(event, :screen_y); end
      def terrain_tag; CharacterValue.new(event, :terrain_tag); end

      def set_event_location(x:, y:, direction:); dsl.set_event_location(self, x: x, y: y, direction: direction); end
      def swap_event_locations(target:, direction:); dsl.swap_event_locations(self, target: target, direction: direction); end
      def set_move_route(&block); dsl.set_move_route(self, &block); end
      def show_animation(animation); dsl.show_animation(self, animation); end
    end

    class OwnEventProxy < EventProxy
      def initialize(dsl)
        super(dsl, :This)
      end

      def self_switch; OwnSelfSwitches.new(dsl); end
    end

    class PlayerEventProxy < EventProxy
      def initialize(dsl)
        super(dsl, :Player)
      end

      def self_switch; OwnSelfSwitches.new(dsl); end

      def gold; GoldValue.new(:gold); end

      def gold=(operation)
        sign, value = operation
        dsl.change_gold(value, sign: sign)
      end
    end

    class EventSourceProxy
      attr_reader :dsl

      def initialize(dsl)
        @dsl = dsl
      end

      def [](idx)
        EventProxy.new(dsl, idx)
      end
    end

    class MoveRouteWaiter
      attr_reader :dsl

      def initialize(dsl)
        @dsl = dsl
      end

      def wait
        dsl.wait_for_move_completion
      end
    end

    class GlobalValue < HolderProxy; end
    class CharacterValue < EventHolderProxy; end
    class Variable < HolderProxy

      def +(value); [:+, value]; end

      def -(value); [:-, value]; end

      def *(value); [:*, value]; end

      def /(value); [:/, value]; end

      def %(value); [:%, value]; end

    end

    class Switch < HolderProxy; end

    class SelfSwitch < EventHolderProxy; end

    class GoldValue < GlobalValue
      def +(value); [1, value]; end
      def -(value); [-1, value]; end
    end
  end

end
