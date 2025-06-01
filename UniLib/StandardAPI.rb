# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ===================================================== REQUIRED FOR ALL OTHER APIS! ======================================================#
# ======================================================================================================================================== #

module UniLib

  VERSION = 0.8

  LOADED_LIBRARIES = {} unless defined? LOADED_LIBRARIES
  LOADED_FILES = {} unless defined? LOADED_FILES
  UNILIB_LOGGING_ENABLED = false unless defined? UNILIB_LOGGING_ENABLED
  PATH = File.dirname(__FILE__) + "/"
  ASSET_PATH = File.dirname(__FILE__) + "/../UniLibAssets/"
  API_PATH = PATH + "API/"
  LIB_PATH = PATH + "Core/"
  LOG_PATH = PATH + "../UniLibLog/"
  CONFIG_DIR = PATH + "../UniLibConfig"
  SAVE_PATH = PATH + "../UniLibSave/"
  SESSION_DEBUG = Time.now.strftime("%Y_%m_%d-%H_%M_%S.log") unless defined? SESSION_DEBUG
  CLEAR_INJECTOR_CACHE = false

  UNILIB_ABILITY = "Ability"
  UNILIB_AEVIAN_PORTS = "AevianPorts"
  UNILIB_ASSET = "Asset"
  UNILIB_BATTLE = "Battle"
  UNILIB_BATTLE_EFFECTS = "BattleEffects"
  UNILIB_CONSTANTS = "Constants"
  UNILIB_CREST = "Crest"
  UNILIB_CREST_COMPATIBILITY = "CrestCompat"
  UNILIB_DISPLAY = "Display"
  UNILIB_EVENTS = "Events"
  UNILIB_EXTRA_MOVE_FLAGS = "ExtraMoveFlags"
  UNILIB_FIXES = "Fixes"
  UNILIB_FORM_PORTS = "FormPorts"
  UNILIB_HELPER = "Helper"
  UNILIB_ITEM = "Item"
  UNILIB_MAP = "Map"
  UNILIB_MOVE = "Move"
  UNILIB_MULTIBILITY = "Multibility"
  UNILIB_OPTIONS = "Options"
  UNILIB_POKEMON = "Pokemon"
  UNILIB_POKEMON_OM = "PokemonOM"
  UNILIB_SWITCH = "Switch"

  MODULES = {
    UNILIB_ABILITY => 3,
    UNILIB_AEVIAN_PORTS => 4,
    UNILIB_ASSET => 0,
    UNILIB_BATTLE => 0,
    UNILIB_BATTLE_EFFECTS => 1,
    UNILIB_CONSTANTS  => 3,
    UNILIB_CREST => 2,
    UNILIB_CREST_COMPATIBILITY => 3,
    UNILIB_DISPLAY => 0,
    UNILIB_EVENTS => 0,
    UNILIB_EXTRA_MOVE_FLAGS => 1,
    UNILIB_FIXES => 3,
    UNILIB_FORM_PORTS => 4,
    UNILIB_HELPER => 0,
    UNILIB_ITEM => 1,
    UNILIB_MAP => 2,
    UNILIB_MOVE => 0,
    UNILIB_MULTIBILITY => 0,
    UNILIB_OPTIONS => 0,
    UNILIB_POKEMON => 0,
    UNILIB_POKEMON_OM  => 1,
    UNILIB_SWITCH => 0,
  } unless defined? MODULES

  CACHE_LEVELS = {
    UNILIB_ABILITY => 5,
    UNILIB_ASSET => 5,
    UNILIB_BATTLE => 5,
    UNILIB_BATTLE_EFFECTS => 5,
    UNILIB_CONSTANTS  => 5,
    UNILIB_CREST => 3,
    UNILIB_CREST_COMPATIBILITY => 3,
    UNILIB_DISPLAY => 5,
    UNILIB_EVENTS => 5,
    UNILIB_EXTRA_MOVE_FLAGS => 5,
    UNILIB_FIXES => 5,
    UNILIB_FORM_PORTS => 5,
    UNILIB_HELPER => 5,
    UNILIB_ITEM => 5,
    UNILIB_MAP => 5,
    UNILIB_MOVE => 5,
    UNILIB_MULTIBILITY => 5,
    UNILIB_OPTIONS => 5,
    UNILIB_POKEMON => 2,
    UNILIB_POKEMON_OM => 2,
    UNILIB_SWITCH => 5,
  } unless defined? CACHE_LEVELS

  <<-DOC
  writes to current debug file, if enabled.
  DOC
  def self.log(*args)
    if UNILIB_LOGGING_ENABLED
      Dir.mkdir(LOG_PATH) unless Dir.exist?(LOG_PATH)
      unless SESSION_DEBUG == ""
        str_final = ""
        args.each {|msg| str_final += msg.to_s + " " }
        File.open(LOG_PATH + SESSION_DEBUG, "a+") { |f| f.write("#{str_final}\n") }
      end
    end
  end

  <<-DOC
  dumps to dev.out
  DOC
  def self.dev_log(*args)
    Dir.mkdir(LOG_PATH) unless Dir.exist?(LOG_PATH)
    str_final = ""
    args.each {|msg| str_final += msg.to_s + (msg == args[-1] ? "" : " ") }
    File.open(LOG_PATH + "dev.out", "a+") { |f| f.write("#{str_final}\n") }
  end

  <<-DOC
  used for verifying the correct version of unilib.
  DOC
  def self.verify_version(version, file)
    file = File.basename(file).gsub(".rb", "")
    if version > VERSION
      Kernel.pbMessage("UniLib: #{file} is from a future version: #{version} - please update UniLib! (currently #{VERSION})")
    elsif version < VERSION
      Kernel.pbMessage("UniLib: #{file} is from an outdated version: #{version} - please update UniLib! (currently #{VERSION})")
    end
  end

  <<-DOC
  used to check for the presence of a mod in the mods directory.
  DOC
  def self.file_present?(other)
    File.file?(PATH + "../" + other + ".rb")
  end

  <<-DOC
  used for loading required apis and libraries. makes sure an api is not loaded more than once.
  DOC
  def self.include(path_relative)
    self.include("CodeInjector") if path_relative != "CodeInjector"
    unless LOADED_FILES[path_relative]
      load LIB_PATH + path_relative + "Core.rb" if File.exists?(LIB_PATH + path_relative + "Core.rb")
      load LIB_PATH + path_relative + "Lib.rb" if File.exists?(LIB_PATH + path_relative + "Lib.rb")
      load API_PATH + path_relative + "API.rb" if File.exists?(API_PATH + path_relative + "API.rb") unless LOADED_LIBRARIES[path_relative]
      load API_PATH + path_relative + ".rb" if File.exists?(API_PATH + path_relative + ".rb") unless LOADED_LIBRARIES[path_relative]
    end
    LOADED_LIBRARIES[path_relative] = (LOADED_FILES[path_relative] = true)
  end

  <<-DOC
  used mainly for internals; check if a library has been loaded at any point.
  DOC
  def self.lib_loaded(file)
    LOADED_LIBRARIES[File.basename(file).gsub(".rb", "").gsub(/(Lib|API|Core)/,"")]
  end

  <<-DOC
  used mainly for internals; check if a module should be considered cached
  DOC
  def self.cached(id)
    $unilib_current_cache_level >= CACHE_LEVELS[id]
  end

  <<-DOC
  used for loading files in subdirectories. makes sure the file is not loaded more than once.
  DOC
  def self.file_load(path_relative)
    load path_relative + ".rb" unless LOADED_FILES[path_relative]
    LOADED_FILES[path_relative] = true
  end

  <<-DOC
  loads all files in a subdirectory.
  DOC
  def self.dir_load(path_relative)
    files = Dir.entries(File.dirname(__FILE__) + "/../" + path_relative)
    files.sort.each do |entry|
      name = path_relative + "/" + entry
      unless LOADED_FILES[name]
        path = File.dirname(__FILE__) + "/../" + name
        load path if entry != "." and entry != ".." and entry.end_with? ".rb" and File.file? path
        LOADED_FILES[name] = true
      end
    end
  end

  <<-DOC
  returns a filepath to the mods directory
  DOC
  def self.path(path_relative)
    "#{Reborn ? "patch/Mods/" : "Data/Mods/"}#{path_relative}"
  end

  <<-DOC
  returns a filepath to the config directory
  DOC
  def self.config_path(path_relative)
    "#{Reborn ? "patch/Mods/" : "Data/Mods/"}UniLibConfig/#{path_relative}"
  end

  <<-DOC
  returns a filepath to the UniLib assets directory.
  DOC
  def self.asset_path(path_relative)
    "#{Reborn ? "patch/Mods/UniLib/Assets/" : "Data/Mods/UniLib/Assets/"}#{path_relative}"
  end

  <<-DOC
  returns an asset path relative to folders in Graphics
  DOC
  def self.from_graphics_path(path_relative)
    "../../#{path(path_relative)}"
  end

  <<-DOC
  loads from UniLib/Save/<name>.dat. prepends "Game_n_" if saveslot set to true.
  DOC
  def self.restore_data(name, default, saveslot=false)
    Dir.mkdir(SAVE_PATH) unless Dir.exist?(SAVE_PATH)
    prefix = saveslot ? "Game_#{$Unidata[:saveslot]}_" : ""
    ret = default
    File.open(SAVE_PATH + prefix + name + ".dat", "rb") { |f| ret = Marshal.load(f.read) } rescue default
    ret
  end

  <<-DOC
  writes to UniLib/Save/<name>.dat. prepends "Game_n_" if saveslot set to true.
  DOC
  def self.save_data(name, data, saveslot=false)
    Dir.mkdir(SAVE_PATH) unless Dir.exist?(SAVE_PATH)
    prefix = saveslot ? "Game_#{$Unidata[:saveslot]}_" : ""
    File.open(SAVE_PATH + prefix + name + ".dat", "wb") { |f| f.write(Marshal.dump(data)) }
  end

end

UniLib.include "ModLoader"