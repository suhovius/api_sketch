module ApiSketch::Model::SharedBlock
  @list_hash = {}

  class << self
    def add(name, block)
      @list_hash[name] = block
    end

    def reset!
      @list_hash = {}
    end

    def find(name)
      @list_hash[name] || raise(::ApiSketch::Error, "Shared block '#{name}' is not defined")
    end
  end
end
