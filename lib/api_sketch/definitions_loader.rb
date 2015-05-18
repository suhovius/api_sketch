class DefinitionsLoader

  def initialize(dsl)
    @dsl = dsl
  end

  def load!
    if File.directory?(config_dir)
      puts_info("Load configuration")
      load_dir_files(config_dir)
    end

    if File.directory?(resources_dir)
      puts_info("Load resources")
      load_dir_files(resources_dir)
    else
      # old logic support
      puts_info("Load definitions")
      load_dir_files(definitions_dir)
    end
  end

  private
    def definitions_dir
      @dsl.definitions_dir
    end

    def config_dir
      "#{definitions_dir}/config"
    end

    def resources_dir
      "#{definitions_dir}/resources"
    end

    def load_dir_files(dir)
      Dir.glob("#{dir}/**/*.rb").each do |file_path|
        puts_info("\t read: #{file_path}")
        @dsl.evaluate_file(file_path)
      end
    end
end
