module ApiSketch::DSL

  def resource(name, &block)
    attributes = get_attrs(name, &block)

    other_attributes = {}
    [:headers, :parameters, :response].each do |k|
      other_attributes[k] = attributes.delete(k)
    end

    res = ::ApiSketch::Model::Resource.create(attributes)

    # p other_attributes

    if other_attributes[:headers]
      res.headers = get_headers(&other_attributes[:headers])
    end

    res
  end


  private
    def get_attrs(name, &block)
      ::ApiSketch::DSL::AttributeParser.new(&block).parameters.merge(name: name)
    end

    def get_headers(&block)
      ::ApiSketch::DSL::Headers.new(&block).to_a
    end

end