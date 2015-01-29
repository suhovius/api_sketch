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
end