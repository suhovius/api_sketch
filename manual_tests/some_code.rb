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

    string "name" do
      description "place name"
      required true
    end

    float "range" do
      description "search range in km"
      required false
      example { rand(100) + rand.round(2) }
    end

    datetime "start_at" do
      description "start at datetime"
      required false
      example { Time.now.to_s }
    end

    timestamp "seconds" do
      description "seconds today"
      example { Time.now.to_i }
    end

    document "user" do
      description "user's parameters fields"
      required true
      string "email" do
        description "user's email value"
      end
      string "password" do
        description "user's profile password"
      end
      string "first_name" do
        description "user's first name"
      end
      string "last_name" do
        description "user's last name"
      end
      string "country_locode" do
        example { ["US", "UA"].sample }
        description "Country location code"
      end

      document "stats" do
        timestamp "login_at" do
          description "last login timestamp"
          example { Time.now.to_i }
        end

        integer "login_count" do
          description "login count"
          example { rand(10000) }
        end

        string "rank" do
          description "users rank"
          example { ["Junior", "Middle", "Senior"].sample }
        end
      end
    end
  end
end