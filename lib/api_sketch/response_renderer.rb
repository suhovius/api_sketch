class ApiSketch::ResponseRenderer

  attr_reader :params, :container_type, :elements_count

  def initialize(params, container_type, elements_count)
    @params = params || {}
    @container_type = container_type
    @elements_count = elements_count > 0 ? elements_count : 3
  end

  def to_h
    render_content(params, container_type)
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
        value = if param.data_type == :array && param.content
          # Some crazy tricks to get 'elements_count' random elements
          elements_count.times.inject([]) { |a, _| a += render_content(param.content, param.data_type) }
        elsif param.data_type == :document && param.content
          render_content(param.content, param.data_type)
        else
          param.example_value(true)
        end

        case placeholder_type
        when :array
          if param.data_type == :array && param.content
            placeholder += value
          else
            placeholder << value
          end
        when :document
          placeholder[param.name] = value
        end
      end

      placeholder
    end

end
