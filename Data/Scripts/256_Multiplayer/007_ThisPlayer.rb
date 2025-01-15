class ThisPlayer
  MOVED_NONE = 0
  MOVED_TRUE  = 1
  MOVED_MAP   = 2

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

  def self.moved?
    if $last_dumped_loc != generate_player_data_hash
      if $last_dumped_loc.kind_of?(Hash) and $last_dumped_loc[:map_id] != $game_map.map_id
        data = generate_player_data_hash
        data[:map_id] = $last_dumped_loc[:map_id]
        data[:x] = 0
        data[:y] = 0
        ConnectionHandler.publish('location', JSON.dump(data))
        $last_dumped_loc = generate_player_data_hash
        return ThisPlayer::MOVED_MAP
      end
      $last_dumped_loc = generate_player_data_hash
      return ThisPlayer::MOVED_TRUE
    end
    return ThisPlayer::MOVED_NONE
  end

  def self.moveTick
    case moved?
    when ThisPlayer::MOVED_NONE then return nil
    when ThisPlayer::MOVED_TRUE..ThisPlayer::MOVED_MAP then ConnectionHandler.publish('location', generate_player_data)
    end
  end

end