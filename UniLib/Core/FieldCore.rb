# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)
UniLib.include "Asset"

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  def self.field_hash_to_hash(origin, dest, field1, field2, key, &block)
    (dest[field2] ||= {})[key] = block&.call(origin[field1].clone) || origin[field1].clone if origin[field1]
  end

  def self.field_hash_to_hash_inverted(origin, dest, field1, field2, key, &block)
    ((dest[field2] ||= {})[block&.call(origin[field1].clone) || origin[field1].clone] ||= []).push(key) if origin[field1]
  end

  FIELD_DATA_RAW = load_data("Data/fields.dat")

  FIELD_DATA = FIELD_DATA_RAW.reduce({}) { |fields, (key, data)|
    d = (fields[key] ||= {})
    d[:name] = data.name.clone
    d[:fieldMessage] = data.message.clone
    d[:graphic] = data.graphic.clone
    d[:secretPower] = data.secretPower.clone
    d[:naturePower] = data.naturePower.clone
    d[:mimicry] = data.mimicry.clone
    d[:burmyCloak] = data.burmyCloak.clone
    d[:statusBuffs] = data.statusBuffs
    d[:statusNerfs] = data.statusNerfs
    d[:seed] = data.seeddata.clone
    d[:changeCondition] = data.fieldchangeconditions

    data.fieldmovedata.each { |move, dt|
      field_hash_to_hash_inverted(dt, d, :mult, :damageMods, move)
      field_hash_to_hash_inverted(dt, d, :typemod, :typeMods, move)
      field_hash_to_hash_inverted(dt, d, :accmod, :accuracyMods, move)
      field_hash_to_hash_inverted(dt, d, :multtext, :moveMessages, move) { |n| data.movemessagelist[n - 1] }
      field_hash_to_hash_inverted(dt, d, :counterincrease, :fieldCounterIncreases, move)
      field_hash_to_hash_inverted(dt, d, :moveeffect, :moveEffects, move)
      field_hash_to_hash_inverted(dt, d, :fieldchange, :fieldChange, move)
      field_hash_to_hash_inverted(dt, d, :changetext, :changeMessage, move) { |n| data.changemessagelist[n - 1] }
      field_hash_to_hash_inverted(dt, d, :changeeffect, :changeEffects, move)
      (d[:dontChangeBackup] ||= []).push(move) if dt[:dontchangebackup]
    }

    data.fieldtypedata.each { |type, dt|
      field_hash_to_hash_inverted(dt, d, :mult, :typeBoosts, type)
      field_hash_to_hash_inverted(dt, d, :typemod, :typeAddOns, type)
      field_hash_to_hash_inverted(dt, d, :typeeffect, :typeEffects, type)
      field_hash_to_hash_inverted(dt, d, :multtext, :typeMessages, type) { |n| data.typemessagelist[n - 1] }
      field_hash_to_hash_inverted(dt, d, :condition, :typeCondition, type)
    }

    if data.overlay
      d = (d[:overlay] = {})
      d[:statusBuffs] = data.overlayStatusBuffs.clone if data.overlayStatusBuffs
      d[:statusNerfs] = data.overlayStatusNerfs.clone if data.overlayStatusNerfs

      data.overlaymovedata.each { |move, dt|
        field_hash_to_hash_inverted(dt, d, :mult, :damageMods, move)
        field_hash_to_hash_inverted(dt, d, :multtext, :moveMessages, move) { |n| data.overlaymovemessagelist[n - 1] }
        field_hash_to_hash_inverted(dt, d, :typemod, :typeMods, move)
      }

      data.overlaytypedata.each { |type, dt|
        field_hash_to_hash_inverted(dt, d, :mult, :typeBoosts, type)
        field_hash_to_hash_inverted(dt, d, :multtext, :typeMessages, type){ |n| data.overlaytypemessagelist[n - 1] }
        field_hash_to_hash_inverted(dt, d, :condition, :typeCondition, type)
      }
    end

    fields
  } unless defined? FIELD_DATA

  MODIFIED_FIELDS = {}

end

class FieldModifier

  include UniLib

  attr_accessor :data

  private

  def initialize(data)
    @data = data
  end

  def set_value(key, value)
    if value == :delete
      @data.delete(key)
    elsif !value.nil?
      @data[key] = value
    end
  end

  def set_hash(key, key2, value, hash = @data)
    if value == :delete
      (hash[key] ||= {}).delete key2
    elsif !value.nil?
      (hash[key] ||= {})[key2] = value
    end
  end

  def set_hash_inverted(key, key2, value, hash = @data)
    if value == :delete
      (hash[key] ||= {}).each { |_, v| v.delete key2 }
    elsif !value.nil?
      ((hash[key] ||= {})[value] ||= []).push key2
    end
  end

  def set_array(key, value, index, hash = @data)
    case index
    when :delete then (hash[key] ||= []).delete(value)
    when :push then (hash[key] ||= []).push(value)
    else (hash[key] ||= [])[[hash[key].length, index].min] = value
    end if value
  end

  def set_array_inverted(key, value, add, hash = @data)
    if add == true
      (hash[key] ||= []).push(value)
    elsif add == false
      (hash[key] ||= []).delete(value)
    end
  end

  def set_array_inverted_overlay(key, value, add)
    d = (@data[:overlay] ||= {})
    if add == true
      (d[key] ||= []).push(value)
    elsif add == false
      (d[key] ||= []).delete(value)
    end
  end

  def self.build(key, fieldMessages, data)
    field = FEData.new

    field.name = data[:name]
    fieldMessages.push data[:name]
    field.fieldAppSwitch = data[:fieldAppSwitch]
    field.message = data[:fieldMessage]
    fieldMessages.push data[:fieldMessage]
    field.secretPower = data[:secretPower]
    field.graphic = data[:graphic]
    field.naturePower = data[:naturePower]
    field.mimicry = data[:mimicry]
    field.burmyCloak = data[:burmyCloak]
    field.statusBuffs = data[:statusBuffs]
    field.statusNerfs = data[:statusNerfs]
    field.overlayStatusBuffs = data[:overlay][:statusBuffs] if data[:overlay]
    field.overlayStatusNerfs = data[:overlay][:statusNerfs] if data[:overlay]

    movetypemod = pbHashForwardizer(data[:typeMods]) || {}
    movedamageboost = pbHashForwardizer(data[:damageMods]) || {}
    moveaccuracyboost = pbHashForwardizer(data[:accuracyMods]) || {}
    counterincreases = pbHashForwardizer(data[:fieldCounterIncreases]) || {}
    moveeffects = pbHashForwardizer(data[:moveEffects]) || {}
    typedamageboost = pbHashForwardizer(data[:typeBoosts]) || {}
    typetypemod = pbHashForwardizer(data[:typeAddOns]) || {}
    fieldchange = pbHashForwardizer(data[:fieldChange]) || {}
    changeeffects = pbHashForwardizer(data[:changeEffects]) || {}
    typecondition = data[:typeCondition] ? data[:typeCondition] : {}
    typeeffects = data[:typeEffects] ? data[:typeEffects] : {}
    changecondition = data[:changeCondition] ? data[:changeCondition] : {}
    dontchangebackup = data[:dontChangeBackup] ? data[:dontChangeBackup] : {}
    if data[:overlay]
      overlaydamage = pbHashForwardizer(data[:overlay][:damageMods]) || {}
      overlaytypemod = pbHashForwardizer(data[:overlay][:typeMods]) || {}
      overlaytypeboost = pbHashForwardizer(data[:overlay][:typeBoosts]) || {}
      overlaytypecons = data[:overlay][:typeCondition] ? data[:overlay][:typeCondition] : {}
    end

    movemessages  = data[:moveMessages]  || {}
    typemessages  = data[:typeMessages]  || {}
    changemessage = data[:changeMessage] || {}
    overlaymovemsg = data[:overlay][:moveMessages] || {} if data[:overlay]
    overlaytypemsg = data[:overlay][:typeMessages] || {} if data[:overlay]
    movemessagelist = []
    typemessagelist = []
    changemessagelist = []
    olmovemessagelist = []
    oltypemessagelist = []
    messagearray = [movemessages, typemessages, changemessage]
    messagearray = [movemessages, typemessages, changemessage, overlaymovemsg, overlaytypemsg] if data[:overlay]
    messagearray.each_with_index { |hashdata, index|
      messagelist = hashdata.keys
      fieldMessages.push *messagelist
      newhashdata = {}
      hashdata.each { |key, value|
        newhashdata[messagelist.index(key) + 1] = value
      }
      invhash = pbHashForwardizer(newhashdata)
      case index
      when 0
        movemessagelist = messagelist
        movemessages = invhash
      when 1
        typemessagelist = messagelist
        typemessages = invhash
      when 2
        changemessagelist = messagelist
        changemessage = invhash
      when 3
        olmovemessagelist = messagelist
        overlaymovemsg = invhash
      when 4
        oltypemessagelist = messagelist
        overlaytypemsg = invhash
      end
    }

    keys = (movedamageboost.keys << movetypemod.keys << moveaccuracyboost.keys << counterincreases.keys << moveeffects.keys << fieldchange.keys).flatten
    fieldmovedata = {}
    for move in keys
      movedata = {}
      movedata[:mult] = movedamageboost[move] if movedamageboost[move]
      movedata[:typemod] = movetypemod[move] if movetypemod[move]
      movedata[:accmod] = moveaccuracyboost[move] if moveaccuracyboost[move]
      movedata[:multtext] = movemessages[move] if movemessages[move]
      movedata[:counterincrease] = counterincreases[move] if counterincreases[move]
      movedata[:moveeffect] = moveeffects[move] if moveeffects[move]
      movedata[:fieldchange] = fieldchange[move] if fieldchange[move]
      movedata[:changetext] = changemessage[move] if changemessage[move]
      movedata[:changeeffect] = changeeffects[move] if changeeffects[move]
      movedata[:dontchangebackup] = dontchangebackup.include?(move)
      fieldmovedata[move] = movedata
    end
    # now, types!
    fieldtypedata = {}
    keys = (typedamageboost.keys << typetypemod.keys << typeeffects.keys).flatten
    for type in keys
      typedata = {}
      typedata[:mult] = typedamageboost[type] if typedamageboost[type]
      typedata[:typemod] = typetypemod[type] if typetypemod[type]
      typedata[:typeeffect] = typeeffects[type] if typeeffects[type]
      typedata[:multtext] = typemessages[type] if typemessages[type]
      typedata[:condition] = typecondition[type] if typecondition[type]
      fieldtypedata[type] = typedata
    end
    if data[:overlay]
      overlaymovedata = {}
      keys = (overlaydamage.keys << overlaytypemod.keys).flatten
      for move in keys
        movedata = {}
        movedata[:mult] = overlaydamage[move] if overlaydamage[move]
        movedata[:typemod] = overlaytypemod[move] if overlaytypemod[move]
        movedata[:multtext] = overlaymovemsg[move] if overlaymovemsg[move]
        overlaymovedata[move] = movedata
      end
      overlaytypedata = {}
      keys = overlaytypeboost.keys
      for type in keys
        typedata = {}
        typedata[:mult] = overlaytypeboost[type] if overlaytypeboost[type]
        typedata[:multtext] = overlaytypemsg[type] if overlaytypemsg[type]
        typedata[:condition] = overlaytypecons[type] if overlaytypecons[type]
        overlaytypedata[type] = typedata
      end
    end

    # seeds for good measure.
    seeddata = data[:seed]
    fieldMessages.push seeddata[:message] if seeddata[:message]
    field.fieldtypedata = fieldtypedata
    field.fieldmovedata = fieldmovedata
    field.seeddata = seeddata
    field.movemessagelist = movemessagelist
    field.typemessagelist = typemessagelist
    field.changemessagelist = changemessagelist
    field.fieldchangeconditions = changecondition
    field.overlay = true if data[:overlay] && ![0, nil, :INDOOR].include?(key)
    field.overlaytypedata = overlaytypedata if overlaytypedata
    field.overlaymovedata = overlaymovedata if overlaymovedata
    field.overlaymovemessagelist = olmovemessagelist if olmovemessagelist
    field.overlaytypemessagelist = oltypemessagelist if oltypemessagelist

    field
  end

end

# ======================================================================================================================================== #
# ================================================================ EVENTS ================================================================ #
# ======================================================================================================================================== #

unless UniLib.lib_loaded(__FILE__)

  def compile_fields(save)
    messages = []
    keys = UniLib::FIELD_DATA.keys | UniLib::MODIFIED_FIELDS.keys
    keys.each { |k| $cache.FEData[k] = FieldModifier.build(k, messages, (UniLib::MODIFIED_FIELDS[k]&.data || UniLib::FIELD_DATA[k])) }
    MessageTypes.setMessagesAsHash(:FieldMessages, messages)
  end

end

UniLib.add_play_event(:compile_fields, 1001)
