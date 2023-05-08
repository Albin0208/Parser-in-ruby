#
# The module for all the runtime related classes and functions
#
module Runtime
	#
	# The module which contains all the runtime values.
	# These are the values that the user interacts with such as ints, floats, bools and so on
	#
	module Values
		#
		# The superclass for all the runtime values
		# @abstract
		#
		class RunTimeVal
			attr_accessor :value#, :type

			#
			# Initializes a new runtime value.
			#
			# @param [Object] value The value of the runtime value.
			# @param [Symbol] type The type of the runtime value.
			#
			def initialize(value, type)
				@value = value
				@type = type
			end

			#
      # The logical not (!) operator.
      #
			def !
				raise TypeError, "unsupported operand types for !: #{@type}"
			end

			#
      # The unary minus (-) operator.
      #
			def -@
				raise TypeError, "unsupported operand types for -: #{@type}"
			end

			#
      # The unary plus (+) operator.
      #
			def +@
				raise TypeError, "unsupported operand types for +: #{@type}"
			end
			
			#
      # The addition (+) operator.
      #
      # @param [RunTimeVal] other The runtime value to add to this one.
      #
			def +(other)
				raise TypeError, "unsupported operand types for +: #{@type} and #{other.type}"
			end

			#
      # The subtraction (-) operator.
      #
      # @param [RunTimeVal] other The runtime value to subtract from this one.
      #
			def -(other)
				raise TypeError, "unsupported operand types for -: #{@type} and #{other.type}"
			end

			#
      # The multiplication (*) operator.
      #
      # @param [RunTimeVal] other The runtime value to multiply this one by.
      #
			def *(other)
				raise TypeError, "unsupported operand types for *: #{@type} and #{other.type}"
			end

			#
      # The division (/) operator.
      #
      # @param [RunTimeVal] other The runtime value to divide this one by.
      #
			def /(other)
				raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
			end

			#
      # The modulo (%) operator.
      #
      # @param [RunTimeVal] other The runtime value to get the modulo of this one with.
      #
			def %(other)
				raise TypeError, "unsupported operand types for %: #{@type} and #{other.type}"
			end

			#
      # The less than (<) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
			def <(other)
				raise TypeError, "unsupported operand types for <: #{@type} and #{other.type}"
			end

			#
      # The greater than (>) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
			def >(other)
				raise TypeError, "unsupported operand types for >: #{@type} and #{other.type}"
			end

 			#
      # The greater or equal to (>=) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
			def >=(other)
				raise TypeError, "unsupported operand types for >=: #{@type} and #{other.type}"
			end

			#
      # The less than or equal to (<=) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
			def <=(other)
				raise TypeError, "unsupported operand types for <=: #{@type} and #{other.type}"
			end

			#
      # The not equal to (!=) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
			def !=(other)
				Values::BooleanVal.new(@value == other.value && @type == other.type)
			end

			#
      # The equal to (==) operator.
      #
      # @param [RunTimeVal] other The runtime value to compare this one to.
      #
			def ==(other)
				Values::BooleanVal.new(@value == other.value && @type == other.type)
			end

			#
			# Creates a copy of the current object
			#
			# @return [RunTimeVal] The copy of the object
			#
			def copy()
				tmp = self.clone
				tmp.value = @value.clone
				return tmp
			end

			#
			# Returns a string representation of the object
			#
			# @return [String] The string representation of the object
			#
			def to_s
				@value.to_s
			end

			#
			# Get the type of the object
			#
			# @return [Symbol] The type of the object
			#
			def type
				return @type
			end
		end
	end
end