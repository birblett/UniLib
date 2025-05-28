# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

require 'fileutils'
UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

class UniLibMod

  attr_accessor(:version)
  attr_accessor(:unilib_version)
  attr_accessor(:dependencies)
  attr_accessor(:priority)
  def initialize(id, version, entrypoints, dir)
    @id = id
    @entrypoints = entrypoints
    @version = version
    @priority = 1000
    @dir = dir
  end

  def mod_load
    UniLib.current_mod = @id
    @entrypoints.each { |e| load "#{@dir}/#{e}" }
    UniLib::LOADED_MODS[@id] = true
  end

end

module UniLib

  CONFIG_PATH = UniLib.config_path("disabled.json")
  STAGED_MODS = {} unless defined? STAGED_MODS
  LOADED_MODS = {} unless defined? LOADED_MODS
  MOD_CONFIGS = {} unless defined? MOD_CONFIGS
  LOADED_LIBRARIES = {} unless defined? LOADED_LIBRARIES
  $unilib_refresh_configs = true unless defined? $refresh_configs

  def self.except(exception)
    return Exception.new("#{exception}")
  end

  def self.current_mod
    @@current_mod
  end

  def self.current_mod=(other)
    @@current_mod = other
  end

  def self.config_read(cfg, id)
    Dir.glob("#{cfg}/*.json") { |f|
      begin
        MOD_CONFIGS[id] ||= {}
        MOD_CONFIGS[id] = MOD_CONFIGS[id].merge(HTTPLite::JSON.parse(File.read(f)))
      rescue Exception => e
        UniLib.dev_log("failed to parse config file #{f}: #{e}")
      end
    }
  end

  def self.load_mods
    mods = []
    required_modules = []
    [STAGED_MODS, LOADED_MODS].map(&:clear)
    MOD_CONFIGS.clear if $unilib_refresh_configs
    Dir.mkdir(CONFIG_DIR) unless Dir.exist?(CONFIG_DIR)
    File.open(CONFIG_PATH, "w") { _1.write("{\n  \"disabled\": [\n  ]\n}") } unless File.exist?(CONFIG_PATH)
    disabled = begin
                 HTTPLite::JSON.parse(File.read(CONFIG_PATH))["disabled"].map { |k| [k, true] }.to_h
               rescue Exception => e
                 UniLib.dev_log("failed to parse UniLibConfig/disabled.json: #{e}")
                 {}
               end
    Dir.entries(UniLib.path("")).each { |f|
      if File.directory?(d = UniLib.path(f)) and File.file?(p = UniLib.path("#{f}/unilib_mod.json")) and !UniLib::LOADED_FILES[p]
        UniLib::LOADED_FILES[p] = true
        begin
          data = HTTPLite::JSON.parse(File.read(p))
          # parse unilib_mod.json
          id, version, entrypoints, unilib_version, modules, dependencies, priority =
            data["id"], data["version"], data["entrypoints"], data["unilib_version"], data["modules"], data["dependencies"], data["priority"]
          raise except("id #{id} must be a string") unless id and id.is_a? String
          next if disabled[id]
          raise except("mod already exists with matching id") if STAGED_MODS[id]
          raise except("version must be a number") unless version and version.is_a? Numeric
          raise except("entrypoints must be an array") unless entrypoints and entrypoints.is_a? Array
          if modules
            raise except("modules must be an array") unless modules.is_a? Array
            modules.each { |m| raise except("no such module #{m}") unless UniLib::MODULES[m] }
            required_modules |= modules
          end
          mods.push(mod = UniLibMod.new(id, version, entrypoints, d))
          mod.unilib_version = (unilib_version * 1000).to_i / 1000.0 if unilib_version and unilib_version.is_a? Numeric
          raise except("unilib version #{mod.unilib_version} required, #{VERSION} found") if mod.unilib_version unless mod.unilib_version == VERSION
          mod.dependencies = dependencies if dependencies and dependencies.is_a? Array
          mod.priority = priority if priority and priority.is_a? Numeric

          if $unilib_refresh_configs
            # parse default configs
            cfg = UniLib.config_path("#{id}")
            begin
              if File.directory?("#{d}/DefaultConfigs")
                post = false
                if !File.directory?(cfg)
                  Dir.mkdir(cfg)
                  Dir.glob("#{d}/DefaultConfigs/*.json") { |file| FileUtils.cp(file, "#{cfg}/#{File.basename(file)}") }
                  post = true
                elsif File.exist?("#{cfg}/version.json")
                  version = (HTTPLite::JSON.parse(File.read("#{cfg}/version.json"))["version"] * 1000).to_i / 1000.0
                  if version != mod.version
                    Dir.glob("#{d}/DefaultConfigs/*.json") { |file|
                      old_cfg_file = "#{cfg}/#{File.basename(file)}"
                      old_configs = File.exist?(old_cfg_file) ? {} : HTTPLite::JSON.parse(File.read(old_cfg_file))
                      new_configs = HTTPLite::JSON.parse(File.read(file))
                      new_configs.keys.each { |k| new_configs[k] = old_configs[k] if old_configs[k] }
                      File.write(old_cfg_file, HTTPLite::JSON.stringify(new_configs))
                    }
                  end
                  post = true
                end
                if post
                  File.write("#{cfg}/version.json", HTTPLite::JSON.stringify({ "version" => mod.version })) if mod.version
                  UniLib.config_read(cfg, id)
                end
              end
            rescue Exception => e
              UniLib.dev_log("failed to parse default configs for #{id}: #{e}")
            end

            # read configs
            UniLib.config_read(cfg, id) if File.directory?(cfg)
          end
          STAGED_MODS[id] = true
        rescue Exception => e
          UniLib.dev_log("failed to parse modfile #{f}/unilib_mod.json: #{e}")
        end
      end
    }
    required_modules.sort_by! { |m| UniLib::MODULES[m] }.each { |m| UniLib.include m }
    UniStringOption.new("Autorefresh Configs", "Refresh configs on F12 restart.", %w[Off On], proc { |value| $unilib_refresh_configs = value == 1 }) if MODULES["Options"]
    mods.sort_by! { |m| m.priority }.reverse!.each(&:mod_load)
  end

end