require 'rubygems'
require 'twitter'
load 'Cred.rb'

cred = Cred.new()

client = cred.return_cred()

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {:count => 200, :include_rts => true}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end
def word_freq (text, frequency, wordDict)
  words = text.split(' ')
  words.each { |word| frequency[word] += 1 if !ignore_me(word, wordDict)   }
  return frequency
end
def ignore_me(word, words)
  words_to_ignore = words
  result = word.empty? || words_to_ignore[word.downcase] != nil || word.length < 2
  return result

end
def get_words_to_ignore()
  file = open("100Words.txt", 'r')
  hash = Hash.new
  file.each { |line| 
    hash[line.downcase.strip] =  line.downcase.strip}
  return hash
end

words = get_words_to_ignore()
=begin
puts words.length
frequency = Hash.new(0)
puts word_freq("Hello my name is John", frequency, words)
=end

puts "Enter twitter username: "
user = gets.chomp#"burnie"
puts "looking up " + user 
all_tweets = client.get_all_tweets(user)
frequency = Hash.new(0)
puts "-------"
all_tweets.each { |tweet| 
  frequency = word_freq(tweet.text, frequency, words) }
puts "Finished getting tweets"

frequency = frequency.sort_by { |a , b| b }
frequency = frequency.reverse
puts "The top most used tweets " + user
target = open(user+".txt", 'w')

frequency[1..100].each{|k , v| 
  word = k + " : " + v.to_s 
  target.write( word)
  target.write("\n")
  }
