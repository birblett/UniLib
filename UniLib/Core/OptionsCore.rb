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
  UNILIB_BOX_COMMANDS = {}
  $queue_option_removal = false

end

unless UniLib.lib_loaded(__FILE__)

  class OptionBase
    include PropertyMixin

    include UniLib

    attr_accessor(:name)
    attr_accessor(:value)
    attr_accessor(:option)
    attr_accessor(:category)

    UNILIB_OPTION_CATEGORY = {}
    NATURAL_SORT = {}

    def self.add_category(category, sort)
      UNILIB_OPTION_CATEGORY[category] = sort
    end

    def self.get_category_sort(category)
      NATURAL_SORT[category] ||= NATURAL_SORT.size
      return 1000 * (UNILIB_OPTION_CATEGORY[category] ? UNILIB_OPTION_CATEGORY[category] : 2000) + NATURAL_SORT[category]
    end

    def initialize(name, desc, on_update_proc=nil, category="Misc.")
      @name = name
      @desc = desc
      @update = on_update_proc
      @increment = 1
      @min = 0
      @category = category
      UNILIB_CUSTOM_OPTIONS.push(self) unless UNILIB_CUSTOM_OPTIONS.include?(self)
    end

    def get
      @option
    end

    def update
      @update.call(@value + @min) unless @update.nil? or @value.nil? or @min.nil?
      UniLib.save_data("options", UniLib::UNILIB_CUSTOM_OPTIONS + UniLib::OLD_OPTIONS)
    end

    def description
      @desc.is_a?(Proc) ? @desc.call : @desc
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
      super(name, format, min, max, increment, getter, setter, description)
      @increment = increment
    end

    def next(current)
      index = current + @optstart + @increment * (Input.press?(Input::SHIFT) ? 10 : 1)
      index = @optstart if index>@optend
      tts(index.to_s, true)
      self.set(index - @optstart)
      index - @optstart
    end

    def prev(current)
      index = current + @optstart - @increment * (Input.press?(Input::SHIFT) ? 10 : 1)
      index = @optend if index < @optstart
      tts(index.to_s, true)
      self.set(index - @optstart)
      index - @optstart
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

#noinspection RubyInstanceMethodNamingConvention
class UniLibOptionScene < PokemonOptionScene

  include UniLib

  $sorted_options = nil

  unless UniLib.lib_loaded(__FILE__)

    attr_accessor(:viewport)

    def initOptions
      unless $sorted_options
        $sorted_options = []
        optionsSorted = UniLib::UNILIB_CUSTOM_OPTIONS.sort_by { |o| OptionBase.get_category_sort(o.category) }
        cat = nil
        optionsSorted.each { |o|
          if o.category != cat
            cat = o.category
            $sorted_options.push _INTL(cat)
          end
          $sorted_options.push(o.get)
        }
        $sorted_options.push _INTL("Back")
      end
      return $sorted_options.clone
    end

  end

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

def read_option_data
  UniLib.restore_data("options", []).each do |option|
    i = UniLib::UNILIB_CUSTOM_OPTIONS.index(option)
    if i
      UniLib::UNILIB_CUSTOM_OPTIONS[i].value = option.value
      UniLib::UNILIB_CUSTOM_OPTIONS[i].update
    else
      UniLib::OLD_OPTIONS.push(option)
    end
  end
end unless UniLib.lib_loaded(__FILE__)

UniLib.add_load_screen_event(:read_option_data)

MenuHandlers.add(:pause_menu, :unilib_options,
                 name:      proc { _INTL("UniLib Options") },
                 order:     71,
                 effect:    proc { |scene, screen|
                   opt_scene = UniLibOptionScene.new
                   opt_screen = PokemonOption.new(opt_scene)
                   pbFadeOutIn(99999) {
                     opt_screen.pbStartScreen
                     pbUpdateSceneMap
                     scene.pbRefresh
                   }
                   # In case windowskin was changed
                   scene.sprites["cmdwindow"].setSkin(MessageConfig.pbGetSystemFrame())
                   scene.sprites["cmdwindow"].setDefaultTextColors
                   $updateFLHUD = true
                   next nil
                 })

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method_before(:PokemonStorageScreen, :pbBoxCommands, "commands[cmdCancel = commands.length] = _INTL(\"Cancel\")",
  "uni_cmds = UniLib::UNILIB_BOX_COMMANDS.reduce({}) { |c, entry| commands[c[entry[0]] = commands.length] = _INTL(entry[1][0]) if entry[1][2].nil? or entry[1][2].call(pbHeldPokemon); c} if pbHeldPokemon")
