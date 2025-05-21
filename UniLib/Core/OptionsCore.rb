# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  UNILIB_CUSTOM_OPTIONS = []
  OLD_OPTIONS = []
  UNILIB_PAUSE_COMMANDS = {"UniLib.option_menu" => ["UniLib", proc do |context|
    pbFadeOutIn(99999) {
      PokemonOption.new(UniLibOptionScene.new).pbStartScreen
      pbUpdateSceneMap
      context.instance_variable_get(:@scene).pbRefresh
    }
    $updateFLHUD = true
  end, proc do |_|
    if $queue_option_removal
      arr = (UNILIB_CUSTOM_OPTIONS + [SEPARATE_UNILIB_OPTIONS]).map { |opt| opt.get }
      PokemonOptionScene::OptionList.delete_if { |v| arr.include?(v) } if Rejuv
    end
    SEPARATE_UNILIB_OPTIONS == 1
  end]}
  UNILIB_PARTY_COMMANDS = {}
  UNILIB_BOX_COMMANDS = {}
  $queue_option_removal = false

end

unless UniLib.lib_loaded(__FILE__)

  class OptionBase

    include UniLib

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
      @update.call(@value + @min) unless @update.nil? or @value.nil? or @min.nil?
      UniLib.save_data("options", UniLib::UNILIB_CUSTOM_OPTIONS + UniLib::OLD_OPTIONS + [UniLib::SEPARATE_UNILIB_OPTIONS])
    end

    def get
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
      if Reborn
        super(name, format, min, max, increment, getter, setter, description)
      else
        super(name, format, min, max, getter, setter, description)
      end
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

end

module UniLib

  SEPARATE_UNILIB_OPTIONS = UniStringOption.new("UniLib Option Menu", "Moves UniLib options to their own menu.", %w[Off On], proc { |value| $queue_option_removal = value == 1 }, 0)
  UNILIB_CUSTOM_OPTIONS -= [SEPARATE_UNILIB_OPTIONS]

end

#noinspection RubyInstanceMethodNamingConvention
class UniLibOptionScene

  include UniLib

  unless UniLib.lib_loaded(__FILE__)

    if Rejuv

      OptionList = []

      attr_accessor(:viewport)

      def pbStartScene
        @sprites={}
        @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z=99999
        @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(_INTL("UniLib Options"),0,0,Graphics.width,64,@viewport)
        @sprites["textbox"]=Kernel.pbCreateMessageWindow
        @sprites["textbox"].letterbyletter=false
        if SEPARATE_UNILIB_OPTIONS == 1
          UNILIB_CUSTOM_OPTIONS.each { |option| OptionList.push(option.get) unless option.get.nil? or OptionList.include?(option.get)}
          OptionList.push(SEPARATE_UNILIB_OPTIONS.get) unless OptionList.include?(SEPARATE_UNILIB_OPTIONS.get)
        end
        @sprites["option"]=Window_PokemonOption.new(OptionList, 0, @sprites["title"].height,Graphics.width, Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
        @sprites["option"].viewport=@viewport
        @sprites["option"].visible=true
        (0...OptionList.length).each { |i| @sprites["option"][i] = (OptionList[i].get || 0) }
        pbDeactivateWindows(@sprites)
        pbFadeInAndShow(@sprites) { pbUpdate }
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

    else

      attr_accessor(:viewport)

      def pbStartScene
        @optionList = []
        @sprites = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(_INTL("UniLib Options"), 0, 0, Graphics.width, 64, @viewport)
        @sprites["textbox"] = Kernel.pbCreateMessageWindow
        @sprites["textbox"].letterbyletter = false
        UNILIB_CUSTOM_OPTIONS.each { |option| @optionList.push(option.get) unless option.get.nil? }
        @optionList.push(SEPARATE_UNILIB_OPTIONS.get)
        @sprites["option"] = Window_PokemonOption.new(@optionList, 0, @sprites["title"].height,
                                                      Graphics.width, Graphics.height - @sprites["title"].height - @sprites["textbox"].height)
        @sprites["option"].viewport = @viewport
        @sprites["option"].visible = true
        # Get the values of each option
        (0...@optionList.length).each { |i| @sprites["option"][i] = (@optionList[i].get || 0) }
        pbDeactivateWindows(@sprites)
        pbFadeInAndShow(@sprites) { pbUpdate }
      end

      def pbOptions
        pbActivateWindow(@sprites,"option"){
          loop do
            Graphics.update
            Input.update
            pbUpdate
            if @sprites["option"].mustUpdateOptions
              # Set the values of each option
              (0...@optionList.length).each { |i| @optionList[i].set(@sprites["option"][i]) }
              @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
              @sprites["textbox"].width=@sprites["textbox"].width  # Necessary evil
              if (opt = @sprites["option"].options[@sprites["option"].index]).nil?
                @sprites["textbox"].text = "Exit and save selected settings."
              else
                if opt.description.is_a?(Proc)
                  @sprites["textbox"].text = opt.description.call
                else
                  @sprites["textbox"].text = opt.description
                end
              end
            end
            break if Input.trigger?(Input::B) or Input.trigger?(Input::C) && @sprites["option"].index == @optionList.length
          end
        }
      end

      def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        # Set the values of each option
        (0...@optionList.length).each { |i| @optionList[i].set(@sprites["option"][i]) }
        Kernel.pbDisposeMessageWindow(@sprites["textbox"])
        pbDisposeSpriteHash(@sprites)
        pbRefreshSceneMap
        @viewport.dispose
      end

    end

    def pbUpdate
      pbUpdateSpriteHash(@sprites)
    end

  end

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def read_option_data
  options = UniLib.restore_data("options", [])
  options.each do |option|
    if option == UniLib::SEPARATE_UNILIB_OPTIONS
      UniLib::SEPARATE_UNILIB_OPTIONS.value = option.value
      UniLib::SEPARATE_UNILIB_OPTIONS.update
    else
      i = UniLib::UNILIB_CUSTOM_OPTIONS.index(option)
      if i
        UniLib::UNILIB_CUSTOM_OPTIONS[i].value = option.value
        UniLib::UNILIB_CUSTOM_OPTIONS[i].update
      else
        UniLib::OLD_OPTIONS.push(option)
      end
    end

  end
end unless UniLib.lib_loaded(__FILE__)

UniLib.add_play_event(:read_option_data)
UniLib.add_new_file_event(:read_option_data)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

target = Reborn ? "@optionList" : "OptionList"
UniLib.insert_in_method_before(:PokemonOptionScene, :pbStartScene, "for i in 0...#{target}.length",
  "if UniLib::SEPARATE_UNILIB_OPTIONS == 0 and UniLib::UNILIB_CUSTOM_OPTIONS.length > 0
    UniLib::UNILIB_CUSTOM_OPTIONS.each { |option| #{target}.push(option.get) unless option.get.nil? or #{target}.include?(option.get)}
    #{target}.push(UniLib::SEPARATE_UNILIB_OPTIONS.get) unless #{target}.include?(UniLib::SEPARATE_UNILIB_OPTIONS.get)
  end")

target = Reborn ? "commands[cmdOption = commands.length] = _INTL(\"Options\")" : "commands[cmdOption=commands.length]=_INTL(\"Options\")"
UniLib.insert_in_method(:PokemonMenu, :pbStartPokemonMenu, target,
  "uni_cmds = UniLib::UNILIB_PAUSE_COMMANDS.reduce({}) { |c, entry| commands[c[entry[0]] = commands.length] = _INTL(entry[1][0]) if entry[1][2].nil? or entry[1][2].call(self); c}")

target = Reborn ? "command = @scene.pbShowCommands(commands)" : "command=@scene.pbShowCommands(commands)"
UniLib.insert_in_method(:PokemonMenu, :pbStartPokemonMenu, target,
  "b = false; uni_cmds.each { |c, idx| next if b; UniLib::UNILIB_PAUSE_COMMANDS[c][1].call(self) if b |= command == idx}; next if b")

target = Reborn ? "commands[commands.length] = _INTL(\"Cancel\")" : "commands[commands.length]=_INTL(\"Cancel\")"
UniLib.insert_in_method_before(:PokemonScreen, :pbPokemonScreen, target,
  "uni_cmds = UniLib::UNILIB_PARTY_COMMANDS.reduce({}) { |c, entry| commands[c[entry[0]] = commands.length] = _INTL(entry[1][0]) if entry[1][2].nil? or entry[1][2].call(pkmn); c}")

target = Reborn ? "if cmdSummary >= 0 && command == cmdSummary" : "if cmdSummary>=0 && command==cmdSummary"
UniLib.insert_in_method_before(:PokemonScreen, :pbPokemonScreen, target,
  "uni_cmds.each { |c, idx| UniLib::UNILIB_PARTY_COMMANDS[c][1].call(pkmn) if command == idx }")

target = Reborn ? "command = pbShowCommands(helptext, commands)" : "command=pbShowCommands(helptext,commands)"
UniLib.insert_in_method_before(:PokemonStorageScreen, :pbStartScreen, target,
  "uni_cmds = UniLib::UNILIB_BOX_COMMANDS.reduce({}) { |c, entry| commands[c[entry[0]] = commands.length] = _INTL(entry[1][0]) if entry[1][2].nil? or entry[1][2].call(heldpoke ? heldpoke : pokemon, selected[0] == -1); c} if heldpoke or pokemon")

target = Reborn ? "command = pbShowCommands(helptext, commands)" : "command=pbShowCommands(helptext,commands)"
UniLib.insert_in_method(:PokemonStorageScreen, :pbStartScreen, target,
  "called = false
  uni_cmds.each { |c, idx| (UniLib::UNILIB_PARTY_COMMANDS[c][1].call(heldpoke ? heldpoke : pokemon, selected[0] == -1); called = true) if command == idx }
  next if called")