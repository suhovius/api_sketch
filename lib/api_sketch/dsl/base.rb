# All DSL clases should inherit this Base class
class ApiSketch::DSL::Base

  def use_shared_block(name)
    self.instance_eval(&::ApiSketch::Model::SharedBlock.find(name))
  end

end
