class ApiSketch::Model::Base

  attr_accessor :name, :description

  def initialize(attributes = {})
    attributes = default_values_hash.merge(attributes)
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  private
    def default_values_hash
      {}
    end

end
