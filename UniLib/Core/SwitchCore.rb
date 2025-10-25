# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  def self.is_switch_on(id)
    ret = $unilib_switches[id]
    ret = $unilib_switch_conditions[id] ? $unilib_switch_conditions[id].call : false unless ret
    ret
  end

end

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
  "return UniLib.is_switch_on(id) if id.is_a? Symbol")

UniLib.insert_in_method(:Game_CommonEvent, :switchIsOn?, :HEAD,
  "return UniLib.is_switch_on(id) if id.is_a? Symbol")

UniLib.insert_in_method(:Interpreter, :command_111, "result = false",
  "if @parameters[1].is_a? Symbol
    result = UniLib.is_switch_on(@parameters[1]) == (@parameters[2] == 0)
  else", 1)

UniLib.insert_in_method(:Interpreter, :command_111, "result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))",
  "end")