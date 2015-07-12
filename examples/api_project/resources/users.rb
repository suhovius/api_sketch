resource "Update user profile" do
  action "update"
  description "Authenticated user could update his profile fields and password"
  path "/api/users/me.json"
  http_method "PUT"
  format "json"

  headers do
    add "Authorization" do
      value "Token token=:token_value"
      description ":token_value - is an authorization token value"
      example { (:A..:z).to_a.shuffle[0,16].join }
      required true
    end

    add "X-Test" do
      value "Test=:perform_test"
      description ":perform_test - test boolean value"
      example true
    end
  end

  parameters do
    query :document do
      string "hello_message" do
        description "some message"
      end

      integer "repeat_times" do
        description "times to repeat hello message"
      end

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

      file "avatar" do
        description "Avatar file"
      end

      array "place_ids" do
        description "user's places ids"
        required false
        content do
          integer do
            description "hello number"
          end
          string do
            description "more text here"
          end
          document do
            content do
              boolean "is_it_true" do
              end
            end
          end
          document do
            description "some useless data :)"
            content do
              string "test" do
                description "test string"
              end
              document "keys" do
                content do
                  integer "sum" do
                  end
                  string "details text" do
                  end
                end
              end

            end
          end
        end
      end
    end

    body :document do
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

      parameters do
        body :document do
          document "user" do
            content do
              integer "id" do
                description "User's ID"
              end
              string "email" do
                description "user's email value"
                example { "user#{rand(100)}@email.com" }
              end
              string "first_name" do
                description "user's first name"
                example { "First name #{rand(100)}" }
              end
              string "last_name" do
                description "user's last name"
                example { "Last name #{rand(100)}" }
              end
              document "country" do
                content do
                  string "name" do
                    description "Country name"
                    example { ["USA", "Ukraine", "Poland"].sample }
                  end
                  string "id" do
                    example :location_code
                    description "Country ID (Location code)"
                    example { ["US", "UA", "PL"].sample }
                  end
                end
              end
              array "values" do
                content do
                  string do
                    example { ["A", "B", "C"].sample }
                  end
                  integer do
                    example { rand(100) }
                  end
                  document do
                    content do
                      string "key" do
                        example { "Test #{rand(100)}" }
                      end
                      timestamp "time" do
                        example { Time.now.to_i }
                      end
                    end
                  end
                end
              end
              array "authentications" do
                content do
                  document do
                    content do
                      string "uid" do
                        description "user's id at social network"
                        example { 5.times.map { 4.times.map { rand(10).to_s }.join }.join("-") }
                      end
                      string "provider" do
                        example { ["facebook", "twitter", "google_plus"].sample }
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
    end

    context "Failure" do
      http_status :bad_request # 400

      parameters do
        body :document do
          document "error" do
            content do
              string "message" do
                description "Error description"
                example { "Epic fail at your parameters" }
              end
            end
          end
        end
      end
    end
  end
end

resource "Get user profile" do
  action "show"
  description "Authenticated user could get data from his profile"
  path "/api/users/me.json"
  http_method "GET"
  format "json"

  headers do
    add "Authorization" do
      value "Token token=:token_value"
      description ":token_value - is an authorization token value"
      example { (:A..:z).to_a.shuffle[0,16].join }
    end
  end

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :document do
          document "user" do
            content do
              integer "id" do
                description "User's ID"
              end
              string "email" do
                description "user's email value"
                example { "user#{rand(100)}@email.com" }
              end
              string "first_name" do
                description "user's first name"
                example { "First name #{rand(100)}" }
              end
              string "last_name" do
                description "user's last name"
                example { "Last name #{rand(100)}" }
              end
            end
          end
        end
      end
    end
  end

end

resource "Create user profile" do
  action "create"
  description "User could register his profile"
  path "/api/users.json"
  http_method "POST"
  format "json"

  parameters do
    body :document do
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
        end
      end
    end
  end

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :document do
          string :token do
            description "Auth token"
          end

          string :email do
            description "User email"
          end
        end
      end
    end
  end

end
