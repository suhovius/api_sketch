class ApiSketch::DSL::DocumentParser < ApiSketch::DSL::AttributeParser

  def method_missing(method_name, *arguments, &block)
    if method_name == :content
      @attribute_values[:content] = ApiSketch::DSL::Parameters.new(&block).to_a
    else
      super(method_name, *arguments, &block)
    end
  end

end