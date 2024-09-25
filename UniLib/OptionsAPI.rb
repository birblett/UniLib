# ==================================================================================================================== #
# =================================================== DEPENDENCIES =================================================== #
# ==================================================================================================================== #

verify_version(0.3, File.basename(__FILE__).gsub!(".rb", ""))

# ==================================================================================================================== #
# ==================================================== PUBLIC API ==================================================== #
# ==================================================================================================================== #

<<-DOC
COMMON
@name - string name
@desc - string description
@on_update_proc - a proc that activates when the option is first loaded and whenever it is changed. useful for 
                  changing global properties, like $DEBUG, for instance.
>> a set of classes for creating options in the options menu and comparing them via ==. automatically serialized and
   deserialized.
DOC

<<-DOC
>> string options. when compared using OPTION == othervalue, compares the integer index of the option selected.
DOC
class UniStringOption < OptionBase

  <<-DOC
  @options - a string array specifying the available options. defaults to the first option.
  >> string options. when compared like OPTION == value, compares the integer index of the option selected.
  DOC
  def initialize(name, desc, options, on_update_proc=nil)
    super(name, desc, on_update_proc)
    @options = []
    @value = 0
    options.each { |option| @options.push(_INTL(option)) }
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
  @min - the minimum value
  @max - the maximum value
  @shift_increment - the amount by which the value is shifted when changing the option
  @default - the default value of the option, set to max normally
  >> string options. when compared like OPTION == value, compares the integer index of the option selected.
  DOC
  def initialize(name, desc, min, max, shift_increment=1, default=max, on_update_proc=nil)
    super(name, desc, on_update_proc)
    @min = min
    @max = max
    @value = default
    @increment = shift_increment
  end

end