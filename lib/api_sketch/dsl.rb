class ApiSketch::DSL

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
