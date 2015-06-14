module ApiSketch::Generators
  class Bootstrap < ApiSketch::Generators::Base

    # Generated folders structure is
    #   docs - html folders and files
    #   assets - js, css and images. Html styling

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

      def docs_folder
        # Left assets directory outside since it may clash with generated files/folders names.
        # Put generated html pages to 'docs' folder
        "#{self.documentation_dir}/docs"
      end

      def create_documentation_files
        @generator = self
        copy_assets
        @resources = ApiSketch::Model::Resource.all
        @resources.each do |resource|
          @resource = resource

          filename = File.join(docs_folder, filename_for(@resource))
          html_data = @resource_template.result(binding)

          dir = File.dirname(filename)
          unless File.directory?(dir)
            puts_info("\t create directory: #{dir}")
            FileUtils.mkdir_p(dir)
          end

          puts_info("\t write: #{filename}")
          File.open(filename, 'w+') { |file| file.write(html_data) }
        end

        if @resources.count > 0
          # Create index page
          index_template = ERB.new(File.read("#{self.templates_folder}/index.html.erb"))
          filename = File.join(docs_folder, "index.html")
          puts_info("\t write: #{filename}")
          File.open(filename, 'w+') { |file| file.write(index_template.result(binding)) }
        end
      end
  end
end
