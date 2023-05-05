require_relative 'runtime_val'

class ArrayVal < RunTimeVal
	attr_reader :value_type

	#
	# Create a Hash Value
	#
	# @param [Hash] value A Hash
	#
	def initialize(value, value_type)
		super(value, value_type)
		@value_type = value_type
	end

	# def ==(other)
	# 	return BooleanVal.new(false) if @type != other.type
	# 	return BooleanVal.new(false) if @value.length != other.value.length
	# 	return BooleanVal.new(false) if @value.keys != other.value.keys
	# 	has_mismatch = false

	# 	@value.each() {|key, val| has_mismatch ||= val.value != other.value[key].value}

	# 	return BooleanVal.new(!has_mismatch)
	# end

	# def !=(other)
	# 	return BooleanVal.new(!(self == other).value)
	# end

	def length
		return NumberVal.new(@value.length(), :int)
	end

	def to_s
		# string = '{'
		# @value.each() { |key, val| 
		# 	string << "#{key} = #{val}, "
		# }
		# string.chomp!(', ')
		# string << '}'
		# return string
	end
end