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
#read from file queue and stored friendCodes


lineHash = Hash.new
puts "Enter channel to join"
channel = gets.chomp#"emre801"
fc_hash = Hash.new
ign_hash = Hash.new
botname = cred.return_bot_name #this is where you'll enter your bot's name
#write queue to file
  
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

    if (is_user_in_queue(m.user.nick,queue, m))
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
    if m.user.nick.eql?(channel)
      battle = queue.pop
      lineHash[m.user.nick] = 0
      battle ="Next person for battle is #{battle}"
      if(fc_hash.has_key?(m.user.nick))
        battle + ", fc: " + fc_hash[m.user.nick][0..3] << "-" << fc_hash[m.user.nick][4..7]<< "-" << fc_hash[m.user.nick][8..12]
      else 
        battle + ", please enter your friend code, inorder to save code use !fc command"
      end
      m.twitch "bloop2"
      if(ign_hash.has_key?(m.user.nick))
        battle + ", IGN: " + ign_hash[m.user.nick]
      else
        battle + ", please enter your IGN inorder for it to be saved"
      end
      m.twitch battle
    end
  end
 on :message, /^!ign (.+)/ do |m, responce|
    ign_hash[m.user.nick] = responce
    m.twitch "your IGN has been saved, thank you"
  end
 on :message, /^!fc (.+)/ do |m, responce|
	    responce = responce.delete('^0-9')
      if(fc_hash.has_key?(m.user.nick))
        m.twitch m.user.nick + ", have already added your friend code, if you want to update it please enter !fc_update"
        return
      end
      if responce.length != 12
        m.twitch m.user.nick + ", You have entered an incorrect friend Code"
        return;
      end
      m.twitch m.user.nick + ", Thank you. I have added your Friend Code to my Collection " + responce[0..3] + "-" + responce[4..7] + "-" + responce[8..12]
      fc_hash[m.user.nick] = responce
  end
  
   on :message, /^!fc_update (.+)/ do |m, responce|
	    responce = responce.delete('^0-9')
      if(!fc_hash.has_key?(m.user.nick))
        m.twitch m.user.nick + ", you do not have a friendCode in the database, currently adding it"
      end
      if responce.length != 12
        m.twitch m.user.nick + ", You have entered an incorrect friend Code"
        return;
      end
      m.twitch m.user.nick + ", Thank you. I have added your Friend Code to my Collection " + responce[0..3] + "-" + responce[4..7] + "-" + responce[8..12]
      fc_hash[m.user.nick] = responce
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
def is_user_in_queue(user, queue, m)
    is_in_queue = false;
    if(!queue.empty?)
      tempQueue = Queue.new
        loop do
          temp = queue.pop
          tempQueue << temp
          is_in_queue = true if (temp.eql?(user))
          break if queue.empty?
        end
        queue = tempQueue
    end
    is_in_queue
end

bot.start

