require_relative 'runtime_val'

# Represents a Array value in the language
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
	def ==(other)
		return BooleanVal.new(false) if @type != other.type
		return BooleanVal.new(false) if @value.length != other.value.length
		has_mismatch = false

		@value.each_with_index() {|val, index| has_mismatch ||= val.value != other.value[index].value}

		return BooleanVal.new(!has_mismatch)
	end

	# Checks whether this ArrayVal instance is not equal to another RunTimeVal instance.
	# @param [RunTimeVal] other The other RunTimeVal instance to compare.
	# @return [BooleanVal] True if the two instances are not equal, False otherwise.
	def !=(other)
		return BooleanVal.new(!(self == other).value)
	end

	# Appends an element to the end of the array.
	#
	# @param [RunTimeVal] append_value The value to be appended to the array.
	# @return [ArrayVal] The modified array with the appended element.
	def append(append_value)
		@value << append_value
		return self
	end

	# Removes and returns the last element of the array.
	#
	# @return [RunTimeVal] The removed element.
	def pop
		return @value.pop()
	end

	# Removes the element at the specified index.
	# @param [NumberVal] index The index of the element to be removed.
	# @return [RunTimeVal] The removed element.
	def remove_at(index)
		raise "Error: Can't remove element at index of non-int type" unless index.is_a?(NumberVal) && index.type == :int
		return @value.delete_at(index.value)
	end

	# Returns the length of the array.
	# @return [NumberVal] The length of the array.
	def length
		return NumberVal.new(@value.length(), :int)
	end

	# Returns a string representation of the array.
	# @return [String] The string representation of the array.
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