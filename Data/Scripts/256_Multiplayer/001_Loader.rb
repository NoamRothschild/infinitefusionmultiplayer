class MultiplayerLoader
  @@enabled = false
  @@tick_thread = nil
  @@map_change_thread = nil
  @@subscribe_thread = nil

  def self.enabled=(val)
    return if val != true && val != false

    if @@enabled == true && val == false
      puts "[IFM] - Disabling multiplayer..."
      Ifm_Event.delete_all
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
    ConnectionHandler.bind if ConnectionHandler.connection.nil?

    @@subscribe_thread = ConnectionHandler.subscribe() if @@subscribe_thread.nil?
    @@map_change_thread = Ifm_Event.mapChangeThread if @@map_change_thread.nil?
    if @@tick_thread.nil?
      @@tick_thread = Thread.new do
        while true
          sleep 0.1
          ThisPlayer.moveTick
        end
      end
    end
    puts "[IFM] - Thread publisher started!"
  end

end