# coding: utf-8
require File.expand_path('../lib/api_sketch/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "api_sketch"
  spec.version       = ApiSketch::VERSION
  spec.authors       = ["Alexey Suhoviy"]
  spec.email         = ["martinsilenn@gmail.com"]
  spec.summary       = %q{API Prototyping and API Documentation Tool}
  spec.description   = %q{Gem provides DSL for API documentation generation and API request examples server}

  spec.homepage      = "https://github.com/suhovius/api_sketch"

  spec.license       = "MIT"
  spec.post_install_message = "Thanks for installing!"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'mixlib-cli'
  spec.add_dependency 'mixlib-config'
  spec.add_dependency 'rack'
  spec.add_dependency 'rack-contrib'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
