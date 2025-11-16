# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

unless UniLib.lib_loaded(__FILE__)

  def unilib_read_switches(save = {})
    $unilib_switches = save[:UniLibSwitches] ? save[:UniLibSwitches] : {}
  end

  def unilib_write_switches(save)
    save[:UniLibSwitches] = $unilib_switches
  end

end

UniLib.add_load_event(:unilib_read_switches)
UniLib.add_save_event(:unilib_write_switches)
UniLib.add_new_file_event(:unilib_read_switches)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method(:Game_Event, :switchIsOn?, :HEAD,
  "return UniLib.switch_on?(id) if id.is_a? Symbol")

UniLib.insert_in_method(:Game_CommonEvent, :switchIsOn?, :HEAD,
  "return UniLib.switch_on(id) if id.is_a? Symbol")

UniLib.insert_in_method(:Game_Switches, :[], :HEAD, "tmp = switch_id")

UniLib.insert_in_method(:Game_Switches, :[], "switch_id = Switches[switch_id] if switch_id.is_a?(Symbol)",
  "return UniLib.switch_on?(tmp) if switch_id.nil? && $unilib_switches.key?(tmp)")

UniLib.insert_in_method(:Game_Switches, :[]=, :HEAD, "tmp = switch_id")

UniLib.insert_in_method(:Game_Switches, :[]=, "switch_id = Switches[switch_id] if switch_id.is_a?(Symbol)",
  "return ($unilib_switches[tmp] = value) if switch_id.nil? && tmp.is_a?(Symbol)")