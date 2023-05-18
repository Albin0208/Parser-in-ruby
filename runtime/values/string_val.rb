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
        raise "Error: Can't multiply withn non-integer value. Expected int but got #{other.type}" unless other.is_a?(NumberVal) && other.type == :int

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
    end
  end
end
