lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "api_sketch"


extend(ApiSketch::DSL)

resource "Update user profile" do
  description "Authenticated user could update his profile fields and password"
  path "/api/users/me"
  http_method "PUT"
  format "json"

  headers do
    add "Authorization" do
      value "Token token=:token_value"
      description ":token_value - is an authorization token value"
      example { (:A..:z).to_a.shuffle[0,16].join }
    end

    add "X-Test" do
      value "Test=:perform_test"
      description ":perform_test - test boolean value"
      example true
    end
  end

  parameters do
    integer "page" do
      description "page number"
      required false
      default 1
    end

    integer "per_page" do
      description "items per page amount"
      required false
      default 25
    end
  end
end