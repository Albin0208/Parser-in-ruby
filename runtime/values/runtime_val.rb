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

			def initialize(value, type)
				@value = value
				@type = type
			end

			def !
				raise TypeError, "unsupported operand types for !: #{@type}"
			end

			def -@
				raise TypeError, "unsupported operand types for -: #{@type}"
			end

			def +@
				raise TypeError, "unsupported operand types for +: #{@type}"
			end
			
			def +(other)
				raise TypeError, "unsupported operand types for +: #{@type} and #{other.type}"
			end

			def -(other)
				raise TypeError, "unsupported operand types for -: #{@type} and #{other.type}"
			end

			def *(other)
				raise TypeError, "unsupported operand types for *: #{@type} and #{other.type}"
			end

			def /(other)
				raise TypeError, "unsupported operand types for /: #{@type} and #{other.type}"
			end

			def %(other)
				raise TypeError, "unsupported operand types for %: #{@type} and #{other.type}"
			end

			def <(other)
				raise TypeError, "unsupported operand types for <: #{@type} and #{other.type}"
			end

			def >(other)
				raise TypeError, "unsupported operand types for >: #{@type} and #{other.type}"
			end

			def >=(other)
				raise TypeError, "unsupported operand types for >=: #{@type} and #{other.type}"
			end

			def <=(other)
				raise TypeError, "unsupported operand types for <=: #{@type} and #{other.type}"
			end

			def !=(other)
				Values::BooleanVal.new(@value == other.value && @type == other.type)
			end

			def ==(other)
				Values::BooleanVal.new(@value == other.value && @type == other.type)
			end

			def copy()
				tmp = self.clone
				tmp.value = @value.clone
				return tmp
			end

			def to_s
				@value.to_s
			end

			def type
				return @type
			end
		end
	end
end