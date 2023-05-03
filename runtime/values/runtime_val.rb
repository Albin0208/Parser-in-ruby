class RunTimeVal
    attr_reader :value#, :type
  
    def initialize(value, type)
      @value = value
      @type = type
    end
  
    def !
      raise TypeError, "unsupported operand types for !: #{@type}"
    end
  
    def -@
      raise TypeError, "unsupported operand types for -: #{@type}"
    end
  
    def +@
      raise TypeError, "unsupported operand types for +: #{@type}"
    end
    
    def +(other)
      raise TypeError, "unsupported operand types for +: #{@type} and #{other.type}"
    end
  
    def -(other)
      raise TypeError, "unsupported operand types for -: #{@type} and #{other.type}"
    end
  
    def *(other)
      raise TypeError, "unsupported operand types for *: #{@type} and #{other.type}"
    end
  
    def /(other)
      raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
    end
  
    def %(other)
      raise TypeError, "unsupported operand types for %: #{@type} and #{other.type}"
    end
  
    def <(other)
      raise TypeError, "unsupported operand types for <: #{@type} and #{other.type}"
    end
  
    def >(other)
      raise TypeError, "unsupported operand types for >: #{@type} and #{other.type}"
    end
  
    def >=(other)
      raise TypeError, "unsupported operand types for >=: #{@type} and #{other.type}"
    end
  
    def <=(other)
      raise TypeError, "unsupported operand types for <=: #{@type} and #{other.type}"
    end
  
    def !=(other)
      BooleanVal.new(@value == other.value && @type == other.type)
    end
  
    def ==(other)
      BooleanVal.new(@value == other.value && @type == other.type)
    end
  
    def to_s
      @value.to_s
    end
  
    def type
      return @type
    end
  end