class ApiSketch::Model::Header < ApiSketch::Model::Base
  attr_accessor :value, :example, :required

  def example_value
    self.example.respond_to?(:call) ? self.example.call : self.example
  end
end