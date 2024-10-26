class MultiplayerLoader
  @@enabled = false
  @@tick_thread = nil
  @@map_change_thread = nil
  @@subscribe_thread = nil

  def self.enabled=(val)
    return if val != true && val != false

    if @@enabled == true && val == false
      puts "Disabling multiplayer..."
      EventManager.delete_all
      @@tick_thread.kill
      @@map_change_thread.kill
      @@subscribe_thread.kill

      @@tick_thread = nil
      @@map_change_thread = nil
      @@subscribe_thread = nil
    elsif @@enabled == false && val == true
      activate
    end

    @@enabled=val
  end
  
  def self.enabled?
    return @@enabled == true
  end

  def self.activate
    ConnectionHandler.create_connection if $conn.nil?

    @@subscribe_thread = ConnectionHandler.subscribe($conn) if @@subscribe_thread.nil?
    @@map_change_thread = EventManager.mapChangeThread if @@map_change_thread.nil?
    if @@tick_thread.nil?
      @@tick_thread = Thread.new do
        while true
          sleep 0.1
          ThisPlayer.moveTick
        end
      end
    end
    puts "Thread publisher started!"
  end

end