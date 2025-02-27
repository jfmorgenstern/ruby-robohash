# lib/robohash/generator.rb
require "digest/sha2"
require "mini_magick"
require "naturally"
require "fileutils"

module Robohash
  class Generator
    attr_reader :img, :format

    def initialize(string, hashcount = 11, ignoreext = true)
      # Default to png
      @format = 'png'

      # Optionally remove an images extension before hashing
      string = remove_exts(string) if ignoreext

      string = string.encode('utf-8')

      hash = Digest::SHA512.hexdigest(string)
      @hexdigest = hash
      @hasharray = []

      # Start this at 4, so earlier is reserved
      # 0 = Color
      # 1 = Set
      # 2 = bgset
      # 3 = BG
      @iter = 4
      create_hashes(hashcount)

      @resourcedir = File.join(File.dirname(__FILE__), '..', '..', 'assets')
      # Get the list of backgrounds and RobotSets
      @sets = list_dirs(File.join(@resourcedir, 'sets'))
      @bgsets = list_dirs(File.join(@resourcedir, 'backgrounds'))

      # Get the colors in set1
      @colors = list_dirs(File.join(@resourcedir, 'sets', 'set1'))
    end

    def remove_exts(string)
      # If the user hasn't disabled it, we will detect image extensions
      # We'll remove them from the string before hashing
      if string.downcase.end_with?('.png', '.gif', '.jpg', '.bmp', '.jpeg', '.ppm', '.datauri')
        format = string[string.rindex('.') + 1..-1]
        format = 'jpeg' if format.downcase == 'jpg'
        @format = format
        string = string[0...string.rindex('.')]
      end
      string
    end

    def create_hashes(count)
      # Breaks up our hash into slots, so we can pull them out later
      count.times do |i|
        # Get 1/numblocks of the hash
        blocksize = (@hexdigest.length / count).to_i
        currentstart = (1 + i) * blocksize - blocksize
        currentend = (1 + i) * blocksize
        @hasharray << @hexdigest[currentstart...currentend].to_i(16)
      end

      # Workaround for adding more sets in 2019
      # We run out of blocks, because we use some for each set, whether it's called or not
      @hasharray = @hasharray + @hasharray
    end

    def list_dirs(path)
      return [] unless File.directory?(path)
      entries = Dir.entries(path).select do |entry| 
        File.directory?(File.join(path, entry)) && !entry.start_with?('.')
      end
      Naturally.sort(entries)
    end

    def get_random_file_from_dir(dir)
      return nil unless File.directory?(dir)
      files = Dir.entries(dir).reject { |f| f.start_with?('.') }
      files = files.select { |f| File.file?(File.join(dir, f)) }
      return nil if files.empty?

      element_in_list = @hasharray[@iter] % files.length
      @iter += 1

      File.join(dir, files[element_in_list])
    end

    def get_parts_for_set1(color)
      parts = []
      color_dir = File.join(@resourcedir, 'sets', 'set1', color)

      # Get all component directories (like 000#Mouth, 001#Eyes, etc)
      component_dirs = list_dirs(color_dir).sort

      # For each component directory, select a random file
      component_dirs.each do |comp_dir|
        full_comp_dir = File.join(color_dir, comp_dir)
        random_file = get_random_file_from_dir(full_comp_dir)
        parts << random_file if random_file
      end

      # Sort parts by the number after the # in the directory name
      # This ensures correct layering order
      parts.sort_by do |part|
        dir_name = File.basename(File.dirname(part))
        render_order = dir_name.split("#")[1] || ""
        render_order
      end
    end

    def get_parts_for_other_sets(set)
      parts = []
      set_dir = File.join(@resourcedir, 'sets', set)

      # Get all component directories and sort them
      component_dirs = list_dirs(set_dir).sort

      # For each component directory, select a random file
      component_dirs.each do |comp_dir|
        full_comp_dir = File.join(set_dir, comp_dir)
        random_file = get_random_file_from_dir(full_comp_dir)
        parts << random_file if random_file
      end

      # Sort parts by the number after the # in the directory name
      parts.sort_by do |part|
        dir_name = File.basename(File.dirname(part))
        render_order = dir_name.split("#")[1] || ""
        render_order
      end
    end

    def assemble(roboset: nil, color: nil, format: nil, bgset: nil, sizex: 300, sizey: 300)
      # Allow users to manually specify a robot 'set' that they like
      if roboset == 'any'
        roboset = @sets[@hasharray[1] % @sets.length]
      elsif @sets.include?(roboset)
        # use the specified set
      else
        roboset = @sets[0]
      end

      # Get the robot parts based on the set
      if roboset == 'set1'
        # Handle color selection for set1
        if @colors.include?(color)
          selected_color = color
        else
          selected_color = @colors[@hasharray[0] % @colors.length]
        end

        roboparts = get_parts_for_set1(selected_color)
      else
        roboparts = get_parts_for_other_sets(roboset)
      end

      # If they specified a background, ensure it's legal
      background_file = nil
      if @bgsets.include?(bgset)
        bg_dir = File.join(@resourcedir, 'backgrounds', bgset)
        bg_files = Dir.entries(bg_dir).reject { |f| f.start_with?('.') }
        bg_files = bg_files.select { |f| File.file?(File.join(bg_dir, f)) }

        if !bg_files.empty?
          bg_index = @hasharray[3] % bg_files.length
          background_file = File.join(bg_dir, bg_files[bg_index])
        end
      elsif bgset == 'any' && !@bgsets.empty?
        selected_bgset = @bgsets[@hasharray[2] % @bgsets.length]
        bg_dir = File.join(@resourcedir, 'backgrounds', selected_bgset)
        bg_files = Dir.entries(bg_dir).reject { |f| f.start_with?('.') }
        bg_files = bg_files.select { |f| File.file?(File.join(bg_dir, f)) }

        if !bg_files.empty?
          bg_index = @hasharray[3] % bg_files.length
          background_file = File.join(bg_dir, bg_files[bg_index])
        end
      end

      # If we don't have any parts, return early
      return self if roboparts.empty?

      # Create a base image from the first part
      begin
        roboimg = MiniMagick::Image.open(roboparts[0])
        roboimg.resize "1024x1024"

        # Add each subsequent part
        roboparts[1..-1].each do |part_path|
          next unless File.exist?(part_path)

          part = MiniMagick::Image.open(part_path)
          part.resize "1024x1024"

          result = roboimg.composite(part) do |c|
            c.compose "Over"
          end
          roboimg = result
        end

        # Add background if specified
        if background_file && File.exist?(background_file)
          bg = MiniMagick::Image.open(background_file)
          bg.resize "1024x1024"

          # Create a composite with background (background goes first, then robot on top)
          result = bg.composite(roboimg) do |c|
            c.compose "Over"
          end
          roboimg = result
        end

        # If we're a BMP or JPEG, flatten the image
        if ['bmp', 'jpeg'].include?(format.to_s.downcase)
          roboimg.flatten
        end

        # Final resize to requested dimensions
        roboimg.resize "#{sizex}x#{sizey}"
        @img = roboimg
        @format = format || @format
      rescue => e
        puts "Error assembling robot: #{e.message}"
        puts e.backtrace.join("\n")
      end

      self
    end
  end
end
