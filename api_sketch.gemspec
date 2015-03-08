# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_sketch/version'

Gem::Specification.new do |spec|
  spec.name          = "api_sketch"
  spec.version       = ApiSketch::VERSION
  spec.authors       = ["Alexey Suhoviy"]
  spec.email         = ["martinsilenn@gmail.com"]
  spec.summary       = %q{API Prototyping and API Documentation Tool}
  spec.description   = %q{Gem provides DSL for API documentation generation and API request stubs}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'mixlib-cli'
  spec.add_dependency 'mixlib-config'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
