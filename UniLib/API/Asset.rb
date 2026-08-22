# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module Assets

  def self.redirect(type, base, target=nil, &block)
    return if target.nil? and block.nil? or UniLib.cached(UniLib::ASSET)
    case type
    when :BMP then ANIMATED_BITMAP_REDIRECT[base] = block ? [UniLib.path(""), block] : UniLib.path(target)
    when :AUDIO then AUDIO_FILE_REDIRECT[base] = block ? ["../../#{UniLib.path("")}", block] : "../../#{UniLib.path(target)}"
    else print "Unsupported asset redirection type: #{type}"
    end
    self
  end

  def self.redirect_pkmn_detailed(species, form, asset = nil, asset_f = nil, egg = nil, egg_f = nil)
    return if UniLib.cached(UniLib::ASSET)
    arr = (form == :ALL) ?
            (PKMN_REDIRECT[species] ||= [nil, nil, nil, nil, nil, nil, nil, nil]) :
            (PKMN_REDIRECT[[species, form]] ||= [nil, nil, nil, nil, nil, nil, nil, nil])
    arr[0] = UniLib.path(asset) if asset
    arr[1] = UniLib.path(asset_f) if asset_f
    arr[2] = UniLib.path(egg) if egg
    arr[3] = UniLib.path(egg_f) if egg_f
  end

  def self.redirect_pkmn_icon(species, form, asset = nil, asset_f = nil, egg = nil, egg_f = nil)
    return if UniLib.cached(UniLib::ASSET)
    arr = (form == :ALL) ?
            (PKMN_REDIRECT[species] ||= [nil, nil, nil, nil, nil, nil, nil, nil]) :
            (PKMN_REDIRECT[[species, form]] ||= [nil, nil, nil, nil, nil, nil, nil, nil])
    arr[4] = UniLib.path(asset) if asset
    arr[5] = UniLib.path(asset_f) if asset_f
    arr[6] = UniLib.path(egg) if egg
    arr[7] = UniLib.path(egg_f) if egg_f
  end

  def self.redirect_pkmn_cry(species, form, cry)
    return if UniLib.cached(UniLib::ASSET)
    arr = (form == :ALL) ?
            (PKMN_REDIRECT[species] ||= [nil, nil, nil, nil, nil, nil, nil, nil]) :
            (PKMN_REDIRECT[[species, form]] ||= [nil, nil, nil, nil, nil, nil, nil, nil])
    arr[8] = "../../" + UniLib.path(cry)
  end

  def self.set_bmp_debug_log(default=true)
    $unilib_bmp_asset_log = default
  end

  def self.set_audio_debug_log(default=true)
    $unilib_audio_asset_log = default
  end

  def self.register_bgm_provider(type, bgms, persistent=false)
    return if UniLib.cached(UniLib::ASSET)
    id = (persistent and BGM_REGISTRY_OLD[type]) ? BGM_REGISTRY_OLD[type][1] : -1
    BGM_REGISTRY_OLD[type] = BGM_REGISTRY[type] = [bgms, id]
  end

end

class LazyBitmap

  def initialize(path)
    @path = path
  end

  def get
    @bmp = AnimatedBitmap.new(@path) unless defined? @bmp
    @bmp = AnimatedBitmap.new(@path) if @bmp.disposed?
    @bmp
  end

  def bmp
    @bmp = AnimatedBitmap.new(@path) unless defined? @bmp
    @bmp = AnimatedBitmap.new(@path) if @bmp.disposed?
    @bmp.bitmap
  end

  def dispose
    @bmp.dispose if @bmp
  end

  def bitmap
    bmp
  end

end