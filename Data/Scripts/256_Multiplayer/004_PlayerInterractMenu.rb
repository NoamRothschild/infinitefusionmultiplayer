class PlayerInterractMenu
  @@canInterract = true

  def initialize(scene, other_player_id)
    @scene = scene
    @other_id = other_player_id
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartInterractMenu
    return unless @@canInterract
    @scene.pbStartScene
    commands = []
    cmdGift = -1
    cmdFight = -1
    cmdCancel = -1

    commands[cmdGift = commands.length] = _INTL("Gift")
    commands[cmdFight = commands.length] = _INTL("Fight")
    commands[cmdCancel = commands.length] = _INTL("Cancel")

    loop do
      command = @scene.pbShowCommands(commands)
      if cmdGift >= 0 && command == cmdGift
        pbGiftScreen(@other_id)
      elsif cmdFight >= 0 && command == cmdFight
        pbMessage("Sorry, IFM doesn't offer in-game battles right now.")
        pbMessage("In the future, this may change. For now, visit any PokéCenter on the 2nd floor to battle friends in Pokémon Showdown!")
        pbPlayCloseMenuSE
        break
      elsif cmdCancel >= 0 && command == cmdCancel
        pbPlayCloseMenuSE
        break
      else
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
    @@canInterract = false
    thread = Thread.new do
       sleep 0.2
       @@canInterract = true
    end
  end

  #PlayerInterractMenu.call(id)
  def self.call(other_player_id)
    $game_temp.in_menu = true
    $game_map.update
    sscene = PokemonPauseMenu_Scene.new
    sscreen = PlayerInterractMenu.new(sscene, other_player_id)
    sscreen.pbStartInterractMenu
    $game_temp.in_menu = false
  end
end