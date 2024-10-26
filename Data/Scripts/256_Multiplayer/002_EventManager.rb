
class EventManager
  @@events = Hash.new
  # { player_id => rf_event }

  @@graphics = Hash.new
  # { player_id => {action, skin_tone, hat...} }

  # Usage: EventManager.new(player_id, graphics, x, y) - (creates an event for the specified player)
  def self.create_event(player_id, graphics, x=-1, y=-1)
    map_id = $game_map.map_id

    rf_event = Rf.create_event(map_id) do |event|
      
      event.x, event.y = (x.negative? && y.negative?) ? [0, 0] : [x, y]
      event.name = "ifmClient_#{player_id}"

      # Create page
      page = RPG::Event::Page.new
      page.list.clear
      page.trigger = 0
      list = page.list

      # Add behavior
      Compiler.push_script(list, "PlayerInterractMenu.call(#{player_id})")
      Compiler.push_end(list)

      # Save
      event.pages = [page]
    end

    if @@events.key?(player_id)
      Rf.delete_event(@@events[player_id], map_id)
    end
    
    if !@@graphics.key?(player_id) || @@graphics[player_id] != graphics
      @@graphics[player_id] = graphics
    end
    
    rf_event.character_name = "Multiplayer_#{player_id}"

    @@events[player_id] = rf_event
    rf_event
  end

  # Usage: walks a given event to position (x, y)
  # Note: pbMoveRoute runs on a seperate thread which means we miss some of its calls when going bulk 
  def self.walkto(rf_event, x, y, direction=2)

    distanceX = x - rf_event.x
    distanceY = y - rf_event.y

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
        PBMoveRoute::ThroughOn,
        xDir
      ], true)
    }
    
    (1..distanceY.abs).each { |_|
      pbMoveRoute(rf_event, [
        PBMoveRoute::ThroughOn,
        yDir
      ], true)
    }

    rotate_direction(rf_event, direction)

    # Auto teleports the event to where it needs to be if he didn't get there due to the above menioned bug
    Thread.new do
      sleep 0.2
      if rf_event.x != x || rf_event.y != y
        rf_event.moveto(x, y) # built in function to force-tp event
      end
    end
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

  # Deletes all *references* to events (for wiping out events from old maps)
  def self.cleanEventList
    @@events.each do |player_id, _|
      @@events.delete(player_id)
    end
  end

  def self.mapChangeThread
    map_id = $game_map.map_id
    thread = Thread.new do
      while true
        if map_id != $game_map.map_id
          cleanEventList
          $conn.publish('location', "{\"x\":-1,\"y\":-1,\"direction\":2,\"map_id\":#{map_id},\"player_id\":#{$Trainer.id}, \"action\":\"walk\"}")
          map_id = $game_map.map_id
        end
        sleep 0.2
      end
    end
    thread
  end

  def self.exists?(player_id)
    @@events.key?(player_id)
  end

  def self.delete_event(ev, map_id, player_id)
    Rf.delete_event(ev, map_id)
    @@events.delete(player_id)
  end

  def self.get_event_by_id(player_id)
    if exists?(player_id)
      return @@events[player_id]
    end
    nil
  end

  def self.get_graphics_by_id(player_id)
    if @@graphics.key?(player_id)
      return @@graphics[player_id]
    end
    nil
  end

  def self.set_graphics_by_id(player_id, graphic)
    @@graphics[player_id] = graphic
  end

end