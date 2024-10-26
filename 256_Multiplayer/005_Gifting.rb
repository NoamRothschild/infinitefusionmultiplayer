class PokemonPartyScreen

  def pbGiftScreen(to_player_id)
    @scene.pbStartScene(@party,
                        (@party.length > 1) ? _INTL("Select a Pokémon.") : _INTL("Select Pokémon or cancel."), nil)
    loop do
      @scene.pbSetHelpText((@party.length > 1) ? _INTL("Select a Pokémon.") : _INTL("Select Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon(false, -1, 1)
      break if (pkmnid.is_a?(Numeric) && pkmnid < 0) || (pkmnid.is_a?(Array) && pkmnid[1] < 0) || (@party.length < 2)
      
      pkmn = @party[pkmnid]
      commands = []      
      cmdGift = -1
      cmdCancel = -1

      # Build the commands
      if !pkmn.egg?
        commands[cmdGift = commands.length] = _INTL("Gift")
      end
      
      commands[commands.length] = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands)
      
      if cmdGift >= 0 && command == cmdGift
        res = Hash.new
        res[to_player_id.to_s+"_"+$Trainer.name] = pkmn.to_json.to_s
        ConnectionHandler.send_updated_location(connection=$conn, channel='gifts', message=JSON.dump(res))
        pbDisplay("Selected Pokémon has been sent to player #{to_player_id}!")
        @party.delete(pkmn)
        break
      end
    end
    @scene.pbEndScene
    return nil
  end

end

#===============================================================================
# Open the gift screen
#===============================================================================
def pbGiftScreen(to_player_id)
  pbFadeOutIn {
    sscene = PokemonParty_Scene.new
    sscreen = PokemonPartyScreen.new(sscene, $Trainer.party)
    sscreen.pbGiftScreen(to_player_id)
  }
end