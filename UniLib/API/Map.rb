# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

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

  def self.add_overworld_item(map, x, y, name, item, switch, graphic = Reborn ? "itemball" : "Object ball", **kwargs)
    i = map.events.keys.max + 1
    event = RPG::Event.new(x, y)
    event.id = i
    event.name = name
    page = event.pages[0]
    page.graphic.character_name = graphic
    kwargs[:graphic].each { |k, v| page.graphic.instance_variable_set("@#{k}".to_sym, v) } if kwargs[:graphic]
    page.move_speed = 1
    page.move_frequency = 1
    page.list.insert(0, event_cmd(111, 0, [12, "Kernel.pbItemBall(:#{item}); $unilib_switches[:#{switch}] = true"]))
    page.list.insert(1, event_cmd(121, 1, [switch, switch, 0]))
    page.list.insert(2, event_cmd(0, 1, []))
    page.list.insert(3, event_cmd(412, 0, []))
    page = RPG::Event::Page.new
    page.condition.switch1_id = switch
    page.condition.switch1_valid = true
    event.pages.push(page)
    map.events[i] = event
  end

  def self.add_static_pkmn(map, x, y, name, pkmn, lvl, asset, switch, **kwargs)
    i = map.events.keys.max + 1
    event = static_pkmn(x, y, name, pkmn, lvl, asset, switch, **kwargs)
    event.id = i
    map.events[i] = event
  end

  def self.add_event(map, obj, x = nil, y = nil)
    i = map.events.keys.max + 1
    event = (obj.is_a?(EventBuilder) ? obj.event : obj).clone
    event.id = i
    event.x = x if x
    event.y = y if y
    map.events[i] = event
  end

  def self.static_pkmn(x, y, name, pkmn, lvl, asset, switch, **kwargs)
    event = RPG::Event.new(x, y)
    event.name = name
    page = event.pages[0]
    page.condition.switch1_id = switch
    page.condition.switch1_valid = true
    if kwargs[:switch2]
      page.condition.switch2_id = kwargs[:switch2]
      page.condition.switch2_valid = true
    end
    page = RPG::Event::Page.new
    page.condition.switch2_id = kwargs[:switch2] if kwargs[:switch2]
    page.graphic.character_name = asset
    page.graphic.direction = kwargs[:dir] ? kwargs[:dir] : 2
    page.move_type = kwargs[:move_type] ? kwargs[:move_type] : 0
    page.move_speed = kwargs[:move_speed] ? kwargs[:move_speed] : 3
    page.move_frequency = kwargs[:move_freq] ? kwargs[:move_freq] : 3
    page.move_route.list.insert(0, RPG::MoveCommand.new(25))
    page.step_anime = kwargs[:step_anime].nil? ? true : kwargs[:step_anime]
    page.direction_fix = kwargs[:fix_dir] ? true : false
    events = []
    events.push(event_cmd(250, 0, [RPG::AudioFile.new(kwargs[:sfx])])) if kwargs[:sfx] # sound effect
    events.push(event_cmd(101, 0, [kwargs[:txt]])) if kwargs[:txt] # text
    events.push(event_cmd(355, 0, [kwargs[:prescript]])) if kwargs[:prescript] # pre battle scripts
    form, wild = kwargs[:form] ? kwargs[:form] : 0, kwargs[:wild]
    events.push(event_cmd(122, 0, [545, 545, 0, 0, 102])) if wild
    events.push(event_cmd(355, 0, ["m = pbGenerateWildPokemon(:#{pkmn}, #{lvl}, #{form}); pbWildBattleObject(m)"]))
    events.push(event_cmd(122, 0, [545, 545, 0, 0, 0])) if wild
    events.push(event_cmd(*(kwargs[:win_event] ? kwargs[:win_event] : [111, 0, [1, Variables[:BattleResult], 0, 1, 0]]))) # if victory
    if kwargs[:should_remove] # removes event and sets a permanent switch
      events.push(event_cmd(116, 1, [1, Variables[:BattleResult], 0, 1, 0]))
      events.push(event_cmd(355, 1, ["$unilib_switches[:#{switch}] = true"]))
    end
    kwargs[:wincommands].each { |event| events.push(event) } if kwargs[:wincommands] # win events
    events.push(event_cmd(355, 1, [kwargs[:winscript]])) if kwargs[:winscript] # run win script
    events.push(event_cmd(101, 1, [kwargs[:wintxt]])) if kwargs[:wintxt] # display win text
    events.push(event_cmd(0, 1, [])) # dummy
    events.push(event_cmd(411, 0, [])) # else
    events.push(event_cmd(115, 1, [])) # stop event
    events.push(event_cmd(0, 1, [])) # dummy
    events.push(event_cmd(412, 0, [])) # end conditional
    page.list.prepend(*events)
    event.pages.prepend(page)
    event
  end

  def self.basic_npc(x, y, name, asset, dialogue, **kwargs)
    event = RPG::Event.new(x, y)
    event.name = name
    page = event.pages[0]
    page.condition.switch1_valid = false
    page.condition.switch2_valid = false
    page.condition.variable_valid = false
    if kwargs[:switch]
      page.condition.switch1_id = kwargs[:switch]
      page.condition.switch1_valid = true
    end
    if kwargs[:switch2]
      page.condition.switch2_id = kwargs[:switch2]
      page.condition.switch2_valid = true
    end
    if kwargs[:variable_id]
      page.condition.variable_id = kwargs[:variable_id]
      page.condition.variable_value = kwargs[:variable_value]
      page.condition.variable_valid = true
    end
    page.graphic.character_name = asset
    page.graphic.direction = kwargs[:dir] ? kwargs[:dir] : 2
    page.move_type = kwargs[:move_type] ? kwargs[:move_type] : 0
    page.move_speed = kwargs[:move_speed] ? kwargs[:move_speed] : 3
    page.move_frequency = kwargs[:move_freq] ? kwargs[:move_freq] : 3
    page.move_route.list.insert(0, RPG::MoveCommand.new(25))
    page.step_anime = kwargs[:step_anime].nil? ? true : kwargs[:step_anime]
    page.direction_fix = kwargs[:fix_dir] ? true : false
    events = []
    events.push(event_cmd(250, 0, [RPG::AudioFile.new(kwargs[:sfx])])) if kwargs[:sfx] # sound effect
    dialogue.each do |d|
      if d.is_a? Array
        events.push(event_cmd(101, 0, [d[0]]))
        (1..d.length).each { |i| events.push(event_cmd(401, 0, [d[i]])) }
      else
        events.push(event_cmd(101, 0, [d]))
      end
    end
    if kwargs[:script]
      events.push(event_cmd(0, 0, [])) # dummy
      events.push(event_cmd(355, 0, [kwargs[:script]]))
    end
    page.list.prepend(*events)
    event
  end

end

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

class EventBuilder

  attr_accessor(:event)

  def initialize(name, x = 0, y = 0)
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

  def add_page
    end_page if @page
    @page = @event.pages[@event.pages.length] = RPG::Event::Page.new
    @current_indent = 0
    self
  end

  def set_page(idx, overwrite = false)
    idx = [@event.pages.length, idx].min
    @event.pages[idx] = RPG::Event::Page.new if overwrite
    @page = @event.pages[idx]
    @current_indent = 0
    self
  end

  def set_switch_1(switch)
    return self unless @page
    @page.condition.switch1_id = switch
    @page.condition.switch1_valid = true
    self
  end

  def set_switch_2(switch)
    return self unless @page
    @page.condition.switch2_id = switch
    @page.condition.switch2_valid = true
    self
  end

  def set_variable(id, value)
    return self unless @page
    @page.condition.variable_id = id
    @page.condition.variable_value = value
    @page.condition.variable_valid = true
    self
  end

  def set_self_switch(char = nil)
    return self unless @page
    @page.instance_variable_set(:@self_switch_valid, true)
    @page.instance_variable_set(:@self_switch_ch, char) if %w[A B C D].include? char
    self
  end

  def set_graphic(base, redirect: nil, hue: 0, direction: 2, pattern: 0, opacity: 255, blend_type: 0)
    return self unless @page
    @page.graphic.character_name = base
    Assets.redirect(:BMP, base, redirect) if redirect
    @page.graphic.character_hue = hue
    @page.graphic.direction = direction
    @page.graphic.pattern = pattern
    @page.graphic.opacity = opacity
    @page.graphic.blend_type = blend_type
    self
  end

  def set_movement(move_type: 0, move_speed: 3, move_frequency: 3, walk_anime: true, step_anime: false, direction_fix: false, through: false, always_on_top: false)
    return self unless @page
    @page.move_type = move_type
    @page.move_speed = move_speed
    @page.move_frequency = move_frequency
    @page.walk_anime = walk_anime
    @page.step_anime = step_anime
    @page.direction_fix = direction_fix
    @page.through = through
    @page.always_on_top = always_on_top
    #@page.move_route.list.insert(0, RPG::MoveCommand.new(25))
    self
  end

  def set_trigger(trigger)
    return self unless @page
    @page.trigger = trigger
    self
  end

  def event_show_text(*texts)
    return self unless @page
    texts.each_with_index { |text, i| @page.list.push(RPG::EventCommand.new(i == 0 ? 101 : 401, @current_indent, [text])) }
    self
  end

  def event_play_se(se, volume = 100, pitch = 100)
    return self unless @page
    @page.list.push(RPG::EventCommand.new(250, @current_indent, [se, volume, pitch]))
    self
  end

  def event_run_scripts(*scripts)
    return self unless @page
    scripts.each_with_index { |script, i| @page.list.push(RPG::EventCommand.new(i == 0 ? 355 : 655, @current_indent, [script])) }
    self
  end

  def event_set_unilib_switch(switch, value, refresh = false)
    return self unless @page
    scripts = ["$unilib_switches[:#{switch}] = #{value}"]
    scripts.push("$game_map.need_refresh = true") if refresh
    scripts.each_with_index { |script, i| @page.list.push(RPG::EventCommand.new(i == 0 ? 355 : 655, @current_indent, [script])) }
    self
  end

  def event_store_temp
    return self unless @page
    @page.list.push(RPG::EventCommand.new(910, @current_indent, []))
    self
  end

  def event_erase
    return self unless @page
    @page.list.push(RPG::EventCommand.new(116, @current_indent, []))
    self
  end

  def event_refresh_map
    return self unless @page
    @page.list.push(RPG::EventCommand.new(355, @current_indent, ["$game_map.need_refresh = true"]))
    self
  end

  def event_control_self_switch(enable = true)
    return self unless @page
    @page.list.push(RPG::EventCommand.new(123, @current_indent, [@page.instance_variable_get(:@self_switch_ch), enable ? 0 : 1]))
    self
  end

  <<-DOC
  >> argument types
  >>   - [0, switch, 0/1]: switch is on (0) or off (1)
  >>   - [1, var1, val1, val2, 0]: var1 == (val2 if val1 is 0, else variable corresponding to val2)
  >>   - [1, var1, val1, val2, 1]: var1 >= (val2 if val1 is 0, else variable corresponding to val2)
  >>   - [1, var1, val1, val2, 2]: var1 <= (val2 if val1 is 0, else variable corresponding to val2)
  >>   - [1, var1, val1, val2, 3]: var1 > (val2 if val1 is 0, else variable corresponding to val2)
  >>   - [1, var1, val1, val2, 4]: var1 < (val2 if val1 is 0, else variable corresponding to val2)
  >>   - [1, var1, val1, val2, 5]: var1 != (val2 if val1 is 0, else variable corresponding to val2)
  >>   - [2, "A/B/C/D", 0/1]: self switch A/B/C/D is on (0) or off (1)
  >>   - [3, val]: timer in val seconds
  >>   - [12, script]: evaluates the result of the script
  DOC
  def event_if(args)
    return self unless @page
    @page.list.push(RPG::EventCommand.new(111, @current_indent, args))
    @current_indent += 1
    self
  end

  def event_else
    return self unless @page
    @page.list.push(RPG::EventCommand.new(0, @current_indent, []))
    @page.list.push(RPG::EventCommand.new(411, @current_indent - 1, []))
    self
  end

  def event_end_if
    return self unless @page
    @page.list.push(RPG::EventCommand.new(0, @current_indent, []))
    @current_indent -= 1
    @page.list.push(RPG::EventCommand.new(412, @current_indent, []))
    self
  end

  def event_prompt(*prompts)
    return self unless @page
    @page.list.push(RPG::EventCommand.new(102, @current_indent, [prompts, prompts.length]))
    @conditionals_left[@current_indent] = prompts.clone
    @index[@current_indent] = 0
    self
  end

  def event_prompt_choice
    return self unless @page and (cond = @conditionals_left[@current_indent]) and (idx = @index[@current_indent]) < cond.length
    @page.list.push(RPG::EventCommand.new(0, @current_indent, [])) unless idx == 0
    @page.list.push(RPG::EventCommand.new(402, @current_indent, [idx, cond[idx]]))
    @index[@current_indent] += 1
    @current_indent += 1
    self
  end

  def event_end_prompt(end_all = false)
    return self unless @page
    @page.list.push(RPG::EventCommand.new(0, @current_indent, []))
    @current_indent -= 1
    @page.list.push(RPG::EventCommand.new(404, @current_indent, [])) if end_all
    self
  end

  def event_next_prompt
    event_end_prompt.event_prompt_choice
  end

  def end_page
    return self unless @page
    @page.list.push(RPG::EventCommand.new(0, 0, []))
    @page = nil
    self
  end

  def event_exclaim
    return self unless @page
    event_store_temp.event_run_scripts("pbExclaim($map_temp)")
  end

  # (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
  def event_if_battle_result(*args)
    return self unless @page
    @page.list.push(RPG::EventCommand.new(911, @current_indent, args))
    @current_indent += 1
    self
  end

  def event_wild_battle(species, lvl, form = 0, item = nil)
    return self unless @page
    @page.list.push(RPG::EventCommand.new(122, @current_indent, [545, 545, 0, 0, 102]))
    @page.list.push(RPG::EventCommand.new(355, @current_indent, ["m = pbGenerateWildPokemon(:#{species}, #{lvl}, #{form});#{item.nil? ? "" : " m.item = :#{item};"} pbWildBattleObject(m)"]))
    @page.list.push(RPG::EventCommand.new(122, @current_indent, [545, 545, 0, 0, 0]))
    self
  end

end