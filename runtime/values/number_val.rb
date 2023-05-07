require_relative 'runtime_val'

module Runtime
  module Values
    class NumberVal < RunTimeVal
      def -@
        Values::NumberVal.new(-@value, type)
      end

      def +@
        Values::NumberVal.new(+@value, type)
      end

      def +(other)
        Values::NumberVal.new(@value + other.value, type)
      end

      def -(other)
        Values::NumberVal.new(@value - other.value, type)
      end

      def *(other)
        Values::NumberVal.new(@value * other.value, type)
      end

      def /(other)
        Values::NumberVal.new(@value / other.value, type)
      end

      def %(other)
        Values::NumberVal.new(@value % other.value, type)
      end

      def <(other)
        Values::BooleanVal.new(@value < other.value)
      end

      def >(other)
        Values::BooleanVal.new(@value > other.value)
      end

      def >=(other)
        Values::BooleanVal.new(@value >= other.value)
      end

      def <=(other)
        Values::BooleanVal.new(@value <= other.value)
      end

      def !=(other)
        Values::BooleanVal.new(@value != other.value)
      end

      def ==(other)
        Values::BooleanVal.new(@value == other.value)
      end

      def to_int()
        Values::NumberVal.new(@value.to_i, :int)
      end

      def to_float()
        Values::NumberVal.new(@value.to_f, :float)
      end
    end
  end
end