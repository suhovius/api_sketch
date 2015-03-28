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
      # Ensure that we have empty resources set for each test
      ApiSketch::Model::Resource.reset!

      @block = Proc.new do
        resource "API endpoint name" do
          action "show"
          namespace "endpoints"
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
              integer "page" do
                description "page number"
                required false
                default 1
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
                example { Time.at(1423179337).to_s }
              end

              timestamp "seconds" do
                description "seconds today"
                example { 1423179342 }
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

                  document "stats" do
                    content do
                      timestamp "login_at" do
                      end

                      integer "login_count" do
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
                      string "email" do
                        description "user's email value"
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
      expect(!!headers[1].required).to eql false # Here this value is nil actually
    end

    it "should set proper request parameters" do
      query = @resource.parameters.query

      expect(query[0].name).to eql "page"
      expect(query[0].data_type).to eql :integer
      expect(query[0].description).to eql "page number"
      expect(!!query[0].required).to eql false
      expect(query[0].default).to eql 1

      expect(query[1].name).to eql "name"
      expect(query[1].data_type).to eql :string
      expect(query[1].description).to eql "place name"
      expect(query[1].required).to eql true

      expect(query[2].name).to eql "range"
      expect(query[2].data_type).to eql :float
      expect(query[2].description).to eql "search range in km"
      expect(query[2].example_value).to be_instance_of(Float)

      expect(query[3].name).to eql "start_at"
      expect(query[3].data_type).to eql :datetime
      expect(query[3].description).to eql "start at datetime"
      expect(query[3].example_value).to eql Time.at(1423179337).to_s

      expect(query[4].name).to eql "seconds"
      expect(query[4].data_type).to eql :timestamp
      expect(query[4].description).to eql "seconds today"
      expect(query[4].example_value).to eql 1423179342

      expect(query[5].name).to eql "place_ids"
      expect(query[5].data_type).to eql :array
      expect(query[5].description).to eql "user's places ids"

      array_content = query[5].content
      expect(array_content[0].description).to eql "hello number"
      expect(array_content[0].data_type).to eql :integer
      expect(array_content[1].description).to eql "more text here"
      expect(array_content[1].data_type).to eql :string
      document = array_content[2]
      expect(document.data_type).to eql :document
      expect(document.content[0].name).to eql "is_it_true"
      expect(document.content[0].data_type).to eql :boolean
    end

    it "should set proper body parameters" do
      body = @resource.parameters.body
      expect(body[0].data_type).to eql :document
      expect(body[0].name).to eql "user"
      expect(body[0].description).to eql "user's parameters fields"
      expect(body[0].required).to eql true

      document_content = body[0].content
      expect(document_content[0].data_type).to eql :string
      expect(document_content[0].name).to eql "email"
      expect(document_content[0].description).to eql "user's email value"
      expect(document_content[1].data_type).to eql :document
      expect(document_content[1].name).to eql "stats"

      inner_content = document_content[1].content
      expect(inner_content[0].name).to eql "login_at"
      expect(inner_content[0].data_type).to eql :timestamp
      expect(inner_content[1].name).to eql "login_count"
      expect(inner_content[1].data_type).to eql :integer
    end

    it "should set proper responses" do
      responses = @resource.responses
      # Success
      expect(responses[0].format).to eql "json"
      expect(responses[0].headers).to eql []
      expect(responses[0].http_status).to eql :ok
      expect(responses[0].name).to eql "Success"
      expect(responses[0].parameters.body[0].data_type).to eql :document
      document_content = responses[0].parameters.body[0].content
      expect(document_content[0].name).to eql "email"
      expect(document_content[0].description).to eql "user's email value"
      expect(document_content[0].data_type).to eql :string
      # Bad request
      expect(responses[1].format).to eql "json"
      expect(responses[1].headers).to eql []
      expect(responses[1].http_status).to eql :bad_request
      expect(responses[1].name).to eql "Failure"
      expect(responses[1].parameters.body[0].name).to eql "error"
      expect(responses[1].parameters.body[0].data_type).to eql :document
      expect(responses[1].parameters.body[0].content[0].name).to eql "message"
      expect(responses[1].parameters.body[0].content[0].description).to eql "Error description"
      expect(responses[1].parameters.body[0].content[0].data_type).to eql :string
      expect(responses[1].parameters.body[0].content[0].example_value).to eql "Epic fail at your parameters"
    end

  end

  context "shared_block" do
    before do
      class TestEvaluator
        include ApiSketch::DSL
      end
    end

    context "definition" do
      before do
        definition = Proc.new do
          string "username" do
            description "unique user name"
          end
          integer "age" do
          end
        end

        @definition_block = definition

        @shared_block = Proc.new do
          shared_block("short user data", definition)
        end
      end

      it "should define and save shared_block code into predefined storage" do
        TestEvaluator.new.instance_eval(&@shared_block)

        expect(ApiSketch::Model::SharedBlock.find("short user data")).to eql @definition_block
      end

      context "when this block is predefined" do
        before do
          @block = lambda do
            document do
              content do
                string "test_key" do
                end

                shared "short user data"
              end
            end
          end
        end

        it "should call this block and put it's data in the definition" do
          attributes = ApiSketch::DSL::Attributes.new(:array, &@block).to_a
          attribute = attributes.first
          expect(attribute.data_type).to eql :document
          string_key = attribute.content.first
          expect(string_key.data_type).to eql :string
          expect(string_key.name).to eql "test_key"

          expect(attribute.content[1].name).to eql "username"
          expect(attribute.content[1].data_type).to eql :string
          expect(attribute.content[2].name).to eql "age"
          expect(attribute.content[2].data_type).to eql :integer
        end
      end

      context "when this block is not defined" do
        before do
          @invalid_block = lambda do
            document do
              content do
                string "test_key" do
                end

                shared "non existing shared data"
              end
            end
          end
        end

        it "should raise error" do
          expect { ApiSketch::Model::SharedBlock.find("non existing shared data") }.to raise_error(::ApiSketch::Error, "Shared block 'non existing shared data' is not defined")
        end
      end

    end
  end
end