module Runtime
  module Values
    #
    # The object containing the custom class object
    #
    class ClassVal < RunTimeVal
      attr_reader :class_instance

      # Initializes a new instance of ClassVal.
      #
      # @param [String] value The value to be stored.
      # @param [ClassInstance] class_instance The class instance represented by this value.
      def initialize(value, class_instance)
        super(value, value.to_sym)
        @class_instance = class_instance
      end

      # Returns a BooleanVal indicating whether the given value is not equal to this value.
      #
      # @param [RunTimeVal] other The other value to compare with.
      # @return [BooleanVal] A BooleanVal indicating whether the given value is not equal to this value.
      def !=(other)
        Values::BooleanVal.new(!(other == self))
      end

      # Returns a BooleanVal indicating whether the given value is equal to this value.
      #
      # @param [RunTimeVal] other The other value to compare with.
      # @return [BooleanVal] A BooleanVal indicating whether the given value is equal to this value.
      def ==(other)
        return Values::BooleanVal.new(true) if other.object_id.equal?(self.object_id)

        return Values::BooleanVal.new(false)
      end

      # Returns a new instance of ClassVal that is a copy of this instance.
      #
      # @return [ClassVal] A new instance of ClassVal that is a copy of this instance.
      def copy
        Values::ClassVal.new(@value, @class_instance.clone)
      end
    end
  end
end
