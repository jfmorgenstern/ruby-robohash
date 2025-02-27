require_relative 'lib/robohash/version'

Gem::Specification.new do |spec|
  spec.name          = "robohash"
  spec.version       = Robohash::VERSION
  spec.authors       = ["Josch Morgenstern"]
  spec.email         = ["josh@fritzing.org"]

  spec.summary       = "Generate unique robot avatars from strings"
  spec.description   = "Robohash is a Ruby gem for generating unique robot avatars based on string inputs based on https://github.com/e1ven/Robohash"
  spec.homepage      = "https://github.com/jfmorgenstern/ruby-robohash"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage
  }

  # Include all the files
  spec.files = Dir["lib/**/*", "assets/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "mini_magick", "~> 4.11"
  spec.add_dependency "naturally", "~> 2.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
end