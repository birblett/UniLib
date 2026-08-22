# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

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

  def self.heal_pkmn(pkmn, amount, liquid_ooze, message=nil)
    if liquid_ooze
      amount *= 2 if [:WASTELAND, :MURKWATERSURFACE, :CORRUPTED].include?(pkmn.battle.FE)
      pkmn.pbReduceHP(amount, true)
      pkmn.battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", pkmn.pbThis))
    else
      amount = (amount * (Rejuv && pkmn.battle.FE == :GRASSY ? 1.6 : 1.3)).floor if pkmn.hasWorkingItem(:BIGROOT)
      amount = (amount * 1.3).floor if pkmn.crested == :SHIINOTIC
      pkmn.pbRecoverHP(amount, true)
      UniLib.display_if_visible(pkmn.battle, message)
    end
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
    battle.pbDisplay(text) if text and battle.scene and battle.scene.sprites["messagebox"]
  end

  def self.with_ability_box(pkmn, item: nil, attrname: nil, crest: nil, &block)
    pkmn.battle.pbShowAbilityBox(pkmn, item: item, attrname: attrname, crest: crest)
    block.call
    pkmn.battle.pbHideAbilityBox(pkmn)
  end

  def self.obj_print(obj, depth=0, label=nil, tree=[])
    UniLib.dev_file_open if depth == 0
    return if tree.include? obj
    name = label ? "#{label} " : ""
    if obj.is_a? Array
      if obj.length > 0
        UniLib.dev_log("  " * depth + "#{obj.class} #{name}= [")
        obj.each_with_index{ |v, i| obj_print(v, depth + 1, "#{i}", tree + [obj]) }
        UniLib.dev_log("  " * depth + "]")
      else
        UniLib.dev_log("  " * depth + "#{obj.class} #{name}= []")
      end
    elsif obj.is_a? Hash
      if obj.length > 0
        UniLib.dev_log("  " * depth + "#{obj.class} #{name}= {")
        obj.each{ |k, v| obj_print(v, depth + 1, "#{k.is_a?(Symbol) ? ":" : ""}#{k}", tree + [obj]) }
        UniLib.dev_log("  " * depth + "}")
      else
        UniLib.dev_log("  " * depth + "#{obj.class} #{name}{}")
      end
    elsif (vars = obj.instance_variables).length > 0
      UniLib.dev_log("  " * depth + "#{obj.class} #{name}= (")
      vars.each { |var| obj_print(obj.instance_variable_get(var), depth + 1, var, tree + [obj]) }
      UniLib.dev_log("  " * depth + ")")
    elsif obj.is_a? String
      UniLib.dev_log("  " * depth + "#{obj.class} #{name}= \"#{obj}\"")
    elsif obj.is_a? Symbol
      UniLib.dev_log("  " * depth + "#{obj.class} #{name}= :#{obj}")
    else
      UniLib.dev_log("  " * depth + "#{obj.class} #{name}= #{obj}")
    end
    UniLib.dev_file_close if depth == 0
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