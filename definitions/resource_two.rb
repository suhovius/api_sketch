resource "Get user profile" do
  description "Authenticated user could get data from his profile"
  path "/api/users/me"
  http_method "GET"
  format "json"

  headers do
    add "Authorization" do
      value "Token token=:token_value"
      description ":token_value - is an authorization token value"
      example { (:A..:z).to_a.shuffle[0,16].join }
    end
  end
end