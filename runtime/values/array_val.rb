module Runtime
  module Values
    # Represents a Array value in the language
    # @example Creating an empty array
    #   int[] a                 #=> []
    #   string[] a = string[]{} #=> []
    # @example Creating an with values array
    #   int[] a = int[]{1, 2, 3}        #=> [1, 2, 3]
    #   string[] a = string[]{"one", "two", "three"} #=> ["one", "two", "three"]
    class ArrayVal < RunTimeVal
      attr_reader :value_type

      # Initializes a new instance of the ArrayVal class.
      #
      # @param [Array] value The array value to be stored.
      # @param [Symbol] value_type The type of elements in the array.
      def initialize(value, value_type)
        super(value, value_type)
        @value_type = value_type
      end

      # Checks whether this ArrayVal instance is equal to another RunTimeVal instance.
      # @param [RunTimeVal] other The other RunTimeVal instance to compare.
      # @return [BooleanVal] True if the two instances are equal, False otherwise.
      # @example
      #   int[]{1, 2} == int[]{1, 2, 3} #=> false
      #   int[]{1, 2, 3} == int[]{1, 2, 3} #=> true
      #   string[]{"1", "2", "3"} == int[]{1, 2, 3} #=> false
      def ==(other)
        return Values::BooleanVal.new(false) if @type != other.type
        return Values::BooleanVal.new(false) if @value.length != other.value.length

        has_mismatch = false

        @value.each_with_index() {|val, index| has_mismatch ||= val.value != other.value[index].value}

        return Values::BooleanVal.new(!has_mismatch)
      end

      # Checks whether this ArrayVal instance is not equal to another RunTimeVal instance.
      # @param [RunTimeVal] other The other RunTimeVal instance to compare.
      # @return [BooleanVal] True if the two instances are not equal, False otherwise.
      # @example
      #   int[]{1, 2} != int[]{1, 2, 3} #=> true
      #   int[]{1, 2, 3} != int[]{1, 2, 3} #=> false
      #   string[]{"1", "2", "3"} != int[]{1, 2, 3} #=> true
      def !=(other)
        Values::BooleanVal.new(!(self == other).value)
      end

      # Appends an element to the end of the array.
      #
      # @param [RunTimeVal] append_value The value to be appended to the array.
      # @return [ArrayVal] The modified array with the appended element.
      #
      # @example
      #   int[] a = int[]{1, 2, 3}
      #   a.append(45) #=> [1, 2, 3, 45]
      #
      #   a.append(45).append(37) #=> [1, 2, 3, 45, 45, 37]
      def append(append_value)
        @value << append_value
        return self
      end

      # Removes and returns the last element of the array.
      #
      # @return [RunTimeVal] The removed element.
      # @example
      #   int[] a = int[]{1, 2, 3}
      #   a.pop() #=> 3
      #   a       #=> [1, 2]
      def pop
        @value.pop()
      end

      # Removes the element at the specified index.
      #
      # @param [NumberVal] index The index of the element to be removed.
      # @return [RunTimeVal] The removed element.
      # @example
      #   int[] a = int[]{1, 2, 3}
      #   a.remove_at(1) #=> 2
      #   a       #=> [1, 3]
      def remove_at(index)
        raise "Error: Can't remove element at index of non-int type" unless index.is_a?(NumberVal) && index.type == :int

        return @value.delete_at(index.value)
      end

      # Returns the length of the array.
      #
      # @return [NumberVal] The length of the array.
      # @example
      #   int[] a = int[]{1, 2, 3}
      #   a.length() #=> 3
      def length
        Values::NumberVal.new(@value.length(), :int)
      end

      # Returns a string representation of the array.
      #
      # @return [String] The string representation of the array.
      # @example
      #   int[] a = int[]{1, 2, 3}
      #   a.to_s() #=> "[1, 2, 3]"
      def to_s
        string = '['
        @value.each() { |val| 
          string << "#{val}, "
        }
        string.chomp!(', ')
        string << ']'
        return string
      end
    end
  end
end