module ApiSketch::DSL

  COMPLEX_ATTRIBUTE_NAMES = [:headers, :parameters, :response]

  def resource(name, &block)
    attributes = get_attrs(name, &block)

    COMPLEX_ATTRIBUTE_NAMES.each do |attribute_name|
      block_value = attributes[attribute_name]
      attributes[attribute_name] = get_complex_attribute(attribute_name, &block_value) if block_value
    end

    ::ApiSketch::Model::Resource.create(attributes)
  end


  private
    def get_attrs(name, &block)
      ::ApiSketch::DSL::AttributeParser.new(&block).to_h.merge(name: name)
    end

    def get_complex_attribute(attribute_name, &block)
      case attribute_name
      when :headers
        ::ApiSketch::DSL::Headers.new(&block).to_a
      when :parameters
        ::ApiSketch::DSL::Attributes.new(&block).to_a
      when :response
        nil # TODO: This should be implemented
      end
    end

end