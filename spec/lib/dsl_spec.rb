require "spec_helper"

describe ApiSketch::DSL do
  context "document" do
  	context "when all data has key names" do
      before do
        @block = lambda do
          document do
            content do
              string "test_key" do
              end
            end
          end
        end
      end

  		it "should successfully create objects" do
        attributes = ApiSketch::DSL::Attributes.new(:array, &@block).to_a
        attribute = attributes.first
        expect(attribute.data_type).to eql :document
        string_key = attribute.content.first
        expect(string_key.data_type).to eql :string
        expect(string_key.name).to eql "test_key"
      end
  	end

    context "when data doesn't have key name" do
      before do
        @invalid_block = lambda do
          document do
            content do
              string do
              end
            end
          end
        end
      end

      it "should return error" do
        expect { ApiSketch::DSL::Attributes.new(:array, &@invalid_block) }.to raise_error(::ApiSketch::Error, "Key inside document should have name")
      end
    end
  end

  context "array" do
    context "when elements don't have names" do
      before do
        @block = lambda do
          array do
            content do
              string do
              end
            end
          end
        end
      end

      it "should successfully create objects" do
        attributes = ApiSketch::DSL::Attributes.new(:array, &@block).to_a
        attribute = attributes.first
        expect(attribute.data_type).to eql :array
        string_key = attribute.content.first
        expect(string_key.data_type).to eql :string
        expect(string_key.name).to be_nil
      end
    end

    context "when elements have names" do
      before do
        @invalid_block = lambda do
          array do
            content do
              string "some_name_here" do
              end
            end
          end
        end
      end

      it "should return error" do
        expect { ApiSketch::DSL::Attributes.new(:array, &@invalid_block) }.to raise_error(::ApiSketch::Error, "Array element can't have name")
      end
    end
  end

  context "resource" do
    before do
      @block = Proc.new do
        resource "API endpoint name" do
          description "API endpoint description"
          path "/api/endpoint/link.json"
          http_method "PUT"
          format "json"

          headers do
            add "Authorization" do
              value "Token token=:token_value"
              description ":token_value - is an authorization token value"
              example { "some_data_#{Time.now.hour}" }
              required true
            end

            add "X-Test" do
              value "Test=:perform_test"
              description ":perform_test - test boolean value"
              example true
            end
          end

          parameters do
            query do
              string "hello_message" do
                description "some message"
              end

              integer "repeat_times" do
                description "times to repeat hello message"
              end
            end

            query do
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

            body do
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
                body do
                  document do
                    content do
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
                      document "country" do
                        content do
                          string "name" do
                            description "Country name"
                          end
                          string "id" do
                            example :location_code
                            description "Country ID (Location code)"
                          end
                        end
                      end
                      array "authentications" do
                        content do
                          document do
                            content do
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
                  end
                end
              end
            end

            context "Failure" do
              http_status :bad_request # 400

              parameters do
                body do
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
      end

      class TestEvaluator
        include ApiSketch::DSL
      end

      TestEvaluator.new.instance_eval(&@block)
      @resource = ApiSketch::Model::Resource.all.find { |r| r.name == "API endpoint name" }
    end

    it "should successfully create correct resource object" do
      expect(@resource.name).to eql "API endpoint name"
      expect(@resource.description).to eql "API endpoint description"
      expect(@resource.path).to eql "/api/endpoint/link.json"
      expect(@resource.http_method).to eql "PUT"
      expect(@resource.format).to eql "json"
    end

    it "should set proper request headers" do
      headers = @resource.headers
      expect(headers[0].name).to eql "Authorization"
      expect(headers[0].value).to eql "Token token=:token_value"
      expect(headers[0].description).to eql ":token_value - is an authorization token value"
      expect(headers[0].example).to be_instance_of(Proc)
      expect(headers[0].example_value).to eql "some_data_#{Time.now.hour}"
      expect(headers[0].required).to be true

      expect(headers[1].name).to eql "X-Test"
      expect(headers[1].value).to eql "Test=:perform_test"
      expect(headers[1].description).to eql ":perform_test - test boolean value"
      expect(headers[1].example).to eql true
      expect(!!headers[1].required).to eql false # Here this value is nil
    end
  end
end