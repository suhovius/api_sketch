class ApiSketch::Model::Base

  attr_accessor :name, :description

  def initialize(attributes = {})
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

end