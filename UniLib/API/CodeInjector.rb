# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

module UniLib
  
  <<-DOC
  >> useful functions and event hooks for cross-compatibility and simplicity. embedded in the standard api.
  DOC
  
  <<-DOC
  COMMON
  @param function - a symbol (i.e. :function) corresponding to a function bound to Object. this includes all global functions.
  @param clazz - a class containing the target method
  @param method - a symbol (i.e. :method) corresponding to a method bound to @clazz. this includes all global functions.
  @param target - a string or one of :HEAD or :TAIL. insertion will be after the first match, or after the definition with :HEAD and right 
                  before the last "end" with :TAIL
  @param proc - a Proc object. the body must be on its own lines.
  @param index - if nonzero, attempts to match a duplicate corresponding to the index (for example with multiple "ends")
  >> for injection, replacement, and deletion functions.
  DOC
  
  <<-DOC
  >> injects a block of code after the specified target in the target function.
  DOC
  def self.insert_in_function(function, target, proc, index=0, priority=$injector_global_priority)
    return if self.has_valid_cache
    self.insert_in_method(:Object, function, target, proc, index, priority)
  end
  
  <<-DOC
  >> injects a block of code after the specified target in the target method.
  DOC
  def self.insert_in_method(clazz, method, target, proc, index=0, priority=$injector_global_priority)
    return if self.has_valid_cache
    PENDING_INSERTIONS.push([clazz, method, target, proc, index, false, priority])
  end
  
  <<-DOC
  >> injects a block of code before the specified target in the target function.
  DOC
  def self.insert_in_function_before(function, target, proc, index=0, priority=$injector_global_priority)
    return if self.has_valid_cache
    self.insert_in_method_before(:Object, function, target, proc, index, priority)
  end
  
  <<-DOC
  >> injects a block of code before the specified target in the target method.
  DOC
  def self.insert_in_method_before(clazz, method, target, proc, index=0, priority=$injector_global_priority)
    return if self.has_valid_cache
    PENDING_INSERTIONS.push([clazz, method, target, proc, index, true, priority])
  end
  
  <<-DOC
  >> replaces a target line in the target function. chains with other operations.
  DOC
  def self.replace_in_function(function, target, proc, index=0, priority=$injector_global_priority)
    return if self.has_valid_cache
    self.replace_in_method(:Object, function, target, proc, index, priority)
  end
  
  <<-DOC
  >> replaces a target line in the target method. chains with other operations.
  DOC
  def self.replace_in_method(clazz, method, target, proc, index=0, priority=$injector_global_priority)
    return if self.has_valid_cache
    PENDING_PRE_INSERTIONS.push([clazz, method, target, proc, index, false, priority])
    self.delete_in_method(clazz, method, target, index, priority)
  end
  
  <<-DOC
  >> deletes a target line in the target function. chains with other operations.
  DOC
  def self.delete_in_function(function, target, index=0, priority=$injector_global_priority)
    return if self.has_valid_cache
    self.delete_in_method(:Object, function, target, index, priority)
  end
  
  <<-DOC
  >> deletes a target line in the target method. chains with other operations.
  DOC
  def self.delete_in_method(clazz, method, target, index=0, priority=$injector_global_priority)
    return if self.has_valid_cache
    PENDING_DELETIONS.push([clazz, method, target, index, priority])
  end

  <<-DOC
  @param load_event - a symbolic function reference (i.e. :function)
  @param priority - a numeric priority
  >> these events are called as the save is being loaded, so interacting with cache is not safe.. useful for deserializing data. numerically 
     higher priorities go first.
  DOC
  def self.add_load_event(load_event, priority=$injector_global_priority)
    EVENT_ON_LOAD.push([load_event, priority]) unless EVENT_ON_LOAD.include?([load_event, priority])
  end
  
  <<-DOC
  @param play_event - a symbolic function reference (i.e. :function)
  @param priority - a numeric priority
  >> these events are called when a save is fully loaded. useful for deserializing data. numerically higher priorities go first.
  DOC
  def self.add_play_event(play_event, priority=$injector_global_priority)
    EVENT_ON_PLAY.push([play_event, priority]) unless EVENT_ON_PLAY.include?([play_event, priority])
  end
  
  <<-DOC
  @param new_file_event - a symbolic function reference (i.e. :function)
  @param priority - a numeric priority
  >> these events are called when the player creates a new save file. numerically higher priorities go first.
  DOC
  def self.add_new_file_event(new_file_event, priority=$injector_global_priority)
    EVENT_ON_NEW_FILE.push([new_file_event, priority]) unless EVENT_ON_NEW_FILE.include?([new_file_event, priority])
  end
  
  <<-DOC
  @param save_event - a symbolic function reference (i.e. :function)
  @param priority - a numeric priority
  >> these events are called on save. useful for serializing data. numerically higher priorities go first.
  DOC
  def self.add_save_event(save_event, priority=$injector_global_priority)
    EVENT_ON_SAVE.push([save_event, priority]) unless EVENT_ON_SAVE.include?([save_event, priority])
  end

  <<-DOC
  >> sets the global default priority for injectors
  DOC
  def self.set_global_priority(priority=1000)
    $injector_global_priority = priority
  end

  <<-DOC
  >> executes a block of code with the given priority before reverting to the default.
  DOC
  def self.with_priority(priority)
    self.set_global_priority(priority)
    yield
    self.set_global_priority
  end
  
end