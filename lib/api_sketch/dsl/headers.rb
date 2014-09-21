class ApiSketch::DSL::Headers

  def initialize(&block)
    @list = []
    define_singleton_method(:initialize_headers_list, block)
    initialize_headers_list
  end

  def to_a
    @list
  end

  def add(name, &block)
    @list << ::ApiSketch::Model::Header.new(::ApiSketch::DSL::AttributeParser.new(&block).to_h.merge(name: name))
  end

end