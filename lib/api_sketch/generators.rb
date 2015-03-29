module ApiSketch::Generators

	class Base

	  attr_accessor :definitions_dir, :documentation_dir

	  attr_reader :templates_folder

	  # TODO: Add here some validations for folders existance, etc
	  def initialize(options = {})
	    self.definitions_dir = options[:definitions_dir]
	    self.documentation_dir = options[:documentation_dir]
	    @templates_folder = File.expand_path("templates/#{self.class.name.split("::").last.downcase}", File.dirname(__FILE__))
	  end

	  def generate!
      puts_info("Load definitions")
	    load_definitions
      puts_info("Create documentation directory")
      puts_info("\t path: #{self.documentation_dir}")
	    create_documentation_directory
      puts_info("Create documentation files")
	    create_documentation_files
	  end

	  private
	    def create_documentation_directory
        FileUtils.rm_r(self.documentation_dir, :force => true)
	      FileUtils.mkdir_p(self.documentation_dir)
	    end

	    # TODO: This is unfinished sample file generator it should be more complex at some other generators
	    #       Other generors should inherit from this class and implement this method
	    def create_documentation_files
	      raise "This method should be implemented at child class who inherits from ApiSketch::Generators::Base"
	    end

	    def load_definitions
        ApiSketch::Model::Resource.reload!(self.definitions_dir)
	    end

	end


	class Bootstrap < ApiSketch::Generators::Base

    def initialize(options = {})
      super(options)
      @resource_template = ERB.new(File.read("#{self.templates_folder}/resource.html.erb"))
    end

    # This is defined here because it is related for this type of generator only
    def filename_for(resource)
      resource.id + '.html'
    end

    private
      def copy_assets
        # copy assets from template directory
        source = File.join(self.templates_folder, 'assets')
        target = File.join(self.documentation_dir, 'assets')
        FileUtils.copy_entry(source, target)
      end

      def create_documentation_files
        @generator = self
        copy_assets
        @resources = ApiSketch::Model::Resource.all
        @resources.each do |resource|
          @resource = resource

          filename = File.join(self.documentation_dir, filename_for(@resource))
          html_data = @resource_template.result(binding)

          dir = File.dirname(filename)
          unless File.directory?(dir)
            puts_info("\t create directory: #{dir}")
            FileUtils.mkdir_p(dir)
          end

          puts_info("\t write: #{filename}")
          File.open(filename, 'w+') { |file| file.write(html_data) }
        end
      end
  end

end