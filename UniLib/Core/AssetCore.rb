# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  unless UniLib.cached(UniLib::ASSET)

    ANIMATED_BITMAP_REDIRECT = {}
    AUDIO_FILE_REDIRECT = {}
    PKMN_REDIRECT = {}

  end

  def self.get_redirected_asset(species, form, fem, egg, icon, audio = false)
    return nil unless (hash = PKMN_REDIRECT[[species, form]]) or (hash = PKMN_REDIRECT[species])
    if audio
      hash[8]
    else
      index = icon ? 4 : 0
      index += 2 if egg
      index += 1 if fem and fem != ""
      ret = hash[index]
      fem && ret.nil? ? hash[index - 1] : ret
    end
  end

end

module Assets

  include UniLib
  $unilib_bmp_asset_log = false unless defined? $unilib_bmp_asset_log
  $unilib_audio_asset_log = false unless defined? $unilib_audio_asset_log

  unless UniLib.cached(UniLib::ASSET)

    BGM_REGISTRY = {}
    BGM_REGISTRY_OLD = {} unless defined? BGM_REGISTRY_OLD

  end

  def self.get_asset(hash, str)
    out = hash[str]
    out = hash[str + ".mp3"] if out.nil?
    out = hash[str + ".ogg"] if out.nil?
    if out.is_a? Array
      res = out[1].call
      return false unless res
      out = out[0] + res
    end
    return false if out.nil?
    out.gsub!("../../", "") if str.start_with? "Audio"
    out
  end

  def self.bmp_redirect(file)
    return file unless file.is_a? String
    f = File.basename(file).gsub(/\.png/,"")
    f2 = Assets.get_asset(UniLib::ANIMATED_BITMAP_REDIRECT, f) if UniLib::ANIMATED_BITMAP_REDIRECT[f]
    f2 ? f2 : file
  end

  def self.log(str)
    str = str.name if str.is_a? RPG::AudioFile
    UniLib.dev_log(str) unless %w[bump menu Choose menuclose].include? str
  end

  def self.strip_bgm(str)
    str.gsub(/(Audio\/[^\/]*\/|\.\.\/\.\.\/|Data\/Mods\/)/, "")
  end

  def self.bgm_provider(type)
    proc do
      bgms = BGM_REGISTRY[type]
      next $game_system.playing_bgm.name if $game_system.playing_bgm and bgms[0].include?(Assets.strip_bgm($game_system.playing_bgm.name))
      bgms[1] = (bgms[0] - [BGM_REGISTRY[type][1]]).sample
    end
  end

end

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

module Audio

  UNILIB_BGM_PLAY_OLD = singleton_method(:bgm_play) unless defined? UNILIB_BGM_PLAY_OLD
  define_singleton_method(:bgm_play) do |file, v=100, p=100|
    Assets.log(file) if $unilib_audio_asset_log
    if UniLib::AUDIO_FILE_REDIRECT[file]
      file = Assets.get_asset(UniLib::AUDIO_FILE_REDIRECT, file)
      next if $game_system.playing_bgm and Assets.strip_bgm(file) == Assets.strip_bgm($game_system.playing_bgm.name) and $game_system.playing_bgm.volume == v and $game_system.playing_bgm.pitch == p
    end
    UNILIB_BGM_PLAY_OLD.(file, v, p)
  end

end

UniLib.insert_in_method(:AnimatedBitmap, :initialize, :HEAD, "file = Assets.bmp_redirect(file)")

UniLib.insert_in_method(:AnimatedBitmap, :setBitmap, :HEAD, "bitmap = Assets.bmp_redirect(bitmap)")

UniLib.insert_in_function(:pbStringToAudioFile, :HEAD, "str = Assets.get_asset(UniLib::AUDIO_FILE_REDIRECT, str) if UniLib::AUDIO_FILE_REDIRECT[str]")

UniLib.insert_in_function(:pbResolveAudioFile, "if str.is_a?(String)", "str = Assets.get_asset(UniLib::AUDIO_FILE_REDIRECT, str) if UniLib::AUDIO_FILE_REDIRECT[str]")

UniLib.insert_in_method(:Scene_Map ,:autofade , "actual_bgm_name = $previous_map.bgm.name.clone", "actual_bgm_name = Assets.get_asset(UniLib::AUDIO_FILE_REDIRECT, actual_bgm_name) if UniLib::AUDIO_FILE_REDIRECT[actual_bgm_name]; return if $game_system.playing_bgm and Assets.strip_bgm(actual_bgm_name) == Assets.strip_bgm($game_system.playing_bgm.name)")

UniLib.insert_in_function(:pbBGMPlay, "return if !param ",
  "s = param.is_a?(RPG::AudioFile) ? param.name : param
  if UniLib::AUDIO_FILE_REDIRECT[s]
    param = Assets.get_asset(UniLib::AUDIO_FILE_REDIRECT, s)
    return if $game_system.playing_bgm and Assets.strip_bgm(param) == Assets.strip_bgm($game_system.playing_bgm.name)
  end")

UniLib.insert_in_function(:pbCueBGM, "return if !bgm",
  "s = bgm.is_a?(RPG::AudioFile) ? bgm.name : bgm
  if UniLib::AUDIO_FILE_REDIRECT[s]
    bgm = Assets.get_asset(UniLib::AUDIO_FILE_REDIRECT, s)
    return if $game_system.playing_bgm and Assets.strip_bgm(bgm) == Assets.strip_bgm($game_system.playing_bgm.name)
  end")

UniLib.insert_in_function(:pbGetTrainerBattleBGM, "if $PokemonGlobal.nextBattleBGM", "p = $PokemonGlobal.nextBattleBGM; s = p.is_a?(RPG::AudioFile) ? p.name : p;  p = Assets.get_asset(UniLib::AUDIO_FILE_REDIRECT, s) if UniLib::AUDIO_FILE_REDIRECT[s]")

target = Reborn ? "music = $cache.trainertypes[trainertype].battleBGM" : "music=$cache.trainertypes[trainertype].battleBGM"
UniLib.insert_in_function(:pbGetTrainerBattleBGM, target,
  "if UniLib::AUDIO_FILE_REDIRECT[s]
    s = music.is_a?(RPG::AudioFile) ? music.name : music;  music = Assets.get_asset(UniLib::AUDIO_FILE_REDIRECT, s)
    return nil if $game_system.playing_bgm and Assets.strip_bgm(s) == Assets.strip_bgm($game_system.playing_bgm.name)
  end")

UniLib.insert_in_function(:pbPokemonBitmap, "bitmapFileName = sprintf(\"Graphics/Battlers/%03d%s\", dexnum, gendermod)",
  "ret = UniLib.get_redirected_asset(species, form, gender == \"Female\", false, false)
  if ret
    bitmapFileName = ret
    form = 0
  end")

UniLib.insert_in_function(:pbLoadPokemonBitmapSpecies, "x = pokemon.isShiny? ? 192 : 0",
  "ret = UniLib.get_redirected_asset(species, form, pokemon.gender == 1, pokemon.isEgg?, false)
  form = 0 if ret")

UniLib.insert_in_function_before(:pbLoadPokemonBitmapSpecies, "spritesheet = RPG::Cache.load_bitmap(bitmapFileName)",
  "bitmapFileName = ret if ret")

UniLib.insert_in_function(:pbPokemonIconBitmap, "filename = sprintf(\"Graphics/Icons/icon%03d%s%s\", species, girl, eggtag)",
  "ret = UniLib.get_redirected_asset(pokemon.species, form, girl, egg, true)
  if ret
    filename = ret
    form = 0
  end")

UniLib.insert_in_function(:pbCryFile, :HEAD,
  "ret = UniLib.get_redirected_asset(pokemon.species, pokemon.form, nil, nil, nil, true)
  return ret if ret and pbResolveAudioSE(ret)")

UniLib.replace_in_method(:Game_System, :se_play, "se.name = File.basename(se.name, File.extname(se.name))",
  "se.name.gsub!(/\\.ogg|\\.wav|\\.mp3/, \"\")")