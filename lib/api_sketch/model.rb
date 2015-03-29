module ApiSketch::Model

  class Base

    attr_accessor :name, :description

    def initialize(attributes = {})
      attributes = default_values_hash.merge(attributes)
      attributes.each do |attribute, value|
        self.send("#{attribute}=", value)
      end
    end

    private
      def default_values_hash
        {}
      end

  end


  class Attribute < ApiSketch::Model::Base
    attr_accessor :data_type, :value, :example, :required, :default, :content

    def example_value(defaults_allowed=false)
      value = self.example
      value ||= example_value_default if defaults_allowed

      value.respond_to?(:call) ? value.call : value
    end

    # TODO: These default values should be configurable via DSL
    #       Some logic to defer value example from key name, - email from key with email part inside, etc.
    def example_value_default
      {
        integer:   lambda { rand(1000) + 1 },
        string:    lambda { "random_string_#{('A'..'Z').to_a.shuffle.first(8).join}" },
        float:     lambda { rand(100) + rand(100) * 0.01 },
        boolean:   lambda { [true, false].sample },
        datetime:  lambda { Time.now.strftime("%d-%m-%Y %H:%M:%S") },
        timestamp: lambda { Time.now.to_i }
      }[data_type]
    end

    def to_hash
      {
        data_type: self.data_type,
        example_value: self.example_value,
        required: !!self.required,
        default: self.default,
        content: self.content_to_hash
      }
    end

    def content_to_hash
      if self.content
        self.content.map do |item|
          item.to_hash
        end
      end
    end

  end


  class Header < ApiSketch::Model::Base
    attr_accessor :value, :example, :required

    def example_value
      self.example.respond_to?(:call) ? self.example.call : self.example
    end
  end


  class Parameters < ApiSketch::Model::Base
    attr_accessor :query, :body

    def initialize(attributes = {})
      super(attributes)
      self.query ||= []
      self.body ||= []
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


  class Resource < ApiSketch::Model::Base

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
        self.reset!
        ApiSketch::DSL.new(definitions_dir).init!
      end

      def all
        @resources ||= []
      end

      def find(id)
        self.all.find { |res| res.id == id }
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

      def run_validations!
        unless self.action =~ /\A\w*\z/
          message = "'#{self.action}' is invalid action value"
          # puts_error(message)
          raise ::ApiSketch::Error, message
        end

        if self.class.find(self.id)
          message =  "'#{self.id}' is not unique id. Change values of 'namespace' and/or 'action' attributes"
          # puts_error(message)
          raise ::ApiSketch::Error, message
        end
      end

  end


  class Response < ApiSketch::Model::Base
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

  module SharedBlock
    @list_hash = {}

    class << self
      def add(name, block)
        @list_hash[name] = block
      end

      def find(name)
        @list_hash[name] || raise(::ApiSketch::Error, "Shared block '#{name}' is not defined")
      end
    end
  end

end