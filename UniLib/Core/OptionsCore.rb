# ==================================================================================================================== #
# =================================================== DEPENDENCIES =================================================== #
# ==================================================================================================================== #

verify_version(0.3, File.basename(__FILE__).gsub!(".rb", ""))

# ==================================================================================================================== #
# ================================================== INTERNAL/CORE =================================================== #
# ==================================================================================================================== #

CUSTOM_OPTIONS = []
OLD_OPTIONS = []
$options_init = false

class OptionBase

  attr_accessor(:name)
  attr_accessor(:value)

  def initialize(name, desc, on_update_proc=nil)
    @name = name
    @desc = desc
    @update = on_update_proc
    CUSTOM_OPTIONS.push(self) unless CUSTOM_OPTIONS.include?(self)
  end

  def update
    @update.call(@value) unless @update.nil?
  end

  def get_option
    nil
  end

  def ==(other)
    (other.is_a?(OptionBase) ? @name == other.name : @value == other)
  end

  def !=(other)
    (other.is_a?(OptionBase) ? @name != other.name : @value != other)
  end

  def >(other)
    (other.is_a?(OptionBase) ? @value > other.value : @value > other)
  end

  def <(other)
    (other.is_a?(OptionBase) ? @value < other.value  : @value < other)
  end

  def >=(other)
    (other.is_a?(OptionBase) ? @value >= other.value : @value >= other)
  end

  def <=(other)
    (other.is_a?(OptionBase) ? @value <= other.value  : @value <= other)
  end

  def marshal_dump
    [@name, @value]
  end

  def marshal_load(data)
    @name = data[0]
    @value = data[1]
  end

end

class IncrementNumberOption < NumberOption

  def initialize(name, format, min, max, getter, setter, increment, description="")
    super(name, format, min, max, getter, setter, description)
    @increment = increment
  end

  def next(current)
    index=current + @optstart
    index += @increment
    index > @optend ? @optstart : index
  end

  def prev(current)
    index=current + @optstart
    index -= @increment
    index < @optstart ? @optend : index
  end

end

class UniStringOption < OptionBase

  def get_option
    inst = self
    EnumOption.new(_INTL(@name) ,@options, proc { inst.value }, proc do |value|
      inst.value = value
      inst.update
    end, @desc)
  end

end

class UniNumberOption < OptionBase

  def get_option
    inst = self
    IncrementNumberOption.new(_INTL(@name), _INTL("Type %d"), @min, @max, proc { inst.value }, proc do |value|
      inst.value = value
      inst.update
    end, @increment, @desc)
  end

end

# ==================================================================================================================== #
# ====================================================== EVENTS ====================================================== #
# ==================================================================================================================== #

def read_option_data
  unless $options_init
    $options_init = true
    options = unilib_load_data("options", [], false)
    options.each do |option|
      i = CUSTOM_OPTIONS.index(option)
      if i
        CUSTOM_OPTIONS[i].value = option.value
        CUSTOM_OPTIONS[i].update
      else
        OLD_OPTIONS.push(option)
      end
    end
  end
end

def write_option_data
  unilib_save_data("options", CUSTOM_OPTIONS + OLD_OPTIONS, false)
end

add_play_event(:read_option_data)
add_save_event(:write_option_data)

# ==================================================================================================================== #
# ====================================================== PATCH ======================================================= #
# ==================================================================================================================== #

insert_in_method_before(:PokemonOptionScene, :pbStartScene, "for i in 0...OptionList.length", proc do
  CUSTOM_OPTIONS.each do |option|
    OptionList.push(option.get_option) unless option.get_option.nil? or OptionList.any? { |opt| opt.name == option.name }
  end
end)