# ==================================================================================================================== #
# =================================================== DEPENDENCIES =================================================== #
# ==================================================================================================================== #

verify_version(0.4, File.basename(__FILE__).gsub!(".rb", ""))

# ==================================================================================================================== #
# ================================================== INTERNAL/CORE =================================================== #
# ==================================================================================================================== #

CUSTOM_OPTIONS = []
OLD_OPTIONS = []
$options_init = false

class OptionBase

  attr_accessor(:name)
  attr_accessor(:value)
  attr_accessor(:option)

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
    @option
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
    index = current + @optstart + @increment
    index = @optstart if index>@optend
    index - @optstart
  end

  def prev(current)
    index = current + @optstart - @increment
    index = @optend if index < @optstart
    index - @optstart
  end

end

class UniStringOption < OptionBase

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

end

class UniNumberOption < OptionBase

  def ==(other)
    (other.is_a?(OptionBase) ? @name == other.name : @value + 1 == other)
  end

  def !=(other)
    (other.is_a?(OptionBase) ? @name != other.name : @value + 1 != other)
  end

  def >(other)
    (other.is_a?(OptionBase) ? @value > other.value : @value + 1 > other)
  end

  def <(other)
    (other.is_a?(OptionBase) ? @value < other.value  : @value + 1 < other)
  end

  def >=(other)
    (other.is_a?(OptionBase) ? @value >= other.value : @value + 1 >= other)
  end

  def <=(other)
    (other.is_a?(OptionBase) ? @value <= other.value  : @value + 1 <= other)
  end

end

$queue_option_removal = false

SEPARATE_UNILIB_OPTIONS = UniStringOption.new("Separate UniLib Options", "Moves UniLib options to their own menu.", %w[Off On], proc { |value| $queue_option_removal = value == 1 }, 1)
CUSTOM_OPTIONS -= [SEPARATE_UNILIB_OPTIONS]

#noinspection RubyInstanceMethodNamingConvention
class UniLibOptionScene

  attr_accessor(:viewport)
  OptionList = []

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(_INTL("UniLib Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    if SEPARATE_UNILIB_OPTIONS == 1
      CUSTOM_OPTIONS.each { |option| OptionList.push(option.get_option) unless option.get_option.nil? or OptionList.include?(option.get_option)}
      OptionList.push(SEPARATE_UNILIB_OPTIONS.get_option) unless OptionList.include?(SEPARATE_UNILIB_OPTIONS.get_option)
    end
    @sprites["option"]=Window_PokemonOption.new(OptionList, 0, @sprites["title"].height,Graphics.width, Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport=@viewport
    @sprites["option"].visible=true
    (0...OptionList.length).each { |i| @sprites["option"][i] = (OptionList[i].get || 0) }
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbOptions
    pbActivateWindow(@sprites,"option"){
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].mustUpdateOptions
          # Set the values of each option
          (0...OptionList.length).each { |i| OptionList[i].set(@sprites["option"][i]) }
          @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
          @sprites["textbox"].width=@sprites["textbox"].width  # Necessary evil
          pbSetSystemFont(@sprites["textbox"].contents)
          if @sprites["option"].options[@sprites["option"].index].description.is_a?(Proc)
            @sprites["textbox"].text=@sprites["option"].options[@sprites["option"].index].description.call
          else
            @sprites["textbox"].text=@sprites["option"].options[@sprites["option"].index].description
          end
        end
        break if Input.trigger?(Input::B) or Input.trigger?(Input::C) && @sprites["option"].index==OptionList.length
      end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    (0...OptionList.length).each { |i| OptionList[i].set(@sprites["option"][i]) }
    Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
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
  if SEPARATE_UNILIB_OPTIONS == 0
    CUSTOM_OPTIONS.each { |option| OptionList.push(option.get_option) unless option.get_option.nil? or OptionList.include?(option.get_option)}
    OptionList.push(SEPARATE_UNILIB_OPTIONS.get_option) unless OptionList.include?(SEPARATE_UNILIB_OPTIONS.get_option)
  end
end)

insert_in_method(:PokemonMenu, :pbStartPokemonMenu, "cmdOption=-1", "cmd_uni=-1")

insert_in_method(:PokemonMenu, :pbStartPokemonMenu, "commands[cmdOption=commands.length]=_INTL(\"Options\")", "commands[cmd_uni=commands.length]=_INTL(\"UniLib\") if SEPARATE_UNILIB_OPTIONS == 1")

insert_in_method_before(:PokemonMenu, :pbStartPokemonMenu, "elsif cmdOption>=0 && command==cmdOption", proc do |command, cmd_uni| if true
  elsif cmd_uni>=0 && command==cmd_uni
    scene=UniLibOptionScene.new
    screen=PokemonOption.new(scene)
    pbFadeOutIn(99999) {
      screen.pbStartScreen
      pbUpdateSceneMap
      @scene.pbRefresh
    }
    $updateFLHUD = true
end end)

insert_in_method(:PokemonMenu, :pbStartPokemonMenu, "command=@scene.pbShowCommands(commands)", proc do
  if $queue_option_removal
    arr = []
    (CUSTOM_OPTIONS + [SEPARATE_UNILIB_OPTIONS]).each { |opt| arr.push(opt.get_option)}
    PokemonOptionScene::OptionList.delete_if { |v| arr.include?(v) }
  end
end)
