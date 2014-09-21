class ApiSketch::DSL::Parameters

  def initialize(&block)
    @params = []
    define_singleton_method(:initialize_parameters, block)
    initialize_parameters
  end

  def to_a
    @params
  end

  def integer(name, &block)
    @params << ::ApiSketch::Model::Parameter.new(::ApiSketch::DSL::AttributeParser.new(&block).to_h.merge(data_type: "integer", name: name))
  end

end