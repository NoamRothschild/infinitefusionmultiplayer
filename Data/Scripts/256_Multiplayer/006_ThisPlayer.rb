class ThisPlayer
  $last_dumped_loc

  def self.generate_player_data_hash
    data = Hash.new
    data[:x]                = $game_player.x
    data[:y]                = $game_player.y
    data[:direction]        = $game_player.direction
    data[:map_id]           = $game_map.map_id
    data[:player_id]        = $Trainer.id
    data[:graphic]          = {
      :action           => $action,
      :skin_tone        => $Trainer.skin_tone,
      :clothes          => $Trainer.clothes,
      :clothes_color    => $Trainer.clothes_color,
      :hair             => $Trainer.hair,
      :hair_color       => $Trainer.hair_color,
      :hat              => $Trainer.hat,
      :hat_color        => $Trainer.hat_color,
    }
    if $action == "surf"
      data[:graphic][:surfing_pokemon] = $surfing_pokemon 
    end
    data
  end

  def self.generate_player_data
    return JSON.dump(ThisPlayer.generate_player_data_hash)
  end

  # 0 -> none
  # 1 -> moved
  # 2 -> map_change
  def self.moved?
    if $last_dumped_loc != generate_player_data_hash
      if $last_dumped_loc.kind_of?(Hash) and $last_dumped_loc[:map_id] != $game_map.map_id
        data = generate_player_data_hash
        data[:map_id] = $last_dumped_loc[:map_id]
        data[:x] = 0
        data[:y] = 0
        ConnectionHandler.send_updated_location(JSON.dump(data))
        $last_dumped_loc = generate_player_data_hash
        return 2
      end
      $last_dumped_loc = generate_player_data_hash
      return 1
    end
    return 0
  end

  def self.moveTick
    case moved?
    when 0 then return nil
    when 1..2 then ConnectionHandler.send_updated_location(generate_player_data)
    end
  end

end