require_relative 'runtime_val'

class HashVal < RunTimeVal
    attr_reader :key_type, :value_type
  
    #
    # Create a Hash Value
    #
    # @param [Hash] value A Hash
    #
    def initialize(value, key_type, value_type, type)
      super(value, type)
      @key_type = key_type
      @value_type = value_type
    end
  
    def ==(other)
      return BooleanVal.new(false) if @type != other.type
      return BooleanVal.new(false) if @value.length != other.value.length
      return BooleanVal.new(false) if @value.keys != other.value.keys
      has_mismatch = false
  
      @value.each() {|key, val| has_mismatch ||= val.value != other.value[key].value}
  
      return BooleanVal.new(!has_mismatch)
    end
  
    def !=(other)
      return BooleanVal.new(!(self == other).value)
    end
  
    def keys
      # TODO Change to return custom array with keys
      return @value.keys
    end
  
    def length
      return NumberVal.new(@value.length(), :int)
    end
  end