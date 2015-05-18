class ApiSketch::DSL::Attributes < ApiSketch::DSL::Base

  TYPES = [:integer, :string, :float, :boolean, :datetime, :timestamp, :document, :array]

  def initialize(container_type, &block)
    @container_type = container_type
    @params = []
    define_singleton_method(:initialize_attributes, block)
    initialize_attributes
  end

  def to_a
    @params
  end

  TYPES.each do |type_name|
    define_method(type_name) do |*args, &block|
      name = args.first
      if @container_type == :document
        if name.nil? || name.empty? # key name is not provided
          raise ::ApiSketch::Error.new, "Key inside document should have name"
        end
      elsif @container_type == :array
        if (!name.nil? && !name.empty?) # key name is provided
          raise ::ApiSketch::Error.new, "Array element can't have name"
        end
      end
      @params << self.class.build_by(type_name, name, &block)
    end
  end

  class << self
    def build_by(data_type, attribute_name, &block)
      options = {data_type: data_type}
      options[:name] = attribute_name if attribute_name
      case data_type
      when :document, :array
        ::ApiSketch::Model::Attribute.new(::ApiSketch::DSL::ComplexAttributeParser.new(data_type, &block).to_h.merge(options))
      else
        ::ApiSketch::Model::Attribute.new(::ApiSketch::DSL::AttributeParser.new(data_type, &block).to_h.merge(options))
      end
    end
  end

end
