class ApiSketch::ExamplesServer
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    if api_resource
      api_response = if api_response_context
        api_resource.responses.find { |rsp| rsp.name == api_response_context }
      else
        api_resource.responses.first
      end

      if api_response
        Rack::Response.new do |response|
          api_response.headers.each do |header|
            response[header.name] = header.value
          end

          response['Content-Type'] = 'application/json'

          response.status = Rack::Utils.status_code(api_response.http_status)

          params_array = (api_response.parameters.body_container_type.to_s == "array") ? [api_response.parameters.wrapped_body] : api_response.parameters.body

          response.write(ApiSketch::ResponseRenderer.new(params_array, api_response.parameters.body_container_type, get_elements_count).to_json)
        end
      else
        api_sketch_message("No any responses defined for this resource and context", 404)
      end
    else
      api_sketch_message("Resource is not Found", 404)
    end
  end

  private
    def api_resource
      @api_resource = if @request.params["api_sketch_resource_id"]
        ApiSketch::Model::Resource.find(@request.params["api_sketch_resource_id"])
      else
        ApiSketch::Model::Resource.find_by_http_method_and_path(@request.request_method, @request.path)
      end
    end

    def api_response_context
      @request.params["api_sketch_response_context"]
    end

    def api_sketch_message(message, status)
      Rack::Response.new({"api_sketch" => message}.to_json, 404)
    end

    def get_elements_count
      @request.params["api_sketch_response_array_elements_count"].to_i
    end
end
