grade = 'B'

did_i_pass = case grade
             when 'A', 'B', 'C'
               'Hell yeah!'
             when 'D'
               "Don't tell your mother."
             else
               "'YOU SHALL NOT PASS!' -Gandalf"
             end

puts did_i_pass

puts "\n1. while"
i = 0
while i < 5
  puts "#{i} zombies incoming!"
  i += 2
end

puts "\n2. Range#step"
(0...5).step(2) do |i|
  puts "#{i} zombies incoming!"
end

puts "\n3. for"
for i in (0...5).step(2)
  puts "#{i} zombies incoming!"
end

tryes = 0
until gets.chomp == 'true' || tryes >= 3
  puts "Tentativa #{tryes}"
  tryes += 1
end

puts "\n4. Hashes"
# A hash stores key-value pairs:
#   key => value
# You use a key to look up its value.
# In this example, :name is the key and "Ada" is its value.
person = { name: 'Ada', role: 'developer' }
puts person[:name] # => Ada

# `hash[:missing_key]` returns nil. Try this:
# puts person[:age].inspect

# Exercise 1 — Read values
# Use the keys to print the price of the cake and the tea.
menu = { coffee: 3, tea: 2, cake: 5 }
# TODO: print menu[:cake]
# TODO: print menu[:tea]

# Exercise 2 — Add and update pairs
# Assignment adds a new key when it does not exist.
# Assignment changes the value when the key already exists.
user = { name: 'Lia', language: 'Ruby' }
# TODO: Add a :level key with the value "beginner".
# TODO: Change :language to "Ruby and Rails".
# TODO: Print user to inspect the complete hash.

# Exercise 3 — Visit every pair
# `each` gives you both the key and the value.
temperatures = { monday: 22, tuesday: 24, wednesday: 19 }
# TODO: Use `each do |day, temperature|` to print:
# monday: 22°C
# tuesday: 24°C
# wednesday: 19°C

# Exercise 4 — Use a value in a condition
account = { owner: 'Sam', balance: 120, active: true }
# TODO: Print the owner's name.
# TODO: If the account is active, print "Account is active".
# TODO: Add 30 to the balance, then print the new balance.

# Exercise 5 — Count repeated words
# Build a hash where each word is a key and its number of appearances is the value.
words = %w[ruby hash ruby code hash ruby]
counts = {}

words.each do |word|
  # TODO: Increase the count for this word by 1.
  # Hint: a key that does not exist returns nil.
end

# Expected result after Exercise 5:
# {"ruby"=>3, "hash"=>2, "code"=>1}
# When you finish, run this file and send me one exercise at a time for feedback.
