# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

PENDING_DELETIONS = []
PENDING_INSERTIONS = []
METHOD_MODS = {} if !defined? METHOD_MODS or UNILIB_CLEAR_INJECTOR_CACHE
NO_OP = {}
SUB_2 = "../../"
MOD_DIR = "#{File.dirname(__FILE__)}/#{SUB_2}"
EVENT_ON_PLAY = []
EVENT_ON_SAVE = []
EVENT_ON_NEW_FILE = []

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
    temp, line = clazz.instance_method(method).source_location rescue clazz.method(method).source_location
  end
  file = temp
  file = "#{MOD_DIR}#{temp}.rb" unless File.exists?(file)
  file = "#{MOD_DIR}#{SUB_2}Scripts/Rejuv/#{temp}.rb" unless File.exists?(file)
  file = "#{MOD_DIR}#{SUB_2}Scripts/#{temp}.rb" unless File.exists?(file)
  if File.exists?(file)
    lines, code, code_lines, valid = IO.foreach(file).to_a, "", [], false
    (line - 1..lines.length).each do |index|
      current = lines[index].strip
      next if current.start_with?("#")
      if current.include?("#")
        tmp = current.split(/#(?=([^"\\]*(\\.|"([^"\\]*\\.)*[^"\\]*"))*[^"]*$)/)
        current = tmp[0] if tmp.length > 0
      end
      next if current.empty? or current.length == 0
      current.split(/;/).each do |str|
        code += str + "\n"
        code_lines.push(str)
        valid = valid_expression(code) if str.include?("end")
        break if valid
      end
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

# ======================================================================================================================================== #
# ================================================================ PATCH ================================================================= #
# ======================================================================================================================================== #

CODE_SOURCE = ""

LOAD_HOOK_INSERTION = [:PokemonLoad, :startPlayingSaveFile, "$game_player.center($game_player.x, $game_player.y)", "EVENT_ON_PLAY.each { |fixer| method(fixer[0]).call }", 0, false, 100000]
FIXER_HOOK_INSERTION = [:PokemonLoad, :pbStartLoadScreen, "saveClientData", "EVENT_ON_NEW_FILE.each { |fixer| method(fixer[0]).call }", 0, false, 100000]
SAVE_HOOK_INSERTION = [:Object, :saveNew, "end", "EVENT_ON_SAVE.each { |saver| method(saver[0]).call }", 0, false, 100000]

entrypoint = method(:pbCallTitle)
define_method(:pbCallTitle) do
  UNILIB_LOADED.clear
  ret = entrypoint.()
  if defined? $code_injector_aggressive_cache and CACHE_AGGRESSIVE
    t = Time.now
    $code_injector_aggressive_cache.each { |clazz, source| clazz.class_eval(source) }
    unilib_log("aggressive insertion cache compile time:", Time.now - t)
  end
  unless CACHE_AGGRESSIVE and defined? $code_injector_aggressive_cache
    $code_injector_aggressive_cache = {} if CACHE_AGGRESSIVE
    EVENT_ON_PLAY.sort! { |a, b| b[1] <=> a[1]}
    EVENT_ON_SAVE.sort! { |a, b| b[1] <=> a[1]}
    insertions = Time.now
    PENDING_INSERTIONS += [LOAD_HOOK_INSERTION, FIXER_HOOK_INSERTION, SAVE_HOOK_INSERTION]
    PENDING_INSERTIONS.sort! { |a, b| b[6] <=> a[6]}
    PENDING_INSERTIONS.each { |pending| insert_in_method_internal(pending[0], pending[1], pending[2], pending[3], pending[4], pending[5]) }
    deletions = Time.now
    PENDING_DELETIONS.sort! { |a, b| b[4] <=> a[4]}
    PENDING_DELETIONS.each { |pending| delete_in_method_internal(pending[0], pending[1], pending[2], pending[3]) }
    method_mods = Time.now
    METHOD_MODS.each do |clazz, methods|
      CODE_SOURCE = ""
      methods.each do |_, ref|
        ref[:CODE].each do |num, line|
          CODE_SOURCE += line + "\n" unless ref[:DELETE] and ref[:DELETE][num]
          unless ref[:INJECT].nil?
            ref[:INJECT][-1].each { |injected| CODE_SOURCE += injected + "\n" } if num == 0 unless ref[:INJECT][-1].nil?
            ref[:INJECT][num].each { |injected| CODE_SOURCE += injected + "\n" } unless ref[:INJECT][num].nil?
            ref[:INJECT][-2].each { |injected| CODE_SOURCE += injected + "\n" } if num == ref[:CODE].length - 2 unless ref[:INJECT][-2].nil?
          end
        end
        ref[:INJECT].clear if ref[:INJECT]
        ref[:DELETE].clear if ref[:DELETE]
      end
      clazz.class_eval(CODE_SOURCE)
      methods.delete_if { |method| method.is_a? Proc}
      $code_injector_aggressive_cache[clazz] = CODE_SOURCE if CACHE_AGGRESSIVE
    end
    end_compile = Time.now
    unilib_log("staging insertions=#{deletions - insertions}", "staging deletions=#{method_mods - deletions}", "compilation=#{end_compile - method_mods}")
  end
  ret
end