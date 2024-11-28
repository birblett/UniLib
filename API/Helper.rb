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
    UniLib.display_if_visible(pkmn.battle, message)
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

  def self.display_if_visible(battle, text)
    battle.pbDisplay(text) if battle.scene and battle.scene.sprites["messagebox"]
  end

  def self.obj_print(obj, depth=0, label=nil, start=true, s=[""])
    name = label ? "#{label} " : ""
    if obj.instance_of? Array
      if obj.length > 0
        s[0] += "  " * depth + "#{obj.class} #{name}[\n"
        obj.each_with_index{ |v, i| obj_print(v, depth + 1, "#{i} = ", false, s) }
        s[0] += "  " * depth + "]\n"
      else
        s[0] += "  " * depth + "#{obj.class} #{name}= []\n"
      end
    elsif obj.instance_of? Hash
      if obj.length > 0
        s[0] += "  " * depth + "#{obj.class} #{name}= {\n"
        obj.each{ |k, v| obj_print(v, depth + 1, ":#{k} = ", false, s) }
        s[0] += "  " * depth + "}\n"
      else
        s[0] += "  " * depth + "#{obj.class} #{name}{}\n"
      end
    elsif (vars = obj.instance_variables).length > 0
      s[0] += "  " * depth + "#{obj.class} #{name}= (\n"
      vars.each { |var| obj_print(obj.instance_variable_get(var), depth + 1, var, false, s) }
      s[0] += "  " * depth + ")\n"
    else
      s[0] += "  " * depth + "#{obj.class} #{name}= #{obj}\n"
    end
    UniLib.dev_log(s[0]) if start
  end

end