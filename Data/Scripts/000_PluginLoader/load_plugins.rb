game_folder = File.expand_path(File.join(File.expand_path(__FILE__), '..'))

#strscan is a package required for json-2.7.2
strscan = File.join(game_folder, 'Libs', 'strscan')
$:.unshift(strscan)

require_relative 'Libs/uri/uri'
require_relative 'Libs/openssl/openssl'
require_relative 'Libs/connection_pool-2.4.1/lib/connection_pool'
require_relative 'Libs/redis-client-0.22.2/lib/redis-client'
require_relative 'Libs/delegate'
require_relative 'Libs/redis-5.3.0/lib/redis'
require_relative 'Libs/json-2.7.2/lib/json'