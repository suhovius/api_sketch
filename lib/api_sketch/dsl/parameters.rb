class ApiSketch::DSL::Parameters

  TYPES = [:integer, :string, :float, :datetime, :timestamp, :document]

  def initialize(&block)
    @params = []
    define_singleton_method(:initialize_parameters, block)
    initialize_parameters
  end

  def to_a
    @params
  end

  TYPES.each do |type_name|
    define_method(type_name) do |name, &block|
      @params << self.class.build_by(type_name, name, &block)
    end
  end

  class << self
    def build_by(data_type, attribute_name, &block)
      case data_type
      when :document
        ::ApiSketch::Model::Parameter.new(::ApiSketch::DSL::DocumentParser.new(&block).to_h.merge(data_type: :document, name: attribute_name))
      else
        ::ApiSketch::Model::Parameter.new(::ApiSketch::DSL::AttributeParser.new(&block).to_h.merge(data_type: data_type, name: attribute_name))
      end
    end
  end

end

