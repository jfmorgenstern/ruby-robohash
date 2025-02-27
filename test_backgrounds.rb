# test_backgrounds.rb
require 'robohash'

puts "Testing background support with the robohash gem"

# 1. Create a robot with a specific background
robot1 = Robohash.new("test_bg@example.com")
puts "Creating robot with bg1 background..."
robot1.assemble(roboset: "set1", color: "blue", bgset: "bg1")
robot1.img.write("robot_with_bg1.png")
puts "Saved robot with bg1 background to robot_with_bg1.png"

# 2. Create a robot with a different background
robot2 = Robohash.new("test_bg2@example.com")
puts "Creating robot with bg2 background..."
robot2.assemble(roboset: "set1", color: "red", bgset: "bg2")
robot2.img.write("robot_with_bg2.png")
puts "Saved robot with bg2 background to robot_with_bg2.png"

# 3. Create a robot with any random background
robot3 = Robohash.new("test_any_bg@example.com")
puts "Creating robot with any random background..."
robot3.assemble(roboset: "set2", bgset: "any")
robot3.img.write("robot_with_any_bg.png")
puts "Saved robot with random background to robot_with_any_bg.png"

puts "All background tests completed!"
