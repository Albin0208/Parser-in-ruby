module Runtime
  module Values
    #
    # The object representing a boolean value
    # @example
    #   bool a = true
    #   bool b = false
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
    # @example
    #   bool a = !true 
    #   a #=> false
    #   !a #=> true
    def !
      Values::BooleanVal.new(!@value)
    end
    
    # Compares the current boolean value object with another value for inequality.
    #
    # @param other [RunTimeVal] the value to compare with
    # @return [BooleanVal] a new boolean value object indicating whether the values are unequal
    # @example
    #   true != true #=> false
    #   true != false #=> true
    #   false != false #=> false
    #
    #   bool a = true
    #   bool b = false
    #   a != b #=> true
    def !=(other)
      Values::BooleanVal.new(@value != other.value)
    end
    
    # Compares the current boolean value object with another value for equality.
    #
    # @param other [RunTimeVal] the value to compare with
    # @return [BooleanVal] a new boolean value object indicating whether the values are equal
    #
    # @example
    #   true == true #=> true
    #   true == false #=> false
    #   false == false #=> true
    #
    #   bool a = true
    #   bool b = false
    #   a == b #=> false
    def ==(other)
      Values::BooleanVal.new(@value == other.value)
    end
    end
  end
end
