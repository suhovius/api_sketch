lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "api_sketch"


extend(ApiSketch::DSL)


resource "Update user profile" do
  description "Authenticated user could update his profile fields and password"
  path "/api/users/me"
  http_method "PUT"
  format "json"
end