class ApiSketch::DSL::AttributeParser

  def initialize(&block)
    @attribute_values = {}
    # INFO: Such long method name is used to ensure that we are would not have such value as key at hash
    define_singleton_method(:set_attributes_as_hash_value_format, block)
    set_attributes_as_hash_value_format
  end

  def method_missing(method_name, *argumets, &block)
    @attribute_values[method_name] = argumets.first || block
  end

  def to_h
    @attribute_values
  end

end