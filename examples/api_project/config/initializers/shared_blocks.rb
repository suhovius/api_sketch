shared_block "place fields" do
  integer "id" do
    description "Place database ID"
  end

  string "name" do
    description "Place name"
    example { ["Cafe", "Market", "Restaurant", "Parking", "Park", "Palace", "Stadium"].sample }
  end

  float "area" do
    description "Place area in square meters"
    example { rand(100) + rand.round(2) }
  end
end
