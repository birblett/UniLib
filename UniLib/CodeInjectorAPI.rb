# ==================================================================================================================== #
# =================================================== DEPENDENCIES =================================================== #
# ==================================================================================================================== #

verify_version(0.3, File.basename(__FILE__).gsub!(".rb", ""))

# ==================================================================================================================== #
# ==================================================== PUBLIC API ==================================================== #
# ==================================================================================================================== #


<<-DOC
>> useful functions and event hooks for cross-compatibility and simplicity. embedded in the standard api.
DOC

<<-DOC
COMMON
@function - a symbol (i.e. :function) corresponding to a function bound to Object. this includes all global functions.
@clazz - a class containing the target method
@method - a symbol (i.e. :method) corresponding to a method bound to @clazz. this includes all global functions.
@target - a string or one of :HEAD or :TAIL. insertion will be after the first match, or after the definition with :HEAD
          and right before the last "end" with :TAIL
@proc - a Proc object. the body must be on its own lines.
@index - if nonzero, attempts to match a duplicate corresponding to the index (for example with multiple "ends")
>> for injection, replacement, and deletion functions.
DOC

<<-DOC
>> injects a block of code after the specified target in the target function.
DOC
def insert_in_function(function, target, proc, index=0)
  insert_in_method(:Object, function, target, proc, index)
end

<<-DOC
>> injects a block of code after the specified target in the target method.
DOC
def insert_in_method(clazz, method, target, proc, index=0)
  PENDING_INSERTIONS.push([clazz, method, target, proc, index, false])
end

<<-DOC
>> injects a block of code before the specified target in the target function.
DOC
def insert_in_function_before(function, target, proc, index=0)
  insert_in_method_before(:Object, function, target, proc, index)
end

<<-DOC
>> injects a block of code before the specified target in the target method.
DOC
def insert_in_method_before(clazz, method, target, proc, index=0)
  PENDING_INSERTIONS.push([clazz, method, target, proc, index, true])
end

<<-DOC
>> replaces a target line in the target function. chains with other operations.
DOC
def replace_in_function(function, target, proc, index=0)
  replace_in_method(:Object, function, target, proc, index)
end

<<-DOC
>> replaces a target line in the target method. chains with other operations.
DOC
def replace_in_method(clazz, method, target, proc, index=0)
  insert_in_method_before(clazz, method, target, proc, index)
  delete_in_method(clazz, method, target, index)
end

<<-DOC
>> deletes a target line in the target function. chains with other operations.
DOC
def delete_in_function(function, target, index=0)
  delete_in_method(:Object, function, target, index)
end

<<-DOC
>> deletes a target line in the target method. chains with other operations.
DOC
def delete_in_method(clazz, method, target, index=0)
  PENDING_DELETIONS.push([clazz, method, target, index])
end

<<-DOC
@play_event - a symbolic function reference (i.e. :function)
@priority - a numeric priority
>> these events are called when the player enters a save file. useful for deserializing data. numerically higher 
   priorities go first.
DOC
def add_play_event(play_event, priority=1000)
  EVENT_ON_PLAY.push([play_event, priority]) unless EVENT_ON_PLAY.include?([play_event, priority])
end

<<-DOC
@save_event - a symbolic function reference (i.e. :function)
@priority - a numeric priority
>> these events are called on save. useful for serializing data. numerically higher priorities go first.
DOC
def add_save_event(save_event, priority=1000)
  EVENT_ON_SAVE.push([save_event, priority]) unless EVENT_ON_SAVE.include?([save_event, priority])
end