class ApiSketch::DSL::Parameters

  def initialize(&block)
    @query = []
    @body = []
    define_singleton_method(:initialize_parameters_list, block)
    initialize_parameters_list
  end

  def to_h
    {
      query: @query,
      body: @body
    }
  end

  def query(&block)
    @query += ::ApiSketch::DSL::Attributes.new(&block).to_a
  end

  def body(&block)
    @body += ::ApiSketch::DSL::Attributes.new(&block).to_a
  end

end