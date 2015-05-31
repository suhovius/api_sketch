class ApiSketch::Model::Attribute < ApiSketch::Model::Base
  attr_accessor :data_type, :value, :example, :required, :default, :content

  def example_value(defaults_allowed=false)
    value = self.example
    value ||= example_value_default if defaults_allowed

    value.respond_to?(:call) ? value.call : value
  end

  # TODO: These default values should be configurable via DSL
  #       Some logic to defer value example from key name, - email from key with email part inside, etc.
  def example_value_default
    {
      integer:   lambda { rand(1000) + 1 },
      string:    lambda { "random_string_#{('A'..'Z').to_a.shuffle.first(8).join}" },
      float:     lambda { rand(100) + rand(100) * 0.01 },
      boolean:   lambda { [true, false].sample },
      datetime:  lambda { Time.now.strftime("%d-%m-%Y %H:%M:%S") },
      timestamp: lambda { Time.now.to_i }
    }[data_type]
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
