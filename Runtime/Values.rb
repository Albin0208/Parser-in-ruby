class RunTimeVal
    attr_reader :value, :type
  
    def initialize(value, type)
      @value = value
      @type = type
    end
  
    def ==(other)
      @value == other.value && @type == other.type
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

    def to_s
        return "Value: #{@value}, Type: #{@type}"
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
end

class BooleanVal < RunTimeVal
    def initialize(value = true)
        super(value, :boolean)
    end
end

class NullVal < RunTimeVal
    def initialize()
        super(value, :null)
    end
end

# class RunTimeVal
#     attr_accessor :value, :type
#     def initialize(value, type)
#         @value = value
#         @type = type
#     end

#     def to_s
#         return "Value: #{@value}, Type: #{@type}"
#     end
# end