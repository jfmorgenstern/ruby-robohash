# test_installed.rb
require 'robohash'

begin
  puts "Creating robot from installed gem..."
  robot = Robohash.new("test_installed@example.com")

  puts "Assembling robot with set1"
  robot.assemble(roboset: "set1")

  if robot.img
    puts "Saving robot to installed_robot.png..."
    robot.img.write("installed_robot.png")
    puts "Success! Robot image saved to installed_robot.png"

    # Also try another set to make sure everything works
    robot2 = Robohash.new("another_test@example.com")
    robot2.assemble(roboset: "set2")
    robot2.img.write("installed_robot2.png")
    puts "Created a second robot from set2 at installed_robot2.png"
  else
    puts "Error: No image was created!"
  end
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")
end