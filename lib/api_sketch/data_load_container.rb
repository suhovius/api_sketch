# TODO: Move this logic to ApiSketch::Model::Resource (ApiSketch::DSL)
#       Also provide reload feature.
class ApiSketch::DataLoadContainer
  include ApiSketch::DSL

  def initialize(definitions_dir)
    @definitions_dir = definitions_dir
  end

  def init!
    Dir.glob("#{@definitions_dir}/**/*.rb").each do |file_path|
      puts_info("\t read: #{file_path}")
      binding.eval(File.open(File.expand_path(file_path)).read, file_path)
    end
  end

  class << self
    def load_definitions!(definitions_dir)
      self.new(definitions_dir).init!
    end
  end
end