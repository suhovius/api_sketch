resource "Get user points" do
  action "index"
  description "User points"
  path "/api/users/username/points.json"
  http_method "GET"
  format "json"

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :array do
          document do
            content do
              integer "items" do
                description "user's items"
                example { rand(1000) }
              end

              integer "rank" do
                description "user's rank"
                example { ["Test User", "Real User"].sample }
              end
            end
          end
        end
      end
    end
  end

end
