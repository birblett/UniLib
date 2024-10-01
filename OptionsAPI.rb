# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.4, File.basename(__FILE__).gsub!(".rb", ""))

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
COMMON
@param name - string name
@param desc - string description
@param on_update_proc - a proc that activates when the option is first loaded and whenever it is changed. useful for changing global 
                        properties, like $DEBUG, for instance.
>> a set of classes for creating options in the options menu and comparing them via ==. automatically serialized and
   deserialized.
DOC

<<-DOC
>> string options. when compared using OPTION == othervalue, compares the integer index of the option selected.
DOC
class UniStringOption < OptionBase

  <<-DOC
  @param options - a string array specifying the available options. defaults to the first option.
  >> string options. when compared like OPTION == value, compares the integer index of the option selected.
  DOC
  def initialize(name, desc, options, on_update_proc=nil, default=0)
    super(name, desc, on_update_proc)
    @options = []
    @value = default
    options.each { |option| @options.push(_INTL(option)) }
    inst = self
    @option = EnumOption.new(_INTL(@name) ,@options, proc { inst.value }, proc do |value|
      inst.value = value
      inst.update
    end, @desc)
  end

  <<-DOC
  >> returns the current selected option as a string
  DOC
  def get_as_string
    @options[@value]
  end

end

<<-DOC
>> number options, as a range. when compared with ==, compares the current numeric value selected.
DOC
class UniNumberOption < OptionBase

  <<-DOC
  @param min - the minimum value
  @param max - the maximum value
  @param shift_increment - the amount by which the value is shifted when changing the option
  @param default - the default value of the option, set to max normally
  >> string options. when compared like OPTION == value, compares the integer index of the option selected.
  DOC
  def initialize(name, desc, min, max, shift_increment=1, default=min, on_update_proc=nil)
    super(name, desc, on_update_proc)
    @min = min
    @max = max
    @value = default - min
    @increment = shift_increment
    inst = self
    @option = IncrementNumberOption.new(_INTL(@name), _INTL("Type %d"), @min, @max, proc { inst.value }, proc do |value|
      inst.value = value
      inst.update
    end, @increment, @desc)
  end

end

<<-DOC
COMMON - commands
@param id - a string id associated with the command.
@param text - the displayed text of the command.
@param executes - a proc or function, called when the command is selected.
@param predicate - a proc or function returning a boolean value which determines if this should show up in the option menu or not.
DOC

<<-DOC
@param executes @param predicate - takes the scene context as an argument
adds a command to the pause menu below the Options command, or below the UniLib command if enabled
DOC
def add_pause_command(id, text, executes, predicate=nil)
  UNILIB_PAUSE_COMMANDS[id] = [text, executes, predicate]
end

<<-DOC
@param executes @param predicate - takes the selected pokemon as an argument
adds a command to the menu when selecting a pokemon in the party. appears at the bottom, above the cancel command.
DOC
def add_party_command(id, text, executes, predicate=nil)
  UNILIB_PARTY_COMMANDS[id] = [text, executes, predicate]
end

<<-DOC
@param executes @param predicate - takes the selected pokemon as argument 1, and whether it is held or not as argument 2
adds a command to the menu when selecting a pokemon in the box. appears at the bottom, below either the cancel or debug command.
DOC
def add_box_command(id, text, executes, predicate=nil)
  UNILIB_BOX_COMMANDS[id] = [text, executes, predicate]
end