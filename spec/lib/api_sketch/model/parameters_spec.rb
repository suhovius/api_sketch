require "spec_helper"

describe ApiSketch::Model::Parameters do

  context "instance methods" do
    let(:instance) {
      element_1 = ApiSketch::Model::Attribute.new(data_type: "string", value: "Test")
      ApiSketch::Model::Parameters.new({query: [], body: [element_1], body_container_type: "array", query_container_type: "document"})
    }

    describe "#wrapped_body" do
      it "should return ApiSketch::Model::Attribute object" do
        attribute = instance.wrapped_body
        expect(attribute.content).to eql instance.body
        expect(attribute.data_type).to eql "array"
      end
    end

    describe "#wrapped_query" do
      it "should return ApiSketch::Model::Attribute object" do
        attribute = instance.wrapped_query
        expect(attribute.content).to eql instance.query
        expect(attribute.data_type).to eql "document"
      end
    end
  end

end
