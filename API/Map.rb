# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module MapEvent

  def self.add_map_event(mapid, func=nil, &block)
    MAP_EVENTS[mapid] = [] unless MAP_EVENTS[mapid]
    if func.nil? and block.nil?
      print "No function or block provided for event on map #{mapid}"
      exit
    end
    MAP_EVENTS[mapid].push(func.nil? ? block : func)
  end

  def self.set_debug(default=true)
    $map_debug = default
  end

  def self.add_item(map, x, y, name, item, switch, graphic = "Object ball")
    i = map.events.size + 1
    event = RPG::Event.new(x, y)
    event.instance_variable_set(:@id, i)
    event.instance_variable_set(:@name, name)
    page = event.pages[0]
    page.instance_variable_get(:@graphic).instance_variable_set(:@character_name, graphic)
    page.instance_variable_set(:@move_speed, 1)
    page.instance_variable_set(:@move_frequency, 1)
    page.list.insert(0, RPG::EventCommand.new(111, 0, [12, "Kernel.pbItemBall(:#{item}); $unilib_switches[:#{switch}] = true"]))
    page.list.insert(1, RPG::EventCommand.new(121, 1, [switch, switch, 0]))
    page.list.insert(2, RPG::EventCommand.new(0, 1, []))
    page.list.insert(3, RPG::EventCommand.new(412, 0, []))
    page = RPG::Event::Page.new
    page.condition.instance_variable_set(:@switch1_id, switch)
    page.condition.instance_variable_set(:@switch1_valid, true)
    event.pages.push(page)
    map.events[i] = event
  end

end