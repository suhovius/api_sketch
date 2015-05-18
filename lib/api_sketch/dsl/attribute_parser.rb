class ApiSketch::DSL::AttributeParser < ApiSketch::DSL::Base

  def initialize(container_type, &block)
    @attribute_values = {}
    @container_type = container_type
    # INFO: Such long method name is used to ensure that we are would not have such value as key at hash
    define_singleton_method(:set_attributes_as_hash_value_format, block)
    set_attributes_as_hash_value_format
  end

  def method_missing(method_name, *arguments, &block)
    @attribute_values[method_name] = arguments.first || block
  end

  def to_h
    @attribute_values
  end

end
