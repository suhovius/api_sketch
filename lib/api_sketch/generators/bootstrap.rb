class ApiSketch::Generators::Bootstrap < ApiSketch::Generators::Base

  def initialize(options = {})
    super(options)
    @resource_template = ERB.new(File.read("#{self.templates_folder}/resource.html.erb"))
  end

  private
    def copy_assets
      # copy assets from template directory
      source = File.join(self.templates_folder, 'assets')
      target = File.join(self.documentation_dir, 'assets')
      FileUtils.copy_entry(source, target)
    end

    def create_documentation_files
      copy_assets
      @resources = ApiSketch::Model::Resource.all
      File.open("#{self.documentation_dir}/index.txt", "w+") do |file|
        @resources.each do |resource|
          @resource = resource
          filename = File.join(self.documentation_dir, "#{@resource.id}.html")

          html_data = @resource_template.result(binding)
          File.open(filename, 'w+') { |file| file.write(html_data) }
        end
      end
    end
end