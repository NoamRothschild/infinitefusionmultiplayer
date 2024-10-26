module Console
  def self.processInput
    loop do
      input = readInput
      unless input.gsub(" ", "").empty?
        STDOUT.sync = true
        puts "\e[A\e[K"
        puts "\e[32mCommand:\e[0m \033[36m#{input}\e[0m\n"
        begin
          eval(input)
        rescue => e
          puts "An error has occurred: #{e}"
        end
      else
        puts "\e[A\e[K"
      end
      STDOUT.sync = false
    end
  end
end

Thread.new { Console.processInput } if $DEBUG
# Allows you to write 1-liners inside the game's terminal if running from RPGXP