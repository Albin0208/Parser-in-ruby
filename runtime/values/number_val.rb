require_relative 'runtime_val'

class NumberVal < RunTimeVal
    def -@
      NumberVal.new(-@value, type)
    end
  
    def +@
      NumberVal.new(+@value, type)
    end
  
    def +(other)
      NumberVal.new(@value + other.value, type)
    end
  
    def -(other)
      NumberVal.new(@value - other.value, type)
    end
  
    def *(other)
      NumberVal.new(@value * other.value, type)
    end
  
    def /(other)
      NumberVal.new(@value / other.value, type)
    end
  
    def %(other)
      NumberVal.new(@value % other.value, type)
    end
  
    def <(other)
      BooleanVal.new(@value < other.value)
    end
  
    def >(other)
      BooleanVal.new(@value > other.value)
    end
  
    def >=(other)
      BooleanVal.new(@value >= other.value)
    end
  
    def <=(other)
      BooleanVal.new(@value <= other.value)
    end
  
    def !=(other)
      BooleanVal.new(@value != other.value)
    end
  
    def ==(other)
      BooleanVal.new(@value == other.value)
    end
  
    def to_int()
      return NumberVal.new(@value.to_i, :int)
    end
  
    def to_float()
      return NumberVal.new(@value.to_f, :float)
    end
  end