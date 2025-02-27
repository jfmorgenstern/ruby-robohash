# test_robohash.rb
require_relative 'lib/robohash'

puts "Creating robot from hash..."
robot = Robohash.new("string")

puts "Assembling the robot with set1 and blue color..."
robot.assemble(roboset: "set1")

if robot.img
  puts "Saving the robot to a file..."
  robot.img.write("robot.png")
  puts "Robot saved to robot.png"
else
  puts "Error: No image was created!"
end