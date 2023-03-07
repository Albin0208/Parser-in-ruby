class RunTimeVal
    attr_reader :value, :type
  
    def initialize(value, type)
      @value = value
      @type = type
    end

    def +(other)
      raise TypeError, "unsupported operand types for +: #{@type} and #{other.type}"
    end
  
    def -(other)
      raise TypeError, "unsupported operand types for -: #{@type} and #{other.type}"
    end

    def !()
        raise TypeError, "unsupported operand types for -: #{@type} and #{other.type}"
    end
  
    def *(other)
      raise TypeError, "unsupported operand types for *: #{@type} and #{other.type}"
    end
  
    def /(other)
      raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
    end

    def %(other)
        raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
    end

    def <(other)
        raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
    end

    def >(other)
        raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
    end

    def >=(other)
        raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
    end

    def <=(other)
        raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
    end

    def !=(other)
        raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
    end

    def ==(other)
        @value == other.value && @type == other.type
    end
    
    def to_s
        return @value
    end
end

class NumberVal < RunTimeVal
    def initialize(value)
        super(value, :number)
    end

    def +(other)
        return NumberVal.new(@value + other.value)
      end
    
    def -(other)
        return NumberVal.new(@value - other.value)
    end

    def *(other)
        return NumberVal.new(@value * other.value)
    end

    def /(other)
        return NumberVal.new(@value / other.value)
    end

    def %(other)
        return NumberVal.new(@value % other.value)
    end

    def <(other)
        return BooleanVal.new(@value < other.value)
    end

    def >(other)
        return BooleanVal.new(@value > other.value)
    end

    def >=(other)
        return BooleanVal.new(@value >= other.value)
    end

    def <=(other)
        return BooleanVal.new(@value <= other.value)
    end

    def !=(other)
        return BooleanVal.new(@value != other.value)
    end

    def ==(other)
        return BooleanVal.new(@value == other.value)
    end
end

class BooleanVal < RunTimeVal
    def initialize(value = true)
        super(value, :boolean)
    end

    def !=(other)
        return BooleanVal.new(@value != other.value)
    end

    def ==(other)
        return BooleanVal.new(@value == other.value)
    end
end

class NullVal < RunTimeVal
    def initialize()
        super("null", :null)
    end
end