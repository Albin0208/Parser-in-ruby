module Runtime
  module Values
    # Represents a Array value in the language
    # @example Creating an empty array
    #   # Has to be assigned before use
    #   int[] a                 #=> null
    #   string[] a = string[]{} #=> []
    # @example Creating an array with values
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
      # @return [RunTimeVal, NullVal] The removed element or null if no item was removed
      # @example
      #   int[] a = int[]{1, 2, 3}
      #   a.remove_at(1) #=> 2
      #   a       #=> [1, 3]
      #   a.remove_at(10) #=> null
      #   a       #=> [1, 3]
      def remove_at(index)
        raise "Error: Can't remove element at index of non-int type" unless index.is_a?(NumberVal) && index.type == :int
        val = @value.delete_at(index.value)
        return val.nil? ? Values::NullVal.new() : val
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
          string << "#{val.to_s.value}, "
        }
        string.chomp!(', ')
        string << ']'
        return StringVal.new(string)
      end

      # Sorts the values in the array using the provided function as the comparison conditon.
      #
      # @param [Nodes::FuncDeclaration] function The user-defined function used as the comparison conditon. This function is required to take two parameters and return a boolean See example below.
      # @return [ArrayVal] The sorted array.
      #
      # @example Example of function to sort ints in descending order
      #   func bool compare_ints(int a, int b) {
      #     return a > b
      #   }
      #
      # @example Sorting the array with the previous functions as the comparetor
      #   int[] a = int[]{4, 2, 5, 1, 6, 2}
      #
      #   # Use the function defined in the previous example
      #   a.sort(compare_ints) #=> [6, 5, 4, 2, 2, 1]
      # @note The `interpreter`, `env`, and `call_node` parameters are automatically passed
      #   and not provided by the user. They represent the interpreter instance, environment,
      #   and the call node representing the function call, respectively.
      # @note If the wrong number of parameters are passed to the sort function it only counts 
      #   the function as only parameter so a error message could say that it got 2 parameters
      #   but expected 1.
      def sort(interpreter, env, call_node, function)
        self.value = sort_helper(interpreter, env, call_node, self.value, function)
        return self
      end

      private

      #
      # Implements the mergesort algorithm to sort the values in the array using the provided comparison function.
      #
      # @param [Interpreter] interpreter The Interpreter object
      # @param [Environment] env The current environment
      # @param [Nodes::MethodCallExpr] call_node The call node for the function
      # @param [Array] array The array of all the values to be sorted
      # @param [Nodes::FuncDeclaration] cmp_func The user-defined function used for the comparison
      #
      # @return [Array] The sorted array
      #
      def sort_helper(interpreter, env, call_node, array, cmp_func)
        return array if array.length() <= 1 # Only one value, no need to sort
      
        mid = array.length() / 2 # Get the middle of the array
        left = sort_helper(interpreter, env, call_node, array[0...mid], cmp_func)
        right = sort_helper(interpreter, env, call_node, array[mid..-1], cmp_func)
      
        sorted_array = []
        
        while !left.empty? && !right.empty?
          comparison_node = Nodes::CallExpr.new(cmp_func.identifier, [left.first, right.first], call_node.line)
          condition = interpreter.call_function(cmp_func, comparison_node, env)

          sorted_array << (condition.value ? left.shift : right.shift)
        end
        return sorted_array.concat(left).concat(right)
      end
    end
  end
end