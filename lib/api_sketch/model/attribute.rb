class ApiSketch::Model::Attribute < ApiSketch::Model::Base
  attr_accessor :data_type, :value, :example, :required, :default, :content

  def example_value
    self.example.respond_to?(:call) ? self.example.call : self.example
  end
end