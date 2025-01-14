
class EventManager
  @@events = Hash.new
  # { player_id => rf_event }

  # Usage: EventManager.create_event(player_id, graphics, x, y) - (creates an event for the specified player)
  def self.create_event(graphics_fname, x=-1, y=-1, map_id = nil, event_name=nil, event_identifier = nil, behavior_script = nil, cache_instance = true)
    map_id ||= $game_map.map_id
    event_identifier ||= rand(1000..9999)
    event_name ||= "CustomEvent#{event_identifier}"
    behavior_script ||= ""

    rf_event = Rf.create_event(map_id) do |event|
      
      event.x, event.y = (x.negative? && y.negative?) ? [0, 0] : [x, y]
      event.name = event_name

      # Create page
      page = RPG::Event::Page.new
      page.list.clear
      page.trigger = 0
      list = page.list

      # Add behavior
      Compiler.push_script(list, behavior_script)
      Compiler.push_end(list)

      # Save
      event.pages = [page]
    end

    rf_event.character_name = graphics_fname

    @@events[event_identifier] = rf_event if cache_instance
    rf_event
  end

  # Usage: walks a given event to position (x, y)
  # Note: pbMoveRoute runs on a seperate thread which means we miss some of its calls when going bulk 
  def self.walkto(rf_event, x, y, state="walk", direction=2)

    distanceX = x - rf_event.x
    distanceY = y - rf_event.y
    
    case state
    when "walk"
      speed = 3
    when "bike"
      speed = 5
    else
      #run, surf & dive
      speed = 4
    end

    if distanceX.zero? && distanceY.zero?
      rotate_direction(rf_event, direction)
      return
    end
    
    if Math.sqrt(distanceX**2 + distanceY**2) >= 10
      rf_event.moveto(x, y) # built in function to force-tp event
      return
    end

    xDir = distanceX.positive? ? 3 : 2
    yDir = distanceY.positive? ? 1 : 4

    (1..distanceX.abs).each { |_|
      pbMoveRoute(rf_event, [
        PBMoveRoute::ChangeSpeed, speed, 
        PBMoveRoute::ChangeFreq, 6,
        PBMoveRoute::ThroughOn,
        xDir
      ], true)
    }
    
    (1..distanceY.abs).each { |_|
      pbMoveRoute(rf_event, [
        PBMoveRoute::ChangeSpeed, speed, 
        PBMoveRoute::ChangeFreq, 6,
        PBMoveRoute::ThroughOn,
        yDir
      ], true)
    }
  end

  # Usage: rotates the event to the given direction
  def self.rotate_direction(rf_event, direction = 2)
    pbDirection = 15 + (direction / 2)
    # 2 -> 16, 4 -> 17, 6 -> 18, 8 -> 19
    # See PBMoveRoute::Turn for more info
    pbMoveRoute(rf_event, [
      pbDirection
    ])
  end

#===============================================================================
# Caching utils
#===============================================================================

  def self.get_event_by_id(event_identifier)
    if exists?(event_identifier)
      return @@events[event_identifier]
    end
    nil
  end
  
  def self.exists?(event_identifier)
    @@events.key?(event_identifier)
  end

  # Deletes all *references* to events (for wiping out events from old maps)
  def self.cleanEventList
    @@events.each do |event_identifier, _|
      @@events.delete(event_identifier)
    end
  end

  def self.delete_all
    @@events.each do |event_identifier, rf_event|
      Rf.delete_event(rf_event, $game_map.map_id)
      @@events.delete(event_identifier)
    end
  end

  def self.delete_event(ev, map_id, event_identifier)
    Rf.delete_event(ev, map_id)
    if @@events.key?(event_identifier)
      @@events.delete(event_identifier)
    end
  end

end