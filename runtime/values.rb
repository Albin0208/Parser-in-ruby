class RunTimeVal
  attr_reader :value#, :type

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
    BooleanVal.new(@value == other.value && @type == other.type)
  end

  def ==(other)
    BooleanVal.new(@value == other.value && @type == other.type)
  end

  def to_s
    @value.to_s
  end

  def type
    return @type
  end
end

class NumberVal < RunTimeVal
  def initialize(value, type)
    super(value, type)
  end

  def -@
    NumberVal.new(-@value, type)
  end

  def +@
    NumberVal.new(+@value, type)
  end

  def +(other)
    NumberVal.new(@value + other.value, type)
  end

  def -(other)
    NumberVal.new(@value - other.value, type)
  end

  def *(other)
    NumberVal.new(@value * other.value, type)
  end

  def /(other)
    NumberVal.new(@value / other.value, type)
  end

  def %(other)
    NumberVal.new(@value % other.value, type)
  end

  def <(other)
    BooleanVal.new(@value < other.value)
  end

  def >(other)
    BooleanVal.new(@value > other.value)
  end

  def >=(other)
    BooleanVal.new(@value >= other.value)
  end

  def <=(other)
    BooleanVal.new(@value <= other.value)
  end

  def !=(other)
    BooleanVal.new(@value != other.value)
  end

  def ==(other)
    BooleanVal.new(@value == other.value)
  end

  def to_int()
    return NumberVal.new(@value.to_i, :int)
  end

  def to_float()
    return NumberVal.new(@value.to_f, :float)
  end
end

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

class StringVal < RunTimeVal
  def initialize(value)
    super(value, :string)
  end

  def +(other)
    StringVal.new(@value + other.value)
  end

  def *(other)
    StringVal.new(@value * other.value)
  end

  def !=(other)
    BooleanVal.new(@value != other.value)
  end

  def ==(other)
    BooleanVal.new(@value == other.value)
  end

  def length
    return NumberVal.new(@value.length, :int)
  end
end

class BooleanVal < RunTimeVal
  def initialize(value = true)
    super(value, :bool)
  end

  def !
    BooleanVal.new(!@value)
  end

  def !=(other)
    BooleanVal.new(@value != other.value)
  end

  def ==(other)
    BooleanVal.new(@value == other.value)
  end
end

class NullVal < RunTimeVal
  def initialize
    super('null', :null)
  end
end


class ClassVal < RunTimeVal
  attr_reader :class_instance

  def initialize(value, class_instance)
    super(value, value.to_sym)
    @class_instance = class_instance
  end

  def !=(other)
    BooleanVal.new(!(other == self))
  end

  def ==(other)
    return BooleanVal.new(true) if other.object_id == self.object_id

    BooleanVal.new(false)
  end
end