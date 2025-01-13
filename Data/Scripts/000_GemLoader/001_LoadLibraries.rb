=begin
  This file adds the Libs folder into the game's path so gem or any modules from ruby can be used appropriately 
    using the `require` keyword.

  Note that some modules may need other modules to run, so in order to make them work you may need to copy them into here too.
  Find ruby's module directories by running
  `ruby -e "puts $:"` in the terminal or
  `gem environment` in the terminal for the gems directory.
=end

game_path = File.expand_path(File.join(File.expand_path(__FILE__), '..'))
libs_path = File.join(game_path, 'Libs')
$:.unshift(libs_path) # adding Libs folder into ruby's PATH

# managing connections (for multiplayer)
require 'redis'

# parsing & transfering data
require 'json' 

=begin

  The following packages have been added since the following modules depend on them:

  REDIS:
  - 'uri'
  - 'openssl'
  - 'connection_pool'
  - 'redis_client'
  - 'delegate'

  JSON:
  - 'strscan'

=end