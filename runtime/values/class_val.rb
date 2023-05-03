require_relative 'runtime_val'

class ClassVal < RunTimeVal
    attr_reader :class_instance
  
    def initialize(value, class_instance)
      super(value, value.to_sym)
      @class_instance = class_instance
    end
  
    def !=(other)
      BooleanVal.new(!(other == self))
    end
  
    def ==(other)
      return BooleanVal.new(true) if other.object_id.equal?(self.object_id)
  
      BooleanVal.new(false)
    end
  end