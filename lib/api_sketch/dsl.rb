class ApiSketch::DSL

  # All DSL clases should inherit this Base class
  class Base

    def use_shared_block(name)
      self.instance_eval(&::ApiSketch::Model::SharedBlock.find(name))
    end

  end

  class AttributeParser < ApiSketch::DSL::Base

    def initialize(container_type, &block)
      @attribute_values = {}
      @container_type = container_type
      # INFO: Such long method name is used to ensure that we are would not have such value as key at hash
      define_singleton_method(:set_attributes_as_hash_value_format, block)
      set_attributes_as_hash_value_format
    end

    def method_missing(method_name, *arguments, &block)
      @attribute_values[method_name] = arguments.first || block
    end

    def to_h
      @attribute_values
    end

  end

  class Attributes < ApiSketch::DSL::Base

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

  class ComplexAttributeParser < ApiSketch::DSL::AttributeParser

    def method_missing(method_name, *arguments, &block)
      if method_name == :content
        @attribute_values[:content] = ApiSketch::DSL::Attributes.new(@container_type, &block).to_a
      else
        super(method_name, *arguments, &block)
      end
    end

  end


  class Headers < ApiSketch::DSL::Base

    def initialize(&block)
      @list = []
      define_singleton_method(:initialize_headers_list, block)
      initialize_headers_list
    end

    def to_a
      @list
    end

    def add(name, &block)
      @list << ::ApiSketch::Model::Header.new(::ApiSketch::DSL::AttributeParser.new(:document, &block).to_h.merge(name: name))
    end

  end

  class Parameters < ApiSketch::DSL::Base

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

  class Responses < ApiSketch::DSL::Base

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


  # Main DSL class

  attr_reader :definitions_dir

  COMPLEX_ATTRIBUTE_NAMES = [:headers, :parameters, :responses]

  def initialize(definitions_dir=ApiSketch::Config[:definitions_dir])
    @definitions_dir = definitions_dir
  end

  def init!
    if File.directory?(config_dir)
      puts_info("Load configuration")
      load_dir_files(config_dir)
    end

    if File.directory?(resources_dir)
      puts_info("Load resources")
      load_dir_files(resources_dir)
    end
  end

  def shared_block(name, &block)
    ::ApiSketch::Model::SharedBlock.add(name, block)
  end

  def resource(name, &block)
    attributes = get_attrs(name, &block)

    COMPLEX_ATTRIBUTE_NAMES.each do |attribute_name|
      block_value = attributes[attribute_name]
      attributes[attribute_name] = get_complex_attribute(attribute_name, &block_value) if block_value
    end

    # Assign resource namespace
    attributes[:namespace] ||= block.source_location[0].gsub(resources_dir, "").gsub(".rb", "").split("/").reject { |ns| ns.nil? || ns == "" }.join("/")

    ::ApiSketch::Model::Resource.create(attributes)
  end

  private

    def get_attrs(name, &block)
      ::ApiSketch::DSL::AttributeParser.new(:root, &block).to_h.merge(name: name)
    end

    def get_complex_attribute(attribute_name, &block)
      case attribute_name
      when :headers
        ::ApiSketch::DSL::Headers.new(&block).to_a
      when :parameters
        params = ::ApiSketch::DSL::Parameters.new(&block).to_h
        ::ApiSketch::Model::Parameters.new(params)
      when :responses
        ::ApiSketch::DSL::Responses.new(&block).to_a
      end
    end


    # Definitions loading
    def config_dir
      "#{definitions_dir}/config"
    end

    def resources_dir
      "#{definitions_dir}/resources"
    end

    def load_dir_files(dir)
      Dir.glob("#{dir}/**/*.rb").each do |file_path|
        puts_info("\t read: #{file_path}")
        binding.eval(File.open(File.expand_path(file_path)).read, file_path)
      end
    end


end
