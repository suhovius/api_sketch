class ApiSketch::DSL::DocumentParser < ApiSketch::DSL::AttributeParser

  def method_missing(method_name, *argumets, &block)
    if ::ApiSketch::DSL::Parameters::TYPES.include?(method_name)
      @attribute_values[:content] ||= []
      @attribute_values[:content] << ApiSketch::DSL::Parameters.build_by(method_name, argumets.first, &block)
    else
      super(method_name, *argumets, &block)
    end
  end

end