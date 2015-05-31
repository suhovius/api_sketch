class ApiSketch::Model::Parameters < ApiSketch::Model::Base
  attr_accessor :query, :body, :query_container_type, :body_container_type

  def initialize(attributes = {})
    super(attributes)
    self.query ||= []
    self.body ||= []
  end

  def wrapped_query
    ApiSketch::Model::Attribute.new(data_type: self.query_container_type, content: self.query)
  end

  def wrapped_body
    ApiSketch::Model::Attribute.new(data_type: self.body_container_type, content: self.body)
  end

  def as_full_names
    fullname_params = self.class.new
    [:query, :body].each do |param_location|
      new_params = []
      self.send(param_location).each do |param|
        if param.data_type == :document
          full_names_for(param, param.name, new_params)
        else
          new_params << param
        end
      end
      fullname_params.send("#{param_location}=", new_params)
    end
    fullname_params
  end

  private
    def full_names_for(param, name = "", new_params)
      name = name.to_s # ensure that this value is always a string
      if param.content.kind_of?(Array)
        param.content.each do |attribute|
          renamed_attribute = attribute.clone
          renamed_attribute.name = name.empty? ? attribute.name.to_s : "#{name}[#{attribute.name}]"
          if renamed_attribute.data_type == :document
            full_names_for(renamed_attribute, renamed_attribute.name, new_params)
          else
            new_params << renamed_attribute
          end
        end
      end
    end
end

