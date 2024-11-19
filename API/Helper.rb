# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module UniLib

  def self.get_form_number(holder, form)
    return [form, FORM_MAP[holder][form]] if form.is_a? Integer
    form_str = nil
    if form.is_a? String
      UniLib.include "Pokemon"
      tmp = FORM_MAP[holder][form_str = form + " Form"]
      tmp = FORM_MAP[holder][form_str = form + " Forme"] if tmp.nil?
      tmp = FORM_MAP[holder][form_str = form + " Rotom"] if tmp.nil?
      tmp = FORM_MAP[holder][form_str = form + " Mode"] if tmp.nil?
      tmp = FORM_MAP[holder][form_str = form] if tmp.nil?
      form = tmp
    end
    [form, form_str]
  end

  def self.deep_copy(object)
    Marshal.load(Marshal.dump(object))
  end

  def self.damage_pkmn(pkmn, dmg, message=nil)
    pkmn.battle.scene.pbDamageAnimation(pkmn,0)
    pkmn.pbReduceHP(dmg)
    pkmn.battle.pbDisplay(message)
    pkmn.pbFaint if pkmn.isFainted?
  end

  def self.get_opposing(pkmn)
    pkmn.battle.battlers[[1, 0, 3, 2][pkmn.index]]
  end

  def self.is_status_move(move)
    move = move.move if move.is_a? PokeBattle_Move
    PBStuff::BURNMOVE.include?(move) || PBStuff::PARAMOVE.include?(move) || PBStuff::SLEEPMOVE.include?(move) || PBStuff::SCREENMOVE.include?(move)
  end

  def self.category(s)
    yield
  end

end