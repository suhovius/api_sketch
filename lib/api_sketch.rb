require 'erb'
require 'fileutils'

module ApiSketch
  require "api_sketch/version"
  require "api_sketch/dsl"
  require "api_sketch/model"
  require "api_sketch/dsl/attribute_parser"
  require "api_sketch/dsl/complex_attribute_parser"
  require "api_sketch/dsl/headers"
  require "api_sketch/dsl/attributes"
  require "api_sketch/dsl/parameters"
  require "api_sketch/dsl/responses"
  require "api_sketch/model/base"
  require "api_sketch/model/header"
  require "api_sketch/model/attribute"
  require "api_sketch/model/parameters"
  require "api_sketch/model/resource"
  require "api_sketch/model/response"
  require "api_sketch/data_load_container"
  require "api_sketch/generators"
  require "api_sketch/generators/base"
  require "api_sketch/generators/bootstrap"
end