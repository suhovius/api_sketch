class ApiSketch::Model::Response < ApiSketch::Model::Base
  attr_accessor :http_status, :parameters, :format, :headers

  private
    def default_values_hash
      {
        format: "json",
        headers: [],
        parameters: ::ApiSketch::Model::Parameters.new
      }
    end
end
