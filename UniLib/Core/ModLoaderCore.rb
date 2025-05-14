# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.7, __FILE__)

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

  def modload = @entrypoints.each { |e| load "#{@dir}/#{e}" }

end

module UniLib

  def self.except(exception)
    return Exception.new("#{exception}")
  end

  def self.load_mods
    mods = []
    required_modules = []
    loaded = {}
    Dir.entries(UniLib.path("")).each { |f|
      if File.directory?(d = UniLib.path(f)) and File.file?(p = UniLib.path("#{f}/unilib_mod.json")) and !UniLib::LOADED_FILES[p]
        UniLib::LOADED_FILES[p] = true
        data = File.read(p)
        begin
          data = HTTPLite::JSON.parse(data)
          id, version, entrypoints, unilib_version, modules, dependencies, priority =
            data["id"], data["version"], data["entrypoints"], data["unilib_version"], data["modules"], data["dependencies"], data["priority"]
          raise except("id #{id} must be a string") unless id and id.is_a? String
          raise except("mod already exists with matching id") if loaded[id]
          loaded[id] = true
          raise except("version must be a number") unless version and version.is_a? Numeric
          raise except("entrypoints must be an array") unless entrypoints and entrypoints.is_a? Array
          if modules
            raise except("modules must be an array") unless modules.is_a? Array
            modules.each { |m| raise except("no such module #{m}") unless UniLib::MODULES[m] }
            required_modules |= modules
          end
          mods.push(mod = UniLibMod.new(id, version, entrypoints, d))
          mod.unilib_version = (unilib_version * 1000).to_i / 1000 if unilib_version and unilib_version.is_a? Numeric
          raise except("unilib version #{mod.unilib_version} required, #{VERSION} found") if mod.unilib_version unless mod.unilib_version == VERSION
          mod.dependencies = dependencies if dependencies and dependencies.is_a? Array
          mod.unilib_version = priority if priority and priority.is_a? Numeric
        rescue Exception => e
          UniLib.dev_log("failed to parse modfile #{f}/unilib_mod.json: #{e}")
        end
      end
    }
    required_modules.sort_by! { |m| UniLib::MODULES[m] }.reverse!.each { |m| UniLib.include m }
    mods.sort_by! { |m| m.priority }.reverse!.each(&:modload)
  end

end