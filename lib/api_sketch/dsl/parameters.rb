class ApiSketch::DSL::Parameters < ApiSketch::DSL::Base

  def initialize(&block)
    @query = []
    @body = []
    @query_container_type = nil
    @body_container_type = nil
    define_singleton_method(:initialize_parameters_list, block)
    initialize_parameters_list
  end

  def to_h
    {
      query: @query,
      body: @body,
      query_container_type: @query_container_type,
      body_container_type: @body_container_type
    }
  end

  def query(container_type, &block)
    @query_container_type = container_type
    @query += ::ApiSketch::DSL::Attributes.new(container_type, &block).to_a
  end

  def body(container_type, &block)
    @body_container_type = container_type
    @body += ::ApiSketch::DSL::Attributes.new(container_type, &block).to_a
  end

end
