shared_examples_for "supports shared blocks" do
  it "should support shared blocks" do
    ApiSketch::DSL.new.shared_block "test data" do
      "test shared block data"
    end

    expect(subject.use_shared_block("test data")).to eql "test shared block data"
  end
end
