resource "Update user profile" do
  description "Authenticated user could update his profile fields and password"
  path "/api/users/me"
  http_method "PUT"
  format "json"
end