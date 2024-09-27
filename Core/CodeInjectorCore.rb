# ==================================================================================================================== #
# =================================================== DEPENDENCIES =================================================== #
# ==================================================================================================================== #

verify_version(0.4, File.basename(__FILE__).gsub!(".rb", ""))

# ==================================================================================================================== #
# ================================================== INTERNAL/CORE =================================================== #
# ==================================================================================================================== #

PENDING_DELETIONS = []
PENDING_INSERTIONS = []
METHOD_MODS = {}
NO_OP = {}
SUB_2 = "../../"
MOD_DIR = "#{File.dirname(__FILE__)}/#{SUB_2}"
EVENT_ON_PLAY = []
EVENT_ON_SAVE = []

def get_or_create_method_attr(clazz, method, sym, default)
  METHOD_MODS[clazz][method][sym] = default if METHOD_MODS[clazz][method][sym].nil?
  METHOD_MODS[clazz][method][sym]
end

def get_or_create_method(clazz, method, base)
  METHOD_MODS[clazz] = {} if METHOD_MODS[clazz].nil?
  METHOD_MODS[clazz][method] = {} if METHOD_MODS[clazz][method].nil?
  METHOD_MODS[clazz][method][:CODE] = base.each_with_index.map { |line, num| [num, line] }.to_h if METHOD_MODS[clazz][method][:CODE].nil?
end

def delete_in_method_internal(clazz, method, target, index)
  clazz = Kernel.const_get(clazz) if clazz.is_a? Symbol
  base = (METHOD_MODS[clazz].nil? or METHOD_MODS[clazz][method].nil? or METHOD_MODS[clazz][method][:CODE].nil?) ? get_method_source(clazz, method) : METHOD_MODS[clazz][method][:CODE].values
  deletion_index = get_target_index(base, target, index)
  get_or_create_method(clazz, method, base)
  get_or_create_method_attr(clazz, method, :DELETE, {})[deletion_index] = true unless deletion_index.nil?
  !deletion_index.nil?
end

def insert_in_method_internal(clazz, method, target, proc, index, prepend)
  clazz = Kernel.const_get(clazz) if clazz.is_a? Symbol
  base = (METHOD_MODS[clazz].nil? or METHOD_MODS[clazz][method].nil? or METHOD_MODS[clazz][method][:CODE].nil?) ? get_method_source(clazz, method) : METHOD_MODS[clazz][method][:CODE].values
  inserted = proc.class == String ? [""] + proc.split("\n") + [""] : get_method_source(nil, proc)
  insertion_index = get_target_index(base, target, index)
  insertion_index -= 1 if prepend
  get_or_create_method(clazz, method, base)
  injected = get_or_create_method_attr(clazz, method, :INJECT, {})
  injected[insertion_index] = [] if injected[insertion_index].nil?
  injected[insertion_index] += inserted[(1...inserted.length - 1)]
  return false if insertion_index.nil?
  true
rescue NoMethodError
  unidev_log("Failed to insert in method ", method, "of class", clazz, "at target \"", target,"\"")
end

def get_target_index(base, target, index)
  insertion_index = nil
  insertion_index = -1 if target == :HEAD
  insertion_index = -2 if target == :TAIL
  if insertion_index.nil?
    base.each_with_index do |line, i|
      if line.strip == target.strip
        return i if index == 0
        index -= 1
      end
    end
  end
  insertion_index
end

def get_method_source(clazz, method)
  if method.is_a? Proc
    temp, line = method.source_location
  else
    clazz = Kernel.const_get(clazz) if clazz.is_a? Symbol
    temp, line = clazz.method(method).source_location rescue clazz.instance_method(method).source_location
  end
  file = temp
  file = "#{MOD_DIR}#{temp}.rb" unless File.exists?(file)
  file = "#{MOD_DIR}#{SUB_2}Scripts/#{temp}.rb" unless File.exists?(file)
  file = "#{MOD_DIR}#{SUB_2}Scripts/Rejuv/#{temp}.rb" unless File.exists?(file)
  if File.exists?(file)
    lines = []
    File.readlines(file, chomp: true).each { |l| lines.push(l) }
    code = ""
    code_lines = []
    valid = false
    (line - 1..lines.length).each do |index|
      current = lines[index].strip
      if not current.start_with?("#") and current.include?("#")
        tmp = current.split(/#(?=([^"\\]*(\\.|"([^"\\]*\\.)*[^"\\]*"))*[^"]*$)/)
        current = tmp[0] if tmp.length > 0
      end
      current.split(/;/).each do |str|
        code += str + "\n"
        code_lines.push(str)
        valid = valid_expression(code) if str.include? "end"
        break if valid
      end unless current.empty? or current.length == 0 or current.start_with?("#")
      break if valid
    end
    return valid ? code_lines : nil
  end
rescue Exception
  nil
end

def valid_expression(str)
  catch(:valid) do
    eval("BEGIN{throw :valid}\n#{str}")
  end
  str !~ /[,\\]\s*\z/
rescue Exception
  false
ensure
  true
end

# ==================================================================================================================== #
# ====================================================== PATCH ======================================================= #
# ==================================================================================================================== #

entrypoint = method(:pbCallTitle)
define_method(:pbCallTitle) do
  UNILIB_LOADED.clear
  ret = entrypoint.()
  EVENT_ON_PLAY.sort! { |a, b| b[1] <=> a[1]}
  EVENT_ON_SAVE.sort! { |a, b| b[1] <=> a[1]}
  insertions = Time.now
  PENDING_INSERTIONS.push([:PokemonLoad, :startPlayingSaveFile, "$game_player.center($game_player.x, $game_player.y)", proc do
    EVENT_ON_PLAY.each { |fixer| method(fixer[0]).call }
  end, 0, false, 100000])
  PENDING_INSERTIONS.push([:Object, :saveNew, "end", proc do
    EVENT_ON_SAVE.each { |saver| method(saver[0]).call }
  end, 0, false, 100000])
  PENDING_INSERTIONS.sort! { |a, b| b[6] <=> a[6]}
  PENDING_INSERTIONS.each do |pending|
    insertions = Time.now
    out = insert_in_method_internal(pending[0], pending[1], pending[2], pending[3], pending[4], pending[5])
    unilib_log("Insertion on class: #{pending[0]} - ", "method: #{pending[1]} - ", "time taken: #{Time.now - insertions} - ", "result: #{out} - ", "target:", pending[2])
  end
  deletions = Time.now
  PENDING_DELETIONS.sort! { |a, b| b[4] <=> a[4]}
  PENDING_DELETIONS.each do |pending|
    delete_in_method_internal(pending[0], pending[1], pending[2], pending[3])
  end
  method_mods = Time.now
  METHOD_MODS.each do |clazz, methods|
    source = ""
    methods.each do |_, ref|
      ref[:CODE].each do |num, line|
        source += line + "\n" unless ref[:DELETE] and ref[:DELETE][num]
        unless ref[:INJECT].nil?
          ref[:INJECT][-1].each { |injected| source += injected + "\n" } if num == 0 unless ref[:INJECT][-1].nil?
          ref[:INJECT][num].each { |injected| source += injected + "\n" } unless ref[:INJECT][num].nil?
          ref[:INJECT][-2].each { |injected| source += injected + "\n" } if num == ref[:CODE].length - 2 unless ref[:INJECT][-2].nil?
        end
      end
    end
    clazz.class_eval(source)
  end
  end_compile = Time.now
  unilib_log("staging insertions=#{deletions - insertions}", "staging deletions=#{method_mods - deletions}", "compilation=#{end_compile - method_mods}")
  ret
end