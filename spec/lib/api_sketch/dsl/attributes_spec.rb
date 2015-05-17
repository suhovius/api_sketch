require "spec_helper"

describe ApiSketch::DSL::Attributes do

  let(:simple_instance) {
    described_class.new(:document, &(Proc.new {}) )
  }

  context "instance methods" do
    subject { simple_instance }
    it_should_behave_like "supports shared blocks"
  end

end
