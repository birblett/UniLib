# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

UNILIB_CUSTOM_OPTIONS = []
OLD_OPTIONS = []
UNILIB_PAUSE_COMMANDS = {}
UNILIB_PARTY_COMMANDS = {}
UNILIB_BOX_COMMANDS = {}

UNILIB_PAUSE_COMMANDS["unilib_option_menu"] = ["UniLib", proc do |context|
  pbFadeOutIn(99999) {
    PokemonOption.new(UniLibOptionScene.new).pbStartScreen
    pbUpdateSceneMap
    context.instance_variable_get(:@scene).pbRefresh
  }
  $updateFLHUD = true
end, proc do |_|
  if $queue_option_removal
    arr = (UNILIB_CUSTOM_OPTIONS + [SEPARATE_UNILIB_OPTIONS]).map { |opt| opt.get_option }
    PokemonOptionScene::OptionList.delete_if { |v| arr.include?(v) }
  end
  SEPARATE_UNILIB_OPTIONS == 1
end]

$options_init = false

class OptionBase

  attr_accessor(:name)
  attr_accessor(:value)
  attr_accessor(:option)

  def initialize(name, desc, on_update_proc=nil)
    @name = name
    @desc = desc
    @update = on_update_proc
    @increment = 1
    @min = 0
    UNILIB_CUSTOM_OPTIONS.push(self) unless UNILIB_CUSTOM_OPTIONS.include?(self)
  end

  def update
    @update.call(@value + @min) unless @update.nil?
  end

  def get_option
    @option
  end

  def ==(other)
    (other.is_a?(OptionBase) ? @name == other.name : (@value + @min) == other)
  end

  def !=(other)
    (other.is_a?(OptionBase) ? @name != other.name : (@value + @min) != other)
  end

  def >(other)
    (other.is_a?(OptionBase) ? @value > other.value : (@value + @min) > other)
  end

  def <(other)
    (other.is_a?(OptionBase) ? @value < other.value  : (@value + @min) < other)
  end

  def >=(other)
    (other.is_a?(OptionBase) ? @value >= other.value : (@value + @min) >= other)
  end

  def <=(other)
    (other.is_a?(OptionBase) ? @value <= other.value  : (@value + @min) <= other)
  end

  def +(other)
    (other.is_a?(Integer) || other.is_a?(Float)) ? @value + @min + other : 0
  end

  def -(other)
    (other.is_a?(Integer) || other.is_a?(Float)) ? @value + @min - other : 0
  end

  def *(other)
    (other.is_a?(Integer) || other.is_a?(Float)) ? (@value + @min) * other : 0
  end

  def /(other)
    (other.is_a?(Integer) || other.is_a?(Float)) ? (@value + @min) / other : 0
  end

  def &(other)
    (other.is_a?(Integer) || other.is_a?(Float)) ? (@value + @min) & other : 0
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
    index = current + @optstart + @increment * (Input.press?(Input::SHIFT) ? 10 : 1)
    index = @optstart if index>@optend
    index - @optstart
  end

  def prev(current)
    index = current + @optstart - @increment * (Input.press?(Input::SHIFT) ? 10 : 1)
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

SEPARATE_UNILIB_OPTIONS = UniStringOption.new("UniLib Option Menu", "Moves UniLib options to their own menu.", %w[Off On], proc { |value| $queue_option_removal = value == 1 }, 1)
UNILIB_CUSTOM_OPTIONS -= [SEPARATE_UNILIB_OPTIONS]

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
      UNILIB_CUSTOM_OPTIONS.each { |option| OptionList.push(option.get_option) unless option.get_option.nil? or OptionList.include?(option.get_option)}
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

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def read_option_data
  options = unilib_load_data("options", [], false)
  options.each do |option|
    if option == SEPARATE_UNILIB_OPTIONS
      SEPARATE_UNILIB_OPTIONS.value = option.value
      SEPARATE_UNILIB_OPTIONS.update
    else
      i = UNILIB_CUSTOM_OPTIONS.index(option)
      if i
        UNILIB_CUSTOM_OPTIONS[i].value = option.value
        UNILIB_CUSTOM_OPTIONS[i].update
      else
        OLD_OPTIONS.push(option)
      end
    end

  end
end

add_play_event(:read_option_data)
add_new_file_event(:read_option_data)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

insert_in_method_before(:PokemonOptionScene, :pbStartScene, "for i in 0...OptionList.length", proc do
  if SEPARATE_UNILIB_OPTIONS == 0 and UNILIB_CUSTOM_OPTIONS.length > 0
    UNILIB_CUSTOM_OPTIONS.each { |option| OptionList.push(option.get_option) unless option.get_option.nil? or OptionList.include?(option.get_option)}
    OptionList.push(SEPARATE_UNILIB_OPTIONS.get_option) unless OptionList.include?(SEPARATE_UNILIB_OPTIONS.get_option)
  end
end)

insert_in_method(:PokemonOption, :pbStartScreen, "@scene.pbOptions", "unilib_save_data(\"options\", UNILIB_CUSTOM_OPTIONS + OLD_OPTIONS + [SEPARATE_UNILIB_OPTIONS], false)")

insert_in_method(:PokemonMenu, :pbStartPokemonMenu, "commands[cmdOption=commands.length]=_INTL(\"Options\")", "uni_cmds = UNILIB_PAUSE_COMMANDS.reduce({}) { |c, entry| commands[c[entry[0]] = commands.length] = _INTL(entry[1][0]) if entry[1][2].nil? or entry[1][2].call(self); c}")

insert_in_method(:PokemonMenu, :pbStartPokemonMenu, "command=@scene.pbShowCommands(commands)", "b = false; uni_cmds.each { |c, idx| UNILIB_PAUSE_COMMANDS[c][1].call(self) if b |= command == idx }; next if b")

insert_in_method_before(:PokemonScreen, :pbPokemonScreen, "commands[commands.length]=_INTL(\"Cancel\")", "uni_cmds = UNILIB_PARTY_COMMANDS.reduce({}) { |c, entry| commands[c[entry[0]] = commands.length] = _INTL(entry[1][0]) if entry[1][2].nil? or entry[1][2].call(pkmn); c}")

insert_in_method_before(:PokemonScreen, :pbPokemonScreen, "if cmdSummary>=0 && command==cmdSummary", "uni_cmds.each { |c, idx| UNILIB_PARTY_COMMANDS[c][1].call(pkmn) if command == idx }")

insert_in_method_before(:PokemonStorageScreen, :pbStartScreen, "command=pbShowCommands(helptext,commands)", "uni_cmds = UNILIB_BOX_COMMANDS.reduce({}) { |c, entry| commands[c[entry[0]] = commands.length] = _INTL(entry[1][0]) if entry[1][2].nil? or entry[1][2].call(heldpoke ? heldpoke : pokemon, selected[0] == -1); c} if heldpoke or pokemon")

insert_in_method(:PokemonStorageScreen, :pbStartScreen, "command=pbShowCommands(helptext,commands)", "uni_cmds.each { |c, idx| UNILIB_PARTY_COMMANDS[c][1].call(heldpoke ? heldpoke : pokemon, selected[0] == -1) if command == idx }")
