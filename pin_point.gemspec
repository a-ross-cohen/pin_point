# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pin_point/version'

Gem::Specification.new do |spec|
  spec.name          = "pin_point"
  spec.version       = PinPoint::VERSION
  spec.authors       = ["Adam Ross Cohen", "John Cihocki"]
  spec.email         = ["ross@startupgiraffe.com", "john@startupgiraffe.com"]
  spec.description   = %q{PinPoint maps IP blocks to locations.}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mongoid"
  spec.add_dependency "rake"
  spec.add_dependency "rubyzip"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
