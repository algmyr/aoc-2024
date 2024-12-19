towels, _, *inputs = $<.map(&:strip)
towels = towels.split(', ').map{|towel| [towel, true]}.to_h

sz = towels.keys.map(&:size).max

p1 = 0
p2 = 0
for s in inputs do
  dp = [1] + [0]*s.size
  for i in 0...s.size do
    prefix = s[i...i+sz]
    for d in 1..prefix.size do
      dp[i+d] += dp[i] if towels[prefix[...d]]
    end
  end
  p1 += 1 if dp[-1] > 0
  p2 += dp[-1]
end

puts "Part 1: #{p1}"
puts "Part 2: #{p2}"
