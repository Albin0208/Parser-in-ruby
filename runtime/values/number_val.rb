module Runtime
  module Values
    #
    # The object for representing a numeric value
    #
    # @example
    #   float a = 1.0  #=> 1.0
    #   int b = 1      #=> 1
    #   int c = 1.1232 #=> 1
    #   float d = 34   #=> 34.0
    class NumberVal < RunTimeVal
      # Unary minus
      #
      # @return [NumberVal] The result of negating the number value
      #
      # @example
      #   int a = 10
      #   -a #=> -10
      #   int b = -10
      #   -a #=> 10
      def -@
        Values::NumberVal.new(-@value, type)
      end

      # Unary plus
      #
      # @return [NumberVal] The result of returning the number value as positive
      #
      # @example
      #   int a = -1
      #   +a #=> 1
      def +@
        Values::NumberVal.new(+@value, type)
      end

      # Addition
      #
      # @param [NumberVal] other The other number value to add to this value
      # @return [NumberVal] The result of adding the two number values
      #
      # @example
      #   5 + 5    #=> 10
      #   5 + 5.34 #=> 10.34
      #   -5 + 5   #=> 0
      #   -5 + -5   #=> -10
      def +(other)
        Values::NumberVal.new(@value + other.value, type)
      end

      # Subtraction
      #
      # @param [NumberVal] other The other number value to subtract from this value
      # @return [NumberVal] The result of subtracting the two number values
      #
      # @example
      #   5 - 5    #=> 0
      #   5 - 5.34 #=> -0.34
      #   -5 - 5   #=> -10
      #   -5 - -5   #=> 0
      def -(other)
        Values::NumberVal.new(@value - other.value, type)
      end

      # Multiplication
      #
      # @param [NumberVal] other The other number value to multiply with this value
      # @return [NumberVal] The result of multiplying the two number values
      #
      # @example
      #   5 * 5  #=> 25
      #   5 * -5 #=> -25
      #   5 * 5.342 #=> 26.709999999999997
      #   -5 * -5 #=> 25
      def *(other)
        Values::NumberVal.new(@value * other.value, type)
      end

      # Division
      #
      # @param [NumberVal] other The other number value to divide this value by
      # @return [NumberVal] The result of dividing this number value by the other
      #
      # @example
      #   5 / 5  #=> 1
      #   5 / -5 #=> -1
      #   5 / 5.342 #=> 0.9359790340696369
      #   -5 / -5 #=> 1
      def /(other)
        Values::NumberVal.new(@value / other.value, type)
      end

      # Calculate the remainder of division
      #
      # @param [NumberVal] other The other number value to modulo this value by
      # @return [NumberVal] The result of moduloing this number value by the other
      #
      # @example
      #   100 % 3   #=> 1
      #   100 % 2   #=> 0
      #   1.34 % 2  #=> 1.34
      #   20.12 % 9 #=> 2.120000000000001
      def %(other)
        Values::NumberVal.new(@value % other.value, type)
      end

      # Less-than
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is less than the other, false otherwise
      #
      # @example
      #   1.0 < 3 #=> true
      #   1.0 < 1.0 #=> false
      #   1.0 < 0 #=> false
      #   100 < 100.0 #=> false
      #   1000 < 100 #=> false
      def <(other)
        Values::BooleanVal.new(@value < other.value)
      end

      # Greater-than
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is greater than the other, false otherwise
      #
      # @example
      #   1.0 > 3 #=> false
      #   1.0 > 1.0 #=> false
      #   1.0 > 0 #=> true
      #   100 > 100.0 #=> false
      #   1000 > 100 #=> true
      def >(other)
        Values::BooleanVal.new(@value > other.value)
      end

      # Greater-than-or-equal-to
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is greater than or equal to the other, false otherwise
      #
      # @example
      #   1.0 >= 3 #=> false
      #   1.0 >= 1.0 #=> false
      #   1.0 >= 0 #=> true
      #   100 >= 100.0 #=> true
      #   1000 >= 100 #=> true
      def >=(other)
        Values::BooleanVal.new(@value >= other.value)
      end

      # Less-than-or-equal-to
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is less than or equal to the other, false otherwise
      #
      # @example
      #   1.0 <= 3 #=> true
      #   1.0 <= 1.0 #=> true
      #   1.0 <= 0 #=> false
      #   100 <= 100.0 #=> true
      #   1000 <= 100 #=> false
      def <=(other)
        Values::BooleanVal.new(@value <= other.value)
      end

      # Check if the current values is not-equal-to another value
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is not equal to the other, false otherwise
      #
      # @example
      #   1.0 != 1 #=> false
      #   1.1 != 1 #=> true
      #   20 != 12.12 #=> true
      #   12.12 != 12.12 #=> false
      def !=(other)
        Values::BooleanVal.new(@value != other.value)
      end

      # Checks if the current values is equal-to another value
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is equal to the other, false otherwise
      #
      # @example
      #   1.0 == 1 #=> true
      #   1.1 == 1 #=> false
      #   20 == 12.12 #=> false
      #   12.12 == 12.12 #=> true
      def ==(other)
        Values::BooleanVal.new(@value == other.value)
      end

      #
      # Converts this NumberVal to an IntegerVal.
      # Always rounds down to the nearest integer
      # 1.9 would then be rounded to 1 and not 2
      #
      # @return [NumberVal] a new NumberVal with the same value, but with the type :int
      #
      # @example
      #   1.34.to_int() #=> 1
      #   1.9.to_int() #=> 1
      #   21.384763.to_int() #=> 21
      def to_int()
        Values::NumberVal.new(@value.to_i, :int)
      end

      #
      # Converts this NumberVal to a FloatVal.
      #
      # @return [NumberVal] a new NumberVal with the same value, but with the type :float
      #
      # @example
      #   3.to_float() #=> 3.0
      #   300.to_float() #=> 300.0
      def to_float()
        Values::NumberVal.new(@value.to_f, :float)
      end
    end
  end
end
