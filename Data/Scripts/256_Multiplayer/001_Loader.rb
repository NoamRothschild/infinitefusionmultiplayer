class MultiplayerLoader
  @@enabled = true

  def self.enabled=(val)
    @@enabled=val
  end

  def self.activate
    ConnectionHandler.subscribe(ConnectionHandler.create_connection)
      EventManager.mapChangeThread
      Thread.new do
        while true
          sleep 0.1
          ThisPlayer.moveTick
        end
      end
      puts "Thread publisher started!"
      
  end

end