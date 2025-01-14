$msg_queue = Queue.new

class ConnectionHandler
  # instantiates & returns a connection to the Redis Database.
  def self.create_connection(host=nil, port=nil, password=nil)
    if host.nil? && port.nil? && password.nil?
      begin
        script_path = File.expand_path(__FILE__)
        game_folder = File.expand_path(File.join(script_path, '..'))
        credentials_path = File.join(game_folder, 'Multiplayer', 'credentials.json')
        File.open(credentials_path, 'r') do |file|
          contents = JSON.parse(file.read)
          host = contents['host']
          port = contents['port']
          password = contents['password']
        end
      rescue Exception => e
        puts "[IFM] - An error has occured while trying to get database info.\n Make sure all details are placed correctly"
      end
    end

    begin
      $conn = Redis.new(host: host, port: port, password: password)
    rescue Exception => e
      pbMessage("Database credentials are not valid, #{e}")
    end
    $conn
  end

  # Listens for new incoming data
  def self.subscribe(connection)
    sub_cnt = 0

    subscribe_thread = Thread.new do
      connection.subscribe('location', 'gifts') do |on|
        on.subscribe { sub_cnt += 1 }
        on.message do |channel, msg|
          begin
            data = JSON.parse(msg)
            case channel
            when 'location' then $msg_queue << data
              # Running this from a thread causes Segmentation Fault, 
              # data is being sent to an event which is always listening and executing from a safe place.
            when 'gifts' then handle_gift_packet(data)
            end
          rescue Exception => e
            puts "[IFM] - Malformed message was sent"
          end
        end
      end
    end

    Thread.pass until sub_cnt == 2
    subscribe_thread
  end

  # This func always runs from an Event to allow for a safe execution place.
  def self.message
    until $msg_queue.empty?
      msg = $msg_queue.pop

      if msg.key?('pbMsg')
        #puts "[IFM] - displaying message: #{msg['pbMsg']}"
        pbMsg = msg['pbMsg']
        msgwindow = pbCreateMessageWindow(nil, nil)
        pbMessageDisplay(msgwindow, pbMsg)
        pbDisposeMessageWindow(msgwindow)
        Input.update
      else
        ConnectionHandler.handle_location_packet(msg)
      end
      
    end
  end
  
  def self.pbMessage(message)
    $msg_queue << {'pbMsg'=>message}
  end

  def self.handle_gift_packet(data)
    data.each do |player_ids, gifted_data|
      receiver, sender = player_ids.split('_')
      break if receiver.to_s != $Trainer.id.to_s
      
      pkmn = Pokemon.new(:BULBASAUR, 1)
      pkmn.load_json(eval(gifted_data))

      storedPlace = nil
      unless $Trainer.party_full?
        puts "[IFM] - Party not full, placing pokemon..."
        $Trainer.party[$Trainer.party.length] = pkmn
        storedPlace = "Party"
      else
        puts "[IFM] - Placing pokemon in pc since party is full..."
        $PokemonStorage.pbStoreCaught(pkmn)
        storedPlace = "PC"
      end

      $msg_queue << {'pbMsg'=> "#{sender} sent you his #{pkmn.name}!, it's waiting for you in your #{storedPlace}."}
    end
  end

  def self.handle_location_packet(data)
    begin
      return if (data == nil) || (data["player_id"] == $Trainer.id)

      player_id = data["player_id"]

      if data["map_id"] == $game_map.map_id

        if data["x"] == -1 and data["y"] == -1
          puts "[IFM] - player #{player_id} moved into another map, deleting event..."
          ev = Ifm_Event.get_event(player_id)
          ev.delete

        elsif ev = Ifm_Event.get_event(player_id)

          if ev.graphics != data["graphic"]
            ev.refresh_graphics(data["graphic"])
            #Refresh player graphic
            ev.event.character_name = "Multiplayer_#{player_id}_#{rand(1000..9999)}"
          end
          
          old_thr = ev.walk_thread
          if !old_thr.nil? && old_thr.alive?
            old_thr.kill
          end

          walkThread = Thread.new do
            ev.walkto(data["x"], data["y"], data["graphic"]["action"]); sleep 0.2 until [ev.event.x, ev.event.y] == [data["x"], data["y"]]
            ev.rotate(data["direction"])
          end

          ev.walk_thread = walkThread

        else
          # New player -> create a new event

          ev = Ifm_Event.new(player_id, data["graphic"], data["x"], data["y"])
          ev.rotate(data["direction"])

          puts "[IFM] - created event for player #{player_id}"
          # send my location
          $conn.publish('location', ThisPlayer.generate_player_data)
        end
      end
    rescue Exception => e
      puts "[IFM] - An error has occured! #{e}"
    end
  end

  def self.send_updated_location(connection=$conn, channel='location', message)
    if $conn.nil?
      $conn = create_connection
      connection = $conn
    end
    connection.publish(channel, message)
  end
end