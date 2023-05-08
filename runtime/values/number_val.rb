module Runtime
  module Values
    #
    # The object for representing a numeric value
    #
    class NumberVal < RunTimeVal
      # Unary minus
      #
      # @return [NumberVal] The result of negating the number value
      #
      def -@
        Values::NumberVal.new(-@value, type)
      end

      # Unary plus
      #
      # @return [NumberVal] The result of returning the number value as positive
      #
      def +@
        Values::NumberVal.new(+@value, type)
      end

      # Addition
      #
      # @param [NumberVal] other The other number value to add to this value
      # @return [NumberVal] The result of adding the two number values
      #
      def +(other)
        Values::NumberVal.new(@value + other.value, type)
      end

      # Subtraction
      #
      # @param [NumberVal] other The other number value to subtract from this value
      # @return [NumberVal] The result of subtracting the two number values
      #
      def -(other)
        Values::NumberVal.new(@value - other.value, type)
      end

      # Multiplication
      #
      # @param [NumberVal] other The other number value to multiply with this value
      # @return [NumberVal] The result of multiplying the two number values
      #
      def *(other)
        Values::NumberVal.new(@value * other.value, type)
      end

      # Division
      #
      # @param [NumberVal] other The other number value to divide this value by
      # @return [NumberVal] The result of dividing this number value by the other
      #
      def /(other)
        Values::NumberVal.new(@value / other.value, type)
      end

      # Modulo
      #
      # @param [NumberVal] other The other number value to modulo this value by
      # @return [NumberVal] The result of moduloing this number value by the other
      #
      def %(other)
        Values::NumberVal.new(@value % other.value, type)
      end

      # Less-than
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is less than the other, false otherwise
      #
      def <(other)
        Values::BooleanVal.new(@value < other.value)
      end

      # Greater-than
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is greater than the other, false otherwise
      #
      def >(other)
        Values::BooleanVal.new(@value > other.value)
      end

      # Greater-than-or-equal-to
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is greater than or equal to the other, false otherwise
      #
      def >=(other)
        Values::BooleanVal.new(@value >= other.value)
      end

      # Less-than-or-equal-to
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is less than or equal to the other, false otherwise
      #
      def <=(other)
        Values::BooleanVal.new(@value <= other.value)
      end

      # Not-equal-to
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is not equal to the other, false otherwise
      #
      def !=(other)
        Values::BooleanVal.new(@value != other.value)
      end

      # Equal-to
      #
      # @param [NumberVal] other The other number value to compare to this value
      # @return [BooleanVal] True if this number value is equal to the other, false otherwise
      #
      def ==(other)
        Values::BooleanVal.new(@value == other.value)
      end

      #
      # Converts this NumberVal to an IntegerVal.
      #
      # @return [NumberVal] a new NumberVal with the same value, but with the type :int
      #
      def to_int()
        Values::NumberVal.new(@value.to_i, :int)
      end

      #
      # Converts this NumberVal to a FloatVal.
      #
      # @return [NumberVal] a new NumberVal with the same value, but with the type :float
      #
      def to_float()
        Values::NumberVal.new(@value.to_f, :float)
      end
    end
  end
end