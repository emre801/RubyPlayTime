def word_freq (text, frequency)
  words = text.split(/\W+/)
  words.each { |word| frequency[word] += 1  }

  frequency = frequency.sort_by { |a , b| b }
  frequency = frequency.reverse
  #frequency.each { |k,  v| puts k  }
  return frequency
end
freq = Hash.new(0)
puts word_freq("cool man is cool", freq).compact.first(2)

