class ApiSketch::DataLoadContainer
  include ApiSketch::DSL

  def initialize(definitions_dir)
    @definitions_dir = definitions_dir
  end

  def init!
    Dir.glob("#{@definitions_dir}/**/*.rb").each do |file_path|
      eval(File.read(file_path))
    end
  end
end