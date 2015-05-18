class ApiSketch::DSL::ComplexAttributeParser < ApiSketch::DSL::AttributeParser

  def method_missing(method_name, *arguments, &block)
    if method_name == :content
      @attribute_values[:content] = ApiSketch::DSL::Attributes.new(@container_type, &block).to_a
    else
      super(method_name, *arguments, &block)
    end
  end

end
