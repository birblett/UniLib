# current config takes in the current mod's configurations as context
if UniLib.current_config("debug_toggle")

  # debug mode toggle in the options or unilib options menu
  # options array is zero-indexed, and the UniLib options can be compared to integers
  DEBUG_ENABLED = UniStringOption.new("Debug", "Debug mode toggle.", %w[Off On], proc { |value| $DEBUG = value == 1})

end
