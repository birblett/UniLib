# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.7, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #
module UniLib

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
        s[0] += "  " * depth + "#{obj.class} #{name}= [\n"
        obj.each_with_index{ |v, i| obj_print(v, depth + 1, "#{i}", false, s) }
        s[0] += "  " * depth + "]\n"
      else
        s[0] += "  " * depth + "#{obj.class} #{name}= []\n"
      end
    elsif obj.instance_of? Hash
      if obj.length > 0
        s[0] += "  " * depth + "#{obj.class} #{name}= {\n"

        obj.each{ |k, v| obj_print(v, depth + 1, "#{k.is_a?(Symbol) ? ":" : ""}#{k}", false, s) }
        s[0] += "  " * depth + "}\n"
      else
        s[0] += "  " * depth + "#{obj.class} #{name}{}\n"
      end
    elsif (vars = obj.instance_variables).length > 0
      s[0] += "  " * depth + "#{obj.class} #{name}= (\n"
      vars.each { |var| obj_print(obj.instance_variable_get(var), depth + 1, var, false, s) }
      s[0] += "  " * depth + ")\n"
    elsif obj.is_a? String
      s[0] += "  " * depth + "#{obj.class} #{name}= \"#{obj}\"\n"
    elsif obj.is_a? Symbol
      s[0] += "  " * depth + "#{obj.class} #{name}= :#{obj}\n"
    else
      s[0] += "  " * depth + "#{obj.class} #{name}= #{obj}\n"
    end
    UniLib.dev_log(s[0]) if start
  end

  def self.print_obj(obj)
    self.obj_print(obj)
  end

end

class NumberContainer

  def self.of(*numbers)
    numbers.map { |n| new(n) }
  end

  def initialize(number)
    @number = number
  end

  def set(other)
    @number = other
  end

  def +(other)
    @number + other
  end

  def -(other)
    @number - other
  end

  def *(other)
    @number * other
  end

  def /(other)
    @number / other
  end

  def add(other)
    @number += other
  end

  def sub(other)
    @number -= other
  end

  def mul(other)
    @number *= other
  end

  def div(other)
    @number /= other
  end

  def ==(other)
    @number == other
  end

  def >=(other)
    @number >= other
  end

  def <=(other)
    @number <= other
  end

  def >(other)
    @number > other
  end

  def <(other)
    @number < other
  end

  def value
    @number
  end

end