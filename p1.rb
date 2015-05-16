def greator_of_three(a, b, c)
  return a > b ? (a > c ?a : c): (b > c ? b : c)
end

#common element in both
array1 = [1,4,5,8,10]
array2 = [4,6,6,8,12]
array3 = array1 & array2
array3.each { |x| puts x }
puts "====="

hash_a = {}
array1.each { |x| hash_a[x] = x }
array2.each { |x| puts x if hash_a[x] != nil  }

puts "====="
array4 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,9]
hash_b = {}
val = -1
array4.each { |x| hash_b[x] == nil ? hash_b[x] = x : val = x  }
puts val
puts "======="
puts greator_of_three(1,2,3)
puts greator_of_three(10,5,6)
