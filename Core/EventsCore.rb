class EventProvider

  attr_accessor(:event_hash)

  def initialize
    # used to check if event is present
    @event_hash = {}
  end

end