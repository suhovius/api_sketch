# ruby manual_tests/generator_test.rb

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "api_sketch"

gen = ApiSketch::Generators::Bootstrap.new
gen.generate!