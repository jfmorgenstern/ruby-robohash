# lib/robohash.rb
require "robohash/version"
require "robohash/generator"

module Robohash
  def self.new(string, hashcount = 11, ignoreext = true)
    Generator.new(string, hashcount, ignoreext)
  end
end
