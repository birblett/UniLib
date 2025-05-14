# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

require "json"

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
  def self.load_mods
    mods = []
    loaded = {}

    Dir.entries(UniLib.path("")).each { |f|
      if File.directory?(d = UniLib.path(f)) and File.file?(p = UniLib.path("#{f}/unilib_mod.json")) and !UniLib::LOADED_FILES[p]
        UniLib::LOADED_FILES[p] = true
        data = File.read(p)
        begin
          data = JSON.parse(data)
          id, version, entrypoints, unilib_version, dependencies, priority =
            data["id"], data["version"], data["entrypoints"], data["unilib_version"], data["dependencies"], data["priority"]
          raise Exception.new("id must be a string") unless id and id.is_a? String
          raise Exception.new("mod already exists with id #{id}") if loaded[id]
          loaded[id] = true
          raise Exception.new("version must be a number") unless version and version.is_a? Numeric
          raise Exception.new("entrypoints must be an array") unless entrypoints and entrypoints.is_a? Array
          mods.push(mod = UniLibMod.new(id, version, entrypoints, d))
          mod.unilib_version = unilib_version if unilib_version and unilib_version.is_a? Numeric
          mod.dependencies = dependencies if dependencies and dependencies.is_a? Array
          mod.unilib_version = priority if priority and priority.is_a? Numeric

        rescue Exception => e
          UniLib.dev_log("failed to parse modfile #{f}/unilib_mod.json: #{e}")
        end
      end
    }

    mods.sort_by! { |m| m.priority }.reverse!.each(&:modload)
  end

end