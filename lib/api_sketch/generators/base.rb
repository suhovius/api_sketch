class ApiSketch::Generators::Base

  attr_accessor :definitions_dir, :documentation_dir

  attr_reader :templates_folder

  # TODO: Add here some validations for folders existance, etc
  def initialize(options = {})
    self.definitions_dir = options[:definitions_dir] || "definitions" # input data
    self.documentation_dir = options[:documentation_dir] || "documentation" # output data
    @templates_folder = File.expand_path("../templates/#{self.class.name.split("::").last.downcase}", File.dirname(__FILE__))
  end

  def generate!
    load_definitions
    create_documentation_directory
    create_documentation_files
  end

  private
    def create_documentation_directory
      FileUtils.mkdir_p(self.documentation_dir)
    end

    # TODO: This is unfinished sample file generator it should be more complex at some other generators
    #       Other generors should inherit from this class and implement this method
    def create_documentation_files
      File.open("#{self.documentation_dir}/index.txt", "w+") do |file|
        ApiSketch::Model::Resource.all.each do |resource|
          file.puts(resource.name)
        end
      end
    end

    def load_definitions
      container = ApiSketch::DataLoadContainer.new(self.definitions_dir)
      container.init!
    end

end