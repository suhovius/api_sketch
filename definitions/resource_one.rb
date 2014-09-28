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
    query do
      string "hello_message" do
        description "some message"
      end

      integer "repeat_times" do
        description "times to repeat hello message"
      end
    end

    query do
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

      array "place_ids" do
        description "user's places ids"
        required false
        content do
          integer do
            description "hello number"
          end
          document do
            content do
              string "test" do
                description "test string"
              end
            end
          end
        end
      end
    end

    body do
      document "user" do
        description "user's parameters fields"
        required true
        content do
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
            content do
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
    end
  end

  responses do
    context "Success" do
      http_status :ok # 200
      body do
        document do
          content do
            integer "id" do
              description "User's ID"
            end
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
            document "country" do
              content do
                string "name" do
                  description "Country name"
                end
                string "id" do
                  example :location_code
                  description "Country ID (Location code)"
                end
              end
            end
            array "authentications" do
              content do
                document do
                  content do
                    string "uid" do
                      description "user's id at social network"
                    end
                    string "provider" do
                      example { "facebook" }
                      description "user's social network type"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    context "Failure" do

    end
  end
end