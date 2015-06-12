require 'cinch'
load 'Cred.rb'

cred = Cred.new()

class Cinch::Message
  def twitch(string)
    string = string.to_s.gsub('<','&lt;').gsub('>','&gt;')
    bot.irc.send ":#{bot.config.user}!#{bot.config.user}@#{bot.config.user}.tmi.twitch.tv PRIVMSG #{channel} :#{string}"
  end
end

def build_commands(fileName)
  #Read the commands from the file
  file = open(fileName, 'r')
  hash = Hash.new
  file.each { |line| 
    line = line.strip
    commands = line.split(':---:')
    hash[commands[0]] =  commands[1]
  }
  return hash
end
def build_commands_array(fileName)
  #Read the commands from the file
  file = open(fileName, 'r')
  array = Array.new
  file.each { |line| 
    line = line.strip
    array <<  line
  }
  return array
end

def write_file(hash, filepath)
  logfile = File.new(filepath, "w")
  hash.each { |k, v| logfile.write(k + ':---:' + v + "\n")  }
end

def write_file_array(array, filepath)
  logfile = File.new(filepath, "w")
  array.each { |person| logfile.write(person + "\n")  }
end




hash = build_commands("botCommands.txt")
queue = Array.new
#read from file queue and stored friendCodes

puts "Enter channel to join"
channel = gets.chomp#"emre801"
fc_hash = build_commands("fc.txt")
ign_hash = build_commands("ign.txt")
puns = build_commands_array("pun.txt")
queue = build_commands_array("queue.txt")
botname = cred.return_bot_name #this is where you'll enter your bot's name
raffle = Hash.new
raffle_lock = false;
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
  ## Commands that can be executed
  hash.each { |command, response|  
    on :message, command do |m|
      m.twitch response
    end
  }
  on :message, "!listC" do |m|
    commandList = "The available commands are "
    hash.each { |command, response|  commandList = commandList + " " + command  }
    m.twitch commandList
  end
  on :message, "!pun" do |m|
    m.twitch puns[rand(puns.length)]
  end
  ##----------
  #
  ## FC and IGN management
  on :message, "!add" do |m|

    if (queue.include?(m.user.nick))
      m.twitch "You are already in line for a battle, #{m.user.nick}"
      return
    end
    m.twitch "#{m.user.nick}, has been added to the battleQueue"
    queue.push m.user.nick
    write_file_array(queue, "queue.txt")
  end
  
  on :message, "!next" do |m|
    if queue.length == 0 
      m.twitch "No one is in queue"
      return
    end
    if m.user.nick.eql?(channel)
      battle = queue.shift 
      person = battle
      battle ="Next person for battle is #{battle}"
      if(fc_hash.has_key?(person))
        battle = battle + ", fc: " +  fc_hash[person][0..3] + "-" + fc_hash[person][4..7] + "-" + fc_hash[person][8..12]
      else 
        battle = battle + ", please enter your friend code, inorder to save code use !fc command"
      end
      if(ign_hash.has_key?(person))
        battle = battle + ", IGN: " + ign_hash[person]
      else
        battle = battle + ", please enter your IGN inorder for it to be saved"
      end
      m.twitch battle
      write_file_array(queue, "queue.txt")
    end
  end
  on :message, /^!ign (.+)/ do |m, responce|
    ign_hash[m.user.nick] = responce
    m.twitch "your IGN has been saved, thank you"
    write_file(ign_hash, "ign.txt")
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
    write_file(fc_hash, "fc.txt")
  end
  
  on :message, "!remove" do |m|
    if queue.include?(m.user.nick)
      queue.delete(m.user.nick)
      m.twitch "You have been removed"
      write_file_array(queue, "queue.txt")
    else
      m.twitch m.user.nick + ", you are not in line"
    end
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
    write_file(fc_hash, "fc.txt")
  end
  
  on :message, "!line" do |m|
    if(queue.length ==0)
      m.twitch "No one is in line"
      return
    end
    line = "";
    queue.each { |item| line = line + " " + item  }
    m.twitch line
  end
  ##----------
  
  ## Raffle Code
  on :message, "!raffle" do |m|
    if !raffle_lock
      raffle[m.user.nick] = 0
      m.twitch "You have been entered"
    end
  end
  on :message, "!raffle_lock" do |m|
    if(m.user.nick.eql?(channel))
      raffle_lock = !raffle_lock
      m.twitch "Raffle has been switch is is now: " + raffle_lock.to_s 
    end
  end
  on :message, "!raffle_end" do |m|
    if(m.user.nick.eql?(channel))
      raffle = Hash.new
      m.twitch "Raffle has been cleared"
      raffle_lock = true
    end
  end
  
  on :message, "!raffle_winner" do |m|
    if( m.user.name.eql?(channel))
      people = raffle.keys
      winner = rand(people.length)
      m.twitch people[winner] + ", you are the winner"
    end
  end
  ##----------

end

bot.start