module Runtime
  module Values
    #
    # The object for representing a string
    #
    class StringVal < RunTimeVal
      def initialize(value)
        super(value, :string)
      end

      #
      # The addition (+) operator.
      #
      # @param [RunTimeVal] other The runtime value to add to this one.
      #
      def +(other)
        Values::StringVal.new(@value + other.value)
      end

      #
      # The multiplication (*) operator.
      #
      # @param [RunTimeVal] other The runtime value to multiply this one by.
      #
      def *(other)
        Values::StringVal.new(@value * other.value)
      end

      #
      # The not equal to (!=) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
      def !=(other)
        Values::BooleanVal.new(@value != other.value)
      end

      #
      # The equal to (==) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
      def ==(other)
        Values::BooleanVal.new(@value == other.value)
      end

      #
      # Return the length of the current string
      #
      # @return [NumberVal] The length of the string
      #
      def length
        Values::NumberVal.new(@value.length, :int)
      end
    end
  end
end
