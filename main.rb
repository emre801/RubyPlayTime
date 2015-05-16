require 'rubygems'
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "fnLBUDDLfOyzyQDx3ZMDgQS82"
  config.consumer_secret     = "TbEWq9NYx41eY39Qvgre71eylnJ0JK7g4SJO9i5RcORWSTtIW7"
  config.access_token        = "235382126-kxh6viE1CHQJpcbHhH0gRcG8kMpvRzcxL2rVUh94"
  config.access_token_secret = "bQsYMmBWVP50XoeDqKwoanDIXjLXN1U6SlO5rK2UzQzi2"
end

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
def wordFreq (text, frequency)
  words = text.split(/\W+/)
  words.each { |word| frequency[word] += 1 if ignore_me(word)   }
  return frequency
end
def ignore_me(word)
  words_to_ignore = ['you','the','to','it','is','that','and','for','of','have','are']
  return !(word.length <= 4 || words_to_ignore.include?(word.downcase))

end

user = "burnie"
puts "looking up " + user 
all_tweets = client.get_all_tweets(user)
frequency = Hash.new(0)
all_tweets.each { |tweet|  frequency = wordFreq(tweet.text, frequency) }
puts "Finished getting tweets"

frequency = frequency.sort_by { |a , b| b }
frequency = frequency.reverse
puts "The top most used tweets " + user
frequency[1..100].each{|k , v| puts k + " : " + v.to_s }

