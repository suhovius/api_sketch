class ApiSketch::Model::Resource < ApiSketch::Model::Base

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

    def first
      self.all.first
    end

    def last
      self.all.last
    end

    def count
      self.all.count
    end

  end

end

