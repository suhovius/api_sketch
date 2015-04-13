require 'mixlib/cli'

class ApiSketch::Runner
  include Mixlib::CLI

  option :help,
    :short        => '-h',
    :long         => '--help',
    :description  => 'Show this help',
    :on           => :tail,
    :boolean      => true,
    :show_options => true,
    :exit         => 0

  option :definitions_dir,
    :short        => '-i DEFINITIONS',
    :long        => '--input DEFINITIONS',
    :description  => 'Path to the folder with api definitions',
    :required     => true

  option :documentation_dir,
    :short        => '-o DOCUMENTATION',
    :long         => '--output DOCUMENTATION',
    :description  => "Path to the folder where generated documentation should be saved (Default is 'documentation' folder in current folder)",
    :default      => 'documentation'

  option :generate,
    :short        => '-g',
    :long         => '--generate',
    :description  => 'Generate documentation from provided definitions',
    :boolean      => true

  option :examples_server,
    :short        => '-s',
    :long         => '--server',
    :description  => 'Run api examples server',
    :boolean      => true

  option :examples_server_port,
    :short        => '-p PORT',
    :long         => '--port PORT',
    :description  => 'Api examples server port (Default is 3127)',
    :default      => 3127

  option :debug,
    :short        => '-d',
    :long         => '--debug',
    :description  => 'Run in verbose mode',
    :boolean      => true

  option :project_name,
    :short        => '-n',
    :long         => '--name PROJECT_NAME',
    :description  => 'Name of the project. (Default is derived from DEFINITIONS folder name)'

  option :version,
    :short        => '-v',
    :long         => '--version',
    :description  => 'Show version number',
    :proc         => lambda { |_| puts ::ApiSketch::VERSION },
    :exit         => 0


  def run
    parse_options

    if config[:generate] || config[:examples_server]
      raise ApiSketch::Error, "Definitions parameter should be a directory" unless File.directory?(config[:definitions_dir])
      config[:project_name] = File.basename(config[:definitions_dir]).gsub("_", " ").gsub(/\w+/, &:capitalize) if (config[:project_name].nil? || config[:project_name].empty?)
      puts config[:project_name]
    end

    ::ApiSketch::Config.merge!(config)

    if config[:generate]
      ApiSketch::Generators::Bootstrap.new(config).generate!
    end

    if config[:examples_server]
      ::ApiSketch::Model::Resource.reload!(config[:definitions_dir])

      builder = Rack::Builder.new do
        use ::Rack::PostBodyContentTypeParser
        use ::Rack::NestedParams
        run ::ApiSketch::ExamplesServer
      end

      Rack::Handler::WEBrick.run builder, :Port => config[:examples_server_port]
    end
  end

end