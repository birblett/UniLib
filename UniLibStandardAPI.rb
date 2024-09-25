# ==================================================================================================================== #
# ==================================================== PUBLIC API ==================================================== #
# =========================================== REQUIRED FOR ALL OTHER APIS! ============================================#
# ==================================================================================================================== #

LOADED = {} unless defined? LOADED
DEBUG_ENABLED = false
API_VERSION = 0.3
UNILIB_PATH = File.dirname(__FILE__) + "/UniLib/"
UNILIB_ASSET_PATH = File.dirname(__FILE__) + "/UniLibAssets/"
LIB_PATH = UNILIB_PATH + "Core/"
LOG_PATH = UNILIB_PATH + "Log/"


def verify_version(version, file)
  if version > API_VERSION
    Kernel.pbMessage("UniLib: #{file} is from a future version: #{version} - please update UniLib! (currently #{API_VERSION})")
  elsif version < API_VERSION
    Kernel.pbMessage("UniLib: #{file} is from an outdated version: #{version} - please update UniLib! (currently #{API_VERSION})")
  end
end

<<-DOC
used for loading required apis and libraries. makes sure an api is not loaded more than once.
DOC
def unilib_include(path_relative)
  unless LOADED["CodeInjector"]
    $debug_name = Time.now.strftime("%d_%m_%Y-%H_%M_%S.log")
  end
  unilib_include("CodeInjector") if path_relative != "CodeInjector"
  load LIB_PATH + path_relative + "Core.rb" if File.exists?(LIB_PATH + path_relative + "Core.rb") unless LOADED[path_relative]
  load LIB_PATH + path_relative + "Lib.rb" if File.exists?(LIB_PATH + path_relative + "Lib.rb") unless LOADED[path_relative]
  load UNILIB_PATH + path_relative + "API.rb" if File.exists?(UNILIB_PATH + path_relative + "API.rb") unless LOADED[path_relative]
  LOADED[path_relative] = true
end

<<-DOC
used for loading files in subdirectories. makes sure the file is not loaded more than once.
DOC
def unilib_file_load(path_relative)
  load File.dirname(__FILE__) + "/" + path_relative + ".rb" unless LOADED[path_relative]
  LOADED[path_relative] = true
end

<<-DOC
loads all files in a subdirectory.
DOC
def unilib_dir_load(path_relative)
  files = Dir.entries(File.dirname(__FILE__) + "/" + path_relative)
  files.each do |entry|
    name = path_relative + "/" + entry
    unless LOADED[name]
      path = File.dirname(__FILE__) + "/" + name
      load path if entry != "." and entry != ".." and entry.end_with? ".rb" and File.file? path
      LOADED[name] = true
    end
  end
end

<<-DOC
loads from UniLib/Save/Game_<savenum>_<name>.dat
DOC
def unilib_load_data(name, default, saveslot=true)
  dir = "#{UNILIB_PATH}Save/"
  Dir.mkdir(dir) unless Dir.exist?(dir)
  prefix = saveslot ? "Game_#{$Unidata[:saveslot]}_" : ""
  Marshal.load(File.read(dir + prefix + name + ".dat")) rescue default
end

<<-DOC
writes to UniLib/Save/Game_<savenum>_<name>.dat
DOC
def unilib_save_data(name, data, saveslot=true)
  dir = "#{UNILIB_PATH}Save/"
  Dir.mkdir(dir) unless Dir.exist?(dir)
  prefix = saveslot ? "Game_#{$Unidata[:saveslot]}_" : ""
  File.open(dir + prefix + name + ".dat", "w") { |f| f.write(Marshal.dump(data)) }
end

<<-DOC
writes to current debug file, if enabled.
DOC
def unilib_log(*args)
  if DEBUG_ENABLED
    Dir.mkdir(LOG_PATH) unless Dir.exist?(LOG_PATH)
    unless $debug_name == ""
      str_final = ""
      args.each {|msg| str_final += msg.to_s + " " }
      File.open(LOG_PATH + $debug_name, "a+") { |f| f.write("#{str_final}\n") }
    end
  end
end

<<-DOC
dumps to dev.out
DOC
def unidev_log(*args)
  Dir.mkdir(LOG_PATH) unless Dir.exist?(LOG_PATH)
  str_final = ""
  args.each {|msg| str_final += msg.to_s + " " }
  File.open(LOG_PATH + "dev.out", "a+") { |f| f.write("#{str_final}\n") }
end