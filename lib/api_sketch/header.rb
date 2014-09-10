class ApiSketch::Header < ApiSketch::Base
  attr_accessor :value, :example

  def example_value
    self.example.respond_to?(:call) ? self.example.call : self.example
  end
end