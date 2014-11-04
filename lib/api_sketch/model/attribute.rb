class ApiSketch::Model::Attribute < ApiSketch::Model::Base
  attr_accessor :data_type, :value, :example, :required, :default, :content

  def example_value
    self.example.respond_to?(:call) ? self.example.call : self.example
  end

  def data_type_details
  	if self.data_type == :array
  	  "#{self.data_type} of #{self.content.map(&:data_type).join(", ")}"
  	else
  	  self.data_type
  	end
  end
end