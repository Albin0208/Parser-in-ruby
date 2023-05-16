module Runtime
  module Values
    #
    # The object representing a boolean value
    #
    class BooleanVal < RunTimeVal
    # Creates a new boolean value object.
    #
    # @param value [Boolean] the value to store in the object
    def initialize(value = true)
      super(value, :bool)
    end
    
    # Returns a new boolean value object with the opposite value of the current object.
    #
    # @return [BooleanVal] a new boolean value object with the opposite value of the current object
    def !
      Values::BooleanVal.new(!@value)
    end
    
    # Compares the current boolean value object with another value for inequality.
    #
    # @param other [RunTimeVal] the value to compare with
    # @return [BooleanVal] a new boolean value object indicating whether the values are unequal
    def !=(other)
      Values::BooleanVal.new(@value != other.value)
    end
    
    # Compares the current boolean value object with another value for equality.
    #
    # @param other [RunTimeVal] the value to compare with
    # @return [BooleanVal] a new boolean value object indicating whether the values are equal
    def ==(other)
      Values::BooleanVal.new(@value == other.value)
    end
    end
  end
end
