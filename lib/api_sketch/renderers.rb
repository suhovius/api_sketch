class ApiSketch::ResponseRenderer

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def to_h
    placeholder_type = (params.count == 1 && params.first.data_type == :array) ? :array : :document
    render_content(params, placeholder_type)
  end

  def to_json
    self.to_h.to_json
  end

  # TODO: Add this feature in future
  # def to_xml
  #   XML conversion code here
  # end

  private
    def render_content(items, placeholder_type)
      placeholder = case placeholder_type
      when :array then []
      when :document then {}
      end

      items.each do |param, index|
        value =  if [:array, :document].include?(param.data_type) && param.content
          render_content(param.content, param.data_type)
        else
          param.example_value(true)
        end

        case placeholder_type
        when :array
          placeholder << value
        when :document
          placeholder[param.name] = value
        end
      end

      placeholder
    end

end
