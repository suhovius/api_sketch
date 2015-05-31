class ApiSketch::Model::Resource < ApiSketch::Model::Base

  attr_accessor :namespace, :action, :path, :http_method, :format, :headers, :parameters, :responses

  # TODO: update this method to provide better id that is used as part of filename
  def id
    [self.namespace, self.action].reject { |v| v.nil? || v == "" }.join("/")
  end

  class << self

    def create(attributes)
      res = self.new(attributes)
      res.send(:run_validations!)
      self.add(res)
      res
    end

    def add(resource)
      @resources ||= []
      @resources << resource
    end

    def reset!
      @resources = []
    end

    def reload!(definitions_dir)
      ApiSketch::Model::SharedBlock.reset!
      self.reset!
      ApiSketch::DSL.new(definitions_dir).init!
    end

    def all
      @resources ||= []
    end

    def find(id)
      self.all.find { |res| res.id == id }
    end

    def find_by_http_method_and_path(http_method, path)
      self.all.find { |res| res.http_method == http_method && res.path == path }
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

  private
    def default_values_hash
      {
        http_method: "GET",
        format: "json",
        headers: [],
        parameters: ::ApiSketch::Model::Parameters.new,
        responses: []
      }
    end

    def error_message(message)
      # puts_error(message)
      raise ::ApiSketch::Error, message
    end

    def run_validations!
      unless self.action =~ /\A\w*\z/
        error_message("'#{self.action}' is invalid action value")
      end

      if self.class.find(self.id)
        error_message("'#{self.id}' is not unique id. Change values of 'namespace' and/or 'action' attributes")
      end

      if self.http_method.nil? || self.http_method.empty?
        error_message("request http_method can't be blank")
      end

      if self.path.nil? || self.path.empty?
        error_message("request path can't be blank")
      end

      if self.class.find_by_http_method_and_path(self.http_method, self.path)
        error_message("Route '#{self.http_method} #{self.path}' should be unique")
      end
    end

end

