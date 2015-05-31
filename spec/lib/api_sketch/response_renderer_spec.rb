require "spec_helper"

describe ApiSketch::ResponseRenderer do

  before do
    # Ensure that we have empty resources set for each test
    ApiSketch::Model::Resource.reset!
  end

  let(:simple_resource) {
    Proc.new do
      resource "Simple data" do
        action "show"
        namespace "simple_data"
        path "/api/test_data.json"
        http_method "GET"
        format "json"

        responses do
          context "Success" do
            http_status :ok # 200

            parameters do
              body :document do
                string "key" do
                  example { "value" }
                end
              end
            end
          end
        end
      end
    end
  }


  let(:array_response) {
    Proc.new do
      resource "Array of documents" do
        action "index"
        namespace "simple_data"
        path "/api/test_datas.json"
        http_method "GET"
        format "json"

        responses do
          context "Success" do
            http_status :ok

            parameters do
              body :array do
                document do
                  description "some data"
                  content do
                    string "name" do
                      example { "Test User #{rand(100)}" }
                    end
                    integer "id" do
                      example { rand(100) + 1 }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  }

  let(:resource_example_definition) {
    Proc.new do
      resource "Get test data" do
        action "index"
        namespace "test_endpoints"
        path "/api/test_data.json"
        http_method "GET"
        format "json"

        responses do
          context "Success" do
            http_status :ok # 200

            parameters do
              body :document do
                document "user" do
                  content do
                    integer "id" do
                      description "User's ID"
                      example { 123 }
                    end
                    string "email" do
                      description "user's email value"
                      example { "user_test@email.com" }
                    end

                    array "same_data" do
                      content do
                        integer do
                          example { 42 }
                        end
                      end
                    end

                    array "values" do
                      content do
                        string do
                          example { "Pizza" }
                        end
                        integer do
                          example { 100500 }
                        end
                        document do
                          content do
                            string "key" do
                              example { "Text" }
                            end
                            timestamp "time" do
                              example { 1430761823 }
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
        end
      end
    end
  }

  context "instance methods" do

    describe "#to_h" do
      it "should render data properly" do
        ApiSketch::DSL.new.instance_eval(&resource_example_definition)
        response = ApiSketch::Model::Resource.find("test_endpoints/index").responses.find { |rsp| rsp.name == "Success" }
        result = ApiSketch::ResponseRenderer.new(response.parameters.body, response.parameters.body_container_type, 3).to_h

        expected_hash = {
          "user" =>
            {
              "id" => 123,
              "email" => "user_test@email.com",
              "same_data" => [42, 42, 42],
              "values" =>
                ["Pizza", 100500, {"key"=>"Text", "time"=>1430761823},
                  "Pizza", 100500, {"key"=>"Text", "time"=>1430761823},
                  "Pizza", 100500, {"key"=>"Text", "time"=>1430761823}]
            }
        }

        expect(result).to eql expected_hash
      end

      context "array root response" do
        it "should return proper elements amount at response array" do
          ApiSketch::DSL.new.instance_eval(&array_response)
          response = ApiSketch::Model::Resource.find("simple_data/index").responses.find { |rsp| rsp.name == "Success" }
          size = 7
          result = ApiSketch::ResponseRenderer.new([response.parameters.wrapped_body], response.parameters.body_container_type, size).to_h

          expect(result.size).to eql size
          result.each do |element|
            expect(element["name"]).to be_instance_of(String)
            expect(element["id"]).to be_kind_of(Numeric)
          end
        end
      end
    end


    describe "#to_json" do
      it "should return proper json" do
        ApiSketch::DSL.new.instance_eval(&simple_resource)
        response = ApiSketch::Model::Resource.find("simple_data/show").responses.find { |rsp| rsp.name == "Success" }
        result = ApiSketch::ResponseRenderer.new(response.parameters.body, response.parameters.body_container_type, 1).to_json

        expected_json = {"key" => "value"}.to_json
        expect(result).to eql expected_json
      end
    end
  end

end
