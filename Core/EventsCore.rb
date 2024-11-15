# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

class EventProvider

  attr_accessor(:event_hash)
  attr_accessor(:symbol)

  def initialize
    # used to check if event is present
    @event_hash = {}
  end

  def add_or_create_event(id, func, block)
    if func.nil? and block.nil?
      print "No function or block provided for event #{id} of #{@symbol}:#{self.class}"
      exit
    elsif func.nil?
      @event_hash[id] = [] unless @event_hash[id]
      @event_hash[id].push(block)
    else
      @event_hash[id] = [] unless @event_hash[id]
      @event_hash[id].push(func)
    end
    self
  end

end unless UniLib.lib_loaded(__FILE__)