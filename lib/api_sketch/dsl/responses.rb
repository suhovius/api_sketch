class ApiSketch::DSL::Responses < ApiSketch::DSL::Base

  def initialize(&block)
    @list = []
    define_singleton_method(:initialize_responses_list, block)
    initialize_responses_list
  end

  def to_a
    @list
  end

  def context(name, &block)
    attributes = ::ApiSketch::DSL::AttributeParser.new(:root, &block).to_h
    if attributes[:parameters]
      params = ::ApiSketch::DSL::Parameters.new(&attributes[:parameters]).to_h
      attributes[:parameters] = ::ApiSketch::Model::Parameters.new(params)
    end
    @list << ::ApiSketch::Model::Response.new(attributes.merge(name: name))
  end

end
