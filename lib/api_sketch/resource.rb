class ApiSketch::Resource < ApiSketch::Base

  attr_accessor :path, :http_method, :format, :hearders, :parameters, :response


  class << self

    def create(attributes)
      self.add(self.new(attributes))
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