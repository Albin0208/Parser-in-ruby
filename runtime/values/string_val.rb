require_relative 'runtime_val'

class StringVal < RunTimeVal
    def initialize(value)
      super(value, :string)
    end
  
    def +(other)
      StringVal.new(@value + other.value)
    end
  
    def *(other)
      StringVal.new(@value * other.value)
    end
  
    def !=(other)
      BooleanVal.new(@value != other.value)
    end
  
    def ==(other)
      BooleanVal.new(@value == other.value)
    end
  
    def length
      return NumberVal.new(@value.length, :int)
    end
  end