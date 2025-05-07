# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  unless UniLib.lib_loaded(__FILE__)
    TRAINERS = load_data("Data/trainers.dat")
    BOSSES = load_data("Data/bossdata.dat")
  end
  TRAINER_DATA = {}
  BOSS_DATA = {}
  TRAINER_CACHE = {}
  BOSS_CACHE = {}
  $trainer_modifier_debug = false

end

class TrainerModifier

  include UniLib

  def get_trainer(tclass, name, id)
    TRAINERS[tclass][name].each { |a| return deep_copy(a) if a[0] == id }
  end

  def initialize(tclass, name, id, is_new)
    unless is_new or TRAINERS[tclass] or TRAINERS[tclass][name] or get_trainer(tclass, name, id)
      print "TrainerModifier: #{tclass} #{name} with team id #{id} doesn't exist"
      exit
    end
    TRAINER_CACHE[[tclass, name, id]] = true
    @is_new = is_new
    @tclass = tclass
    @name = name
    @id = id
    if is_new
      @pkmn = []
    else
      t = get_trainer(tclass, name, id)
      @pkmn = t[1]
      @items = t[2]
      @ace = t[3]
      @defeat = t[4]
      @effect = t[5]
    end
  end

  def build
    trainers = $cache.trainers
    trainers[@tclass] = {} unless trainers[@tclass]
    trainers[@tclass][@name] = [] unless trainers[@tclass][@name]
    if @is_new
      trainers[@tclass][@name].push([@id, @pkmn, @items, @ace, @defeat, @effect])
    else
      trainers[@tclass][@name].each_with_index do |trainer, i|
        if trainer[0] == @id
          trainers[@tclass][@name][i] = [@id, @pkmn, @items, @ace, @defeat, @effect]
          return
        end
      end
    end
  end

  def self.party_log(party)
    str = ""
    party[1].each_with_index do |pkmn, idx|
      str += "               .set_pkmn(#{idx}, :#{pkmn[:species]}, #{pkmn[:level]}, #{pkmn[:ability] ? ':' + pkmn[:ability].to_s : 'nil'}"
      unless pkmn.nil?
        pkmn.each do |k, v|
          case k
          when :species, :ability, :level then str += ")\n" if k == pkmn.keys.last; next
          else
            if v.is_a? String
              str += ", #{k}: #{'"' + v+ '"'}"
            elsif v.is_a? Symbol
              str += ", #{k}: :#{v}"
            else
              str += ", #{k}: #{v}"
            end
          end
          str += ")\n" if k == pkmn.keys.last
        end
      end
    end
    str += "               .set_items(#{party[2] ? party[2] : "nil"})\n"
    str += "               .set_ace(#{party[3] ? '"' + party[3] + '"' : "nil" })\n"
    str += "               .set_defeat(#{party[4] ? '"' + party[4] + '"' : "nil" })\n"
    str += "               .set_effects(#{party[5] ? party[5] : "nil"})\n"
    UniLib.dev_log(str)
  end

end

class BossModifier

  include UniLib

  BOSS_MULTIBILITY_HANDLER = proc { |pkmn| pkmn.is_a?(PokeBattle_Battler) and pkmn.isbossmon }

  def initialize(id, is_new)
    unless is_new or BOSSES[id]
      print "BossModifier: boss with #{id} doesn't exist"
      exit
    end
    @id = id
    BOSS_CACHE[@id] = true
    @is_new = is_new
    if is_new
      @name = id.to_s.gsub("_", " ").split.map(&:capitalize).join(' ')
      @pkmn = {}
      @shields = 0
      @immunities = nil
      @entry_text = "Test"
      @entry_effects = nil
      @break_effects = nil
      @sos_details = nil
      @capturable = nil
      @can_run = nil
    else
      boss = deep_copy(BOSSES[id])
      @name = boss.name
      @pkmn = boss.moninfo
      @shields = boss.shieldCount
      @immunities = boss.immunities
      @entry_text = boss.entryText
      @entry_effects = boss.onEntryEffects
      @break_effects = boss.onBreakEffects
      @sos_details = boss.sosDetails
      @capturable = boss.capturable
      @can_run = boss.canrun
    end
  end

  def build
    if @is_new
      data = {}
      data[:name] = @name
      data[:moninfo] = @pkmn
      data[:shieldCount] = @shields
      data[:immunities] = @immunities
      data[:entryText] = @entry_text
      data[:onEntryEffects] = @entry_effects
      data[:onBreakEffects] = @break_effects
      data[:sosDetails] = @sos_details
      data[:capturable] = @capturable
      data[:canrun] = @can_run
      $cache.bosses[@id] = BossData.new(@id, data)
    else
      boss = $cache.bosses[@id]
      boss.name = @name
      boss.moninfo = @pkmn
      boss.shieldCount = @shields
      boss.immunities = @immunities
      boss.entryText = @entry_text
      boss.onEntryEffects = @entry_effects
      boss.onBreakEffects = @break_effects
      boss.sosDetails = @sos_details
      boss.capturable = @capturable
      boss.canrun = @can_run
    end
  end

  def self.data_log(pkmn)
    boss = $cache.bosses[pkmn.bossId]
    s = "BossModifier.add(:#{pkmn.bossId})\n"
    # name
    s += "            .set_name(\"#{boss.name}\")\n"
    pk = boss.moninfo
    # moninfo
    s += "            .set_pkmn(:#{pk[:species]}, #{pk[:level]}, #{pk[:ability] ? ':' + pk[:ability].to_s : 'nil'}"
    pk.each do |k, v|
      case k
      when :species, :ability, :level then str += ")\n" if k == pk.keys.last; next
      else
        if v.is_a? String
          s += ", #{k}: #{'"' + v+ '"'}"
        elsif v.is_a? Symbol
          s += ", #{k}: :#{v}"
        else
          s += ", #{k}: #{v}"
        end
      end
      s += ")\n" if k == pk.keys.last
    end
    # shield count
    s += "            .set_shields(#{boss.shieldCount})\n"
    # immunities
    boss.immunities.each { |k, _| s += "            .set_immunity(:#{k})\n" } if boss.immunities
    # entry message
    s += "            .set_entry_text(\"#{boss.entryText}\")\n" if boss.entryText
    # entry effects
    if boss.onEntryEffects
      key0 = boss.onEntryEffects.keys[0]
      boss.onEntryEffects.each do |k, v|
        s += k == key0 ? "            .set_entry_effect(" : ", "
        if v.is_a? String
          add = "\"#{v}\""
        elsif v.is_a? Symbol
          add = ":#{v}"
        else
          add = "#{v}"
        end
        s += "#{k}: #{add}"
      end
      s += ")\n"
    end
    # break effects
    boss.onBreakEffects.each do |k, v|
      s += "            .set_break_effect(#{k}"
      v.each do |j, c|
        if c.is_a? String
          add = "\"#{c}\""
        elsif c.is_a? Symbol
          add = ":#{c}"
        else
          add = "#{c}"
        end
        s += ", #{j}: #{add}"
      end
      s += ")\n"
    end if boss.onBreakEffects
    # sos pokemon
    if boss.sosDetails
      s += "            .set_sos_condition(\"#{boss.sosDetails[:activationRequirement]}\")\n" if boss.sosDetails[:activationRequirement]
      s += "            .set_sos_continuous(#{boss.sosDetails[:continuous]})\n" unless boss.sosDetails[:continuous].nil?
      s += "            .set_sos_count(#{boss.sosDetails[:totalMonCount]})\n" if boss.sosDetails[:totalMonCount]
      boss.sosDetails[:moninfos].each do |num, pkinfo|
        s += "            .set_sos_pkmn(#{num}, :#{pkinfo[:species]}, #{pkinfo[:level]}, :#{pkinfo[:ability]}"
        pkinfo.each do |k, v|
          case k
          when :species, :ability, :level then s += ")\n" if k == pkinfo.keys.last; next
          else
            if v.is_a? String
              s += ", #{k}: #{'"' + v+ '"'}"
            elsif v.is_a? Symbol
              s += ", #{k}: :#{v}"
            else
              s += ", #{k}: #{v}"
            end
          end
          s += ")\n" if k == pkinfo.keys.last
        end
      end
    end
    # can run from
    s += "            .set_can_run(#{boss.canrun})" unless boss.canrun.nil?
    # can catch
    s += "            .set_capture(#{boss.capturable})" unless boss.capturable.nil?
    UniLib.dev_log(s)
  end

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

unless UniLib.lib_loaded(__FILE__)

  def register_modified_trainers
    UniLib::TRAINER_DATA.each { |_, trainer| trainer.build }
  end

  def register_modified_bosses
    UniLib::BOSS_DATA.each { |_, boss| boss.build }
  end

end

UniLib.add_play_event(:register_modified_trainers)
UniLib.add_play_event(:register_modified_bosses)

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

UniLib.insert_in_method(:PokeBattle_Battler, :pbInitBoss, "boss = bossdata[pkmn.bossId]", "BossModifier.data_log(pkmn) unless UniLib::BOSS_CACHE[pkmn.bossId] or pkmn.bossId == :SHADOWDEN")

UniLib.insert_in_function(:pbLoadTrainer, :HEAD, proc do |type, name, id, trainerid, trainername, partyid|
  type, name, id = trainerid, trainername, partyid if Rejuv
  unless UniLib::TRAINER_CACHE[[type, name, id]]
    UniLib.dev_log("TrainerModifier.add(:#{type}, \"#{name}\", #{id})")
    $cache.trainers[type][name].each do |i|
      next unless i
      if i[0] == id
        TrainerModifier.party_log(i)
        break
      end
    end
  end
end)

UniLib.insert_in_method(:PokeBattle_Battle, :pbShieldEffects, "case onBreakdata[:bossSideStatusChanges][0]",
  "when :BURN then canstatus = @battle.battlers[i].pbCanBurn?(false)")