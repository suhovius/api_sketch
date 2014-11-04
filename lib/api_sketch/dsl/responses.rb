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
    if attributes[:parameters]
      params = ::ApiSketch::DSL::Parameters.new(&attributes[:parameters]).to_h
      attributes[:parameters] = ::ApiSketch::Model::Parameters.new(query: params[:query], body: params[:body])
    end
    @list << ::ApiSketch::Model::Response.new(attributes.merge(name: name))
  end

end