class ApiSketch::DSL::Responses

  def initialize(&block)
    @list = []
    define_singleton_method(:initialize_responses_list, block)
    initialize_responses_list
  end

  def to_a
    @list
  end

  def context(name, &block)
    attributes = ::ApiSketch::DSL::AttributeParser.new(&block).to_h
    if attributes[:body]
      attributes[:body] = ::ApiSketch::DSL::Attributes.new(&attributes[:body]).to_a
    end
    @list << ::ApiSketch::Model::Response.new(attributes.merge(name: name))
  end

end