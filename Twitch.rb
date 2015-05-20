require 'cinch'
load 'Cred.rb'

cred = Cred.new()

class Cinch::Message
    def twitch(string)
        string = string.to_s.gsub('<','&lt;').gsub('>','&gt;')
        bot.irc.send ":#{bot.config.user}!#{bot.config.user}@#{bot.config.user}.tmi.twitch.tv PRIVMSG #{channel} :#{string}"
    end
end

def build_commands
  #Read the commands from the file
  file = open("botCommands.txt", 'r')
  hash = Hash.new
  file.each { |line| 
    line = line.strip
    commands = line.split(':---:')
    hash[commands[0]] =  commands[1]
  }
  return hash
end

hash = build_commands
queue = Queue.new
lineHash = Hash.new
puts "Enter channel to join"
channel = gets.chomp#"emre801"  
botname = cred.return_bot_name #this is where you'll enter your bot's name
  
  
bot = Cinch::Bot.new do
  configure do |c|
    c.server   = "irc.twitch.tv"
    c.port     = "6667"
    c.nick     = botname #change nickname to your bots' name
    c.password = cred.return_twitch_password
    c.channels = ["#"+channel]
    c.user     = botname #change user to your bot's name
  end
  hash.each { |command, response|  
  on :message, command do |m|
    m.twitch response
  end
  }
  on :message, "!add" do |m|
    tempQueue = Queue.new
    is_in_queue = false;
    if(!queue.empty?)
        loop do
          temp = queue.pop
          tempQueue << temp
          is_in_queue = true if (temp.eql?(m.user.nick))
          m.twitch "Stop"
          break if queue.empty?
        end
        queue = tempQueue
    end
    if (is_in_queue)
      m.twitch "You are already in line for a battle, #{m.user.nick}"
      return
    end
    m.twitch "#{m.user.nick}, has been added to the battleQueue"
    queue << m.user.nick
    lineHash[m.user.nick] = 1
  end
  
  on :message, "!next" do |m|
    if queue.length == 0 
      m.twitch "No one is in queue"
      return
    end
    return if !m.user.nick.eql?(channel)
    battle = queue.pop
    lineHash[m.user.nick] = 0
    m.twitch "Next person for battle is #{battle}"
  end
  
  on :message, "!line" do |m|
    if queue.length == 0 
      m.twitch "No one is in queue"
      return
    end
    line = ""
    tempQueue = Queue.new
    loop do
      temp = queue.pop
      tempQueue << temp
      line += temp + " "
      break if queue.empty?
    end
    queue = tempQueue
    m.twitch line
  end
  

end

bot.start

