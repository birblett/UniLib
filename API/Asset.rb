# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module Assets

  def self.redirect(type, base, target=nil, &block)
    return if target.nil? and block.nil?
    case type
    when :BMP then ANIMATED_BITMAP_REDIRECT[base] = block ? ["Data/Mods/", block] : "Data/Mods/#{target}"
    when :AUDIO then AUDIO_FILE_REDIRECT[base] = block ? ["../../Data/Mods/", block] : "../../Data/Mods/#{target}"
    else print "Unsupported asset redirection type: #{type}"
    end
    self
  end

  def self.set_bmp_debug_log(default=true)
    $unilib_bmp_asset_log = default
  end

  def self.set_audio_debug_log(default=true)
    $unilib_audio_asset_log = default
  end

  def self.register_bgm_provider(type, bgms, persistent=false)
    id = (persistent and BGM_REGISTRY[type]) ? BGM_REGISTRY[type][1] : -1
    BGM_REGISTRY[type] = [bgms, id]
  end

end