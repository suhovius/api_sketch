class ApiSketch::Model::Attribute < ApiSketch::Model::Base
  attr_accessor :data_type, :value, :example, :required, :default, :content

  def example_value
    self.example.respond_to?(:call) ? self.example.call : self.example
  end

  def to_hash
    {
      data_type: self.data_type,
      example_value: self.example_value,
      required: !!self.required,
      default: self.default,
      content: self.content_to_hash
    }
  end

  def content_to_hash
    if self.content
      self.content.map do |item|
        item.to_hash
      end
    end
  end

end
