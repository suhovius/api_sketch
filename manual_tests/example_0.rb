resource "Update user profile" do
  description "Authenticated user could update his profile fields and password"
  path "/api/users/me"
  http_method "PUT"
  format "json"

  headers do
    name "Authorization" do
      value "Token token=:token_value"
      description ":token_value - is an authorization token value"
      example { (:A..:z).to_a.shuffle[0,16].join }
    end
  end
end