resource "Get user points stats" do
  action "index"
  description "User points stats"
  path "/api/users/username/points/stats.json"
  http_method "GET"
  format "json"

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :document do
          document "stats" do
            content do
              string "total" do
                description "total amount"
                example { rand(100) }
              end
              string "rank" do
                description "user's rank"
                example { ["Junior", "Middle", "Senior"].sample }
              end
            end
          end
        end
      end
    end
  end
end
