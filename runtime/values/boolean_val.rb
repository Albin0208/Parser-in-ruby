require_relative 'runtime_val'

class BooleanVal < RunTimeVal
    def initialize(value = true)
      super(value, :bool)
    end
  
    def !
      BooleanVal.new(!@value)
    end
  
    def !=(other)
      BooleanVal.new(@value != other.value)
    end
  
    def ==(other)
      BooleanVal.new(@value == other.value)
    end
  end
  