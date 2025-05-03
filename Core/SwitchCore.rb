# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

unless UniLib.lib_loaded(__FILE__)

  def unilib_read_switches(save)
    $unilib_switches = save[:UniLibSwitches] ? save[:UniLibSwitches] : {}
  end

  def unilib_write_switches(save)
    save[:UniLibSwitches] = $unilib_switches
  end

end

UniLib.add_load_event(:unilib_read_switches)
UniLib.add_save_event(:unilib_write_switches)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method(:Game_Event, :switchIsOn?, :HEAD,
  "if id.is_a? Symbol
    b = $unilib_switch_conditions[id]
    return (!$unilib_switches[id].nil? || (b && b.call))
  end")

UniLib.insert_in_method(:Interpreter, :command_111, "result = false",
  "if @parameters[1].is_a? Symbol
    b = $unilib_switch_conditions[@parameters[1]]
    result = (!$unilib_switches[@parameters[1]].nil? || (!b || b.call))
  else")

UniLib.replace_in_method(:Interpreter, :command_111, "@branch[@list[@index].indent] = result",
  "end
  @branch[@list[@index].indent] = result")