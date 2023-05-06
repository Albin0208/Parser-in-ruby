require_relative 'runtime_val'

# Represents an Hash value in the language
class HashVal < RunTimeVal
	attr_reader :key_type, :value_type

  #
  # Create a new instance of HashVal.
  #
  # @param [Hash] value The value of the hash.
  # @param [Symbol] key_type The data type of the hash keys.
  # @param [Symbol] value_type The data type of the hash values.
  # @param [Symbol] type The type of the HashVal object.
  #
	def initialize(value, key_type, value_type, type)
		super(value, type)
		@key_type = key_type
		@value_type = value_type
	end

	#
  # Create a new instance of HashVal.
  #
  # @param [Hash] value The value of the hash.
  # @param [Symbol] key_type The data type of the hash keys.
  # @param [Symbol] value_type The data type of the hash values.
  # @param [Symbol] type The type of the HashVal object.
  #
	def ==(other)
		return BooleanVal.new(false) if @type != other.type
		return BooleanVal.new(false) if @value.length != other.value.length
		return BooleanVal.new(false) if @value.keys != other.value.keys
		has_mismatch = false

		@value.each() {|key, val| has_mismatch ||= val.value != other.value[key].value}

		return BooleanVal.new(!has_mismatch)
	end

	#
  # Compare two HashVal objects for inequality.
  #
  # @param [RunTimeVal] other The other value to compare.
  # @return [BooleanVal] true if the two HashVal objects are not equal, false otherwise.
  #
	def !=(other)
		return BooleanVal.new(!(self == other).value)
	end

  #
  # Get an array of all keys in the hash.
  #
  # @return [ArrayVal] An array of all keys in the hash.
  #
	def keys
		return ArrayVal.new(@value.keys, :"#{@key_type}[]")
	end

	#
  # Get the length of the hash.
  #
  # @return [NumberVal] The length of the hash.
  #
	def length
		return NumberVal.new(@value.length(), :int)
	end

	#
  # Convert the HashVal object to a string.
  #
  # @return [String] The string representation of the HashVal object.
  #
	def to_s
		string = '{'
		@value.each() { |key, val| 
			string << "#{key} = #{val}, "
		}
		string.chomp!(', ')
		string << '}'
		return string
	end
end