resource "Get place details" do
  action "show"
  description "Place details"
  path "/api/places/:place_id.json"
  http_method "GET"
  format "json"

  parameters do
    query :array do
      string do
        description "place name"
      end

      integer do
        description "search radius"
      end
    end
  end

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :document do
          use_shared_block "place fields"
        end
      end
    end
  end

end

resource "Create place" do
  action "create"
  path "/api/places.json"
  http_method "POST"
  format "json"

  parameters do
    body :document do
      string "name" do
        description "Place name"
        example { ["Cafe", "Market", "Restaurant", "Parking", "Park", "Palace", "Stadium"].sample }
      end

      float "area" do
        description "Place area in square meters"
        example { rand(100) + rand.round(2) }
      end
    end
  end

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :document do
          use_shared_block "place fields"
        end
      end
    end
  end

  sample_call 'curl -v -H "Authorization: Token token=CFd6Sh_dCRT1DhwQQg9N" -H "Accept: application/json" -H "Content-type: application/json" -X POST -d \'{ "name" : "Cafe", "area" : "123.5" }\' http://:domain/api/places.json'

end


resource "Update place" do
  action "update"
  path "/api/places/:place_id.json"
  http_method "PUT"
  format "json"

  parameters do
    body :document do
      string "name" do
        description "Place name"
        example { ["Cafe", "Market", "Restaurant", "Parking", "Park", "Palace", "Stadium"].sample }
      end

      float "area" do
        description "Place area in square meters"
        example { rand(100) + rand.round(2) }
      end
    end
  end

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :document do
          use_shared_block "place fields"
        end
      end
    end
  end

end

resource "Get places list" do
  action "index"
  path "/api/places.json"
  http_method "GET"
  format "json"

  parameters do
    query :document do
      integer "page" do
        description "Pagination page"
        default 1
      end

      integer "per_page" do
        description "Pagination place per page"
        default 25
      end
    end
  end

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :array do
          document do
            content do
              use_shared_block "place fields"
            end
          end
        end
      end
    end
  end
end
