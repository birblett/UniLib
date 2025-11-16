# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module UniLib

  $unilib_switches = {}
  $unilib_switches_inverted = {}
  $unilib_switch_conditions = {}

  def self.set_switch(id, value=true)
    $unilib_switches[id] = value
  end

  def self.inverted_switch(id)
    $unilib_switches_inverted[id] = true
    id
  end

  def self.register_inverted(*ids)
    ids.each { |id| $unilib_switches_inverted[id] = true }
  end

  def self.get_switch_or_default(id, default)
    $unilib_switches[id].nil? ? default : $unilib_switches[id]
  end

  def self.set_switch_condition(id, proc = nil, &block)
    $unilib_switch_conditions[id] = block ? block : proc
  end

  def self.switch_on?(id)
    ret = $unilib_switches[id]
    ret = $unilib_switch_conditions[id] ? $unilib_switch_conditions[id].call : false unless ret
    ret = !ret if $unilib_switches_inverted[id]
    ret
  end

end