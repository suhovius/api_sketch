require "api_sketch"

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
  end

  parameters do
    object "user" do
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
    end
  end

  response do
    context "Success" do
      http_status :ok # 200
      body do
        object do
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
          object "country" do
            string "name" do
              description "Country name"
            end
            string "id" do
              example :location_code
              description "Country ID (Location code)"
            end
          end
          array "authentications" do
            object do
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
    context "Failure" do
      
    end
  end

end