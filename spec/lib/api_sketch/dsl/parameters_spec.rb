require "spec_helper"

describe ApiSketch::DSL::Parameters do

  let(:simple_instance) {
    described_class.new( &(Proc.new {}) )
  }

  context "instance methods" do
    subject { simple_instance }
    it_should_behave_like "supports shared blocks"
  end

end
