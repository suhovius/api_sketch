require "spec_helper"

describe ApiSketch::DSL::AttributeParser do

  let(:simple_instance) {
    ApiSketch::DSL::AttributeParser.new(:document, &(Proc.new {}) )
  }

  context "instance methods" do
    it "should support shared blocks" do
      ApiSketch::DSL.new.shared_block "test data" do
        "test shared block data"
      end

      expect(simple_instance.use_shared_block("test data")).to eql "test shared block data"
    end
  end
end
