#anagram
  def is_anagram(word_one, word_two)
    anagram_word_one = sort_word(word_one)
    anagram_word_two = sort_word(word_two)
    puts anagram_word_one
    puts anagram_word_two
    return anagram_word_one.eql?(anagram_word_two)
  end
  def sort_word(word)
    return word.chars.sort.join
  end
def testCase
  word_a = "aaabaa"
  word_b = "baaaaa"
  word_c = "aaavaa"
  puts is_anagram(word_a, word_b)
  puts is_anagram(word_a, word_c)
end

testCase