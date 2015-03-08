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
    :description  => 'Path to the folder where generated documentation should be saved (Defult is documentation folder in curren folder)',
    :default      => 'documentation'

  option :generate,
    :short        => '-g',
    :long         => '--generate',
    :description  => 'Generate documentation from provided definitions',
    :boolean      => true

  option :stub_server,
    :short        => '-s',
    :long         => '--short',
    :description  => 'Run api stubs server (This option is under developent)',
    :boolean      => true

  option :version,
    :short        => '-v',
    :long         => '--version',
    :description  => 'Show version number',
    :proc         => lambda { |_| puts ::ApiSketch::VERSION },
    :exit         => 0


  def run
    parse_options
    if config[:generate]
      raise ApiSketch::Error, "Definitions parameter should be a directory" unless File.directory?(config[:definitions_dir])
      ApiSketch::Generators::Bootstrap.new(config).generate!
    end

    if config[:stub_server]
      # TODO: Run rack server here
      #       This rack server should serve api request stubs
    end
  end

end