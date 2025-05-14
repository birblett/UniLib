# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.7, __FILE__)

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
    i = map.events.size + 1
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
    i = map.events.size + 1
    event = static_pkmn(x, y, name, pkmn, lvl, asset, switch, **kwargs)
    event.id = i
    map.events[i] = event
  end

  def self.add_event(map, obj)
    i = map.events.size + 1
    event = obj.clone
    event.id = i
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
    page.step_anime = true
    page.direction_fix = kwargs[:fix_dir] ? true : false
    events = []
    events.push(event_cmd(250, 0, [RPG::AudioFile.new(kwargs[:sfx])])) if kwargs[:sfx] # sound effect
    events.push(event_cmd(101, 0, [kwargs[:txt]])) if kwargs[:txt] # text
    events.push(event_cmd(355, 0, [kwargs[:prescript]])) if kwargs[:prescript] # pre battle scripts
    form, wild = kwargs[:form] ? kwargs[:form] : 0, kwargs[:wild]
    events.push(event_cmd(122, 0, [545, 545, 0, 0, 102])) if wild
    events.push(event_cmd(355, 0, ["m = pbGenerateWildPokemon(:#{pkmn}, #{lvl}); m.form=#{form}; pbWildBattleObject(m)"]))
    events.push(event_cmd(122, 0, [545, 545, 0, 0, 0])) if wild
    events.push(event_cmd(111, 0, [kwargs[:wincon] ? kwargs[:wincon] : 1, 100, 0, kwargs[:comparator] ? kwargs[:comparator] : 1, 0])) # if victory
    if kwargs[:should_remove] # removes event and sets a permanent switch
      events.push(event_cmd(116, 1, [1, 100, 0, 1, 0]))
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
    event.pages.prepend(0, page)
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
    page.step_anime = true
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