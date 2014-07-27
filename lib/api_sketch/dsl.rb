module ApiSketch::DSL

  def resource(name, &block)
    attributes = AttributeParser.new(&block).parameters.merge(name: name)
    ::ApiSketch::Resource.create(attributes)
  end

end