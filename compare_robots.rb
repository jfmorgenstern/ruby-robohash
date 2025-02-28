# compare_robots.rb
require 'rmagick'

def compare_images(generated_path, reference_path, threshold = 0.01)
  puts "Comparing #{generated_path} with #{reference_path}..."

  begin
    generated = Magick::Image.read(generated_path).first
    reference = Magick::Image.read(reference_path).first

    # Compare the images using Mean Squared Error metric
    difference = generated.compare_channel(reference, Magick::MeanSquaredErrorMetric)
    similarity = 1.0 - difference[1]

    puts "Similarity: #{(similarity * 100).round(2)}%"

    # Save difference visualization
    diff_path = "difference_#{File.basename(generated_path)}"
    difference[0].write(diff_path)
    puts "Difference image saved to #{diff_path}"

    if similarity >= (1.0 - threshold)
      puts "✅ Images match within threshold"
      return true
    else
      puts "❌ Images differ beyond threshold"
      return false
    end
  rescue => e
    puts "Error comparing images: #{e.message}"
    return false
  end
end

# Compare both sets of robot images
set1_passed = compare_images('installed_robot.png', 'example-robots/installed_robot.png')
set2_passed = compare_images('installed_robot2.png', 'example-robots/installed_robot2.png')

# Exit with status code based on results
exit(set1_passed && set2_passed ? 0 : 1)
