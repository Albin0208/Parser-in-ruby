module Runtime
  module Values
    #
    # The object for representing a string
    #
    # @example
    #   string s = "hej"
    #   string s2 = 'hej'
    #   string s3 = "hello mate, how it go?"
    #   s  #=> "hej"
    #   s2 #=> "hej"
    #   s3 #=> "hello mate, how it go?"
    class StringVal < RunTimeVal
      def initialize(value)
        super(value, :string)
      end

      #
      # The addition (+) operator.
      #
      # @param [RunTimeVal] other The runtime value to add to this one.
      #
      # @example
      #   "hello" + "world" #=> "helloworld"
      #   'hello' + ' ' + "world" #=> "hello world"
      def +(other)
        Values::StringVal.new(@value + other.value)
      end

      #
      # The multiplication (*) operator.
      #
      # @param [RunTimeVal] other The runtime value to multiply this one by.
      #
      # @example
      #   "hello" * 3 #=> "hellohellohello"
      def *(other)
        raise "Error: Can't multiply with non-integer value. Expected int but got #{other.type}" unless other.is_a?(NumberVal) && other.type == :int

        Values::StringVal.new(@value * other.value)
      end

      #
      # The not equal to (!=) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
      # @example
      #   "hello" != "world" #=> true
      #   "hello" != "hello" #=> false
      #   "hello" != 'hello' #=> false
      #   "hello" != 'world' #=> true
      def !=(other)
        Values::BooleanVal.new(@value != other.value)
      end

      #
      # The equal to (==) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
      # @example
      #   "hello" == "world" #=> false
      #   "hello" == "hello" #=> true
      #   "hello" == 'hello' #=> true
      #   "hello" == 'world' #=> false
      def ==(other)
        Values::BooleanVal.new(@value == other.value)
      end

      #
      # Return the length of the current string
      #
      # @return [NumberVal] The length of the string
      #
      # @example
      #   "hello".length() #=> 5
      #   'world'.length() #=> 5
      #   string a = "Hello world"
      #   a.length()       #=> 11
      def length
        Values::NumberVal.new(@value.length, :int)
      end

      #
      # Converts the string to a array where each char is an entry in the array
      #
      # @return [<Type>] <description>
      #
      # @example
      #   "hej".to_array() #=> ['h', 'e', 'j']
      #   "hello world".to_array() #=> ['h', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd']
      def to_array
        arr = @value.chars.map() { |c| Values::StringVal.new(c)}
        Values::ArrayVal.new(arr, :string)
      end

      #
      # Converts this NumberVal to an IntegerVal.
      # Always rounds down to the nearest integer
      # 1.9 would then be rounded to 1 and not 2
      #
      # @return [NumberVal] a new NumberVal with the same value, but with the type :int
      #
      # @example
      #   '1.34'.to_int() #=> 1
      #   '1.9'.to_int() #=> 1
      #   '21.384763'.to_int() #=> 21
      #
      # @example Example of invalid conversion
      #   "hej".to_int() #=> Conversion error
      def to_int()
        converted_val = @value.to_i
        raise "Error: Can't convert string '#{@value}' to a int" unless converted_val.to_s == @value
        Values::NumberVal.new(converted_val, :int)
      end

      #
      # Converts this NumberVal to a FloatVal.
      #
      # @return [NumberVal] a new NumberVal with the same value, but with the type :float
      #
      # @example
      #   "3".to_float() #=> 3.0
      #   "300".to_float() #=> 300.0
      #
      # @example Example of invalid conversion
      #   "hej".to_int() #=> Conversion error
      def to_float()
        converted_val = @value.to_f
        raise "Error: Can't convert string '#{@value}' to a float" unless converted_val.to_s == @value
        Values::NumberVal.new(converted_val, :float)
      end
    end
  end
end
