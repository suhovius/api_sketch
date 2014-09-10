class ApiSketch::Resource < ApiSketch::Base

  attr_accessor :path, :http_method, :format, :headers, :parameters, :response

  class << self

    def create(attributes)
      res = self.new(attributes)
      self.add(res)
      res
    end

    def add(resource)
      @resources ||= []
      @resources << resource
    end

    def all
      @resources ||= []
    end

  end

end

