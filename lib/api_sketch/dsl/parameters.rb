class ApiSketch::DSL::Parameters

  TYPES = [:integer, :string, :float, :datetime, :timestamp, :document, :array]

  def initialize(&block)
    @params = []
    define_singleton_method(:initialize_parameters, block)
    initialize_parameters
  end

  def to_a
    @params
  end

  TYPES.each do |type_name|
    define_method(type_name) do |*args, &block|
      name = args.first
      @params << self.class.build_by(type_name, name, &block)
    end
  end

  class << self
    def build_by(data_type, attribute_name, &block)
      options = {data_type: data_type}
      options[:name] = attribute_name if attribute_name
      case data_type
      when :document, :array
        ::ApiSketch::Model::Parameter.new(::ApiSketch::DSL::DocumentParser.new(&block).to_h.merge(options))
      else
        ::ApiSketch::Model::Parameter.new(::ApiSketch::DSL::AttributeParser.new(&block).to_h.merge(options))
      end
    end
  end

end

