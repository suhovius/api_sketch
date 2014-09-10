class ApiSketch::AttributeParser

  attr_reader :parameters

  def initialize(&block)
    @parameters = {}
    define_singleton_method(:set_parameters, block)
    set_parameters
  end

  def method_missing(method_name, *argumets, &block)
    @parameters[method_name] = argumets.first || block
  end

end