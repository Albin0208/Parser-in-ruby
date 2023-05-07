module Runtime
  module Values
    class StringVal < RunTimeVal
      def initialize(value)
        super(value, :string)
      end

      def +(other)
        return Values::StringVal.new(@value + other.value)
      end

      def *(other)
        return Values::StringVal.new(@value * other.value)
      end

      def !=(other)
        return Values::BooleanVal.new(@value != other.value)
      end

      def ==(other)
        return Values::BooleanVal.new(@value == other.value)
      end

      def length
        return Values::NumberVal.new(@value.length, :int)
      end
    end
  end
end