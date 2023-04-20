class RunTimeVal
  attr_reader :value#, :type

  def initialize(value, type)
    @value = value
    @type = type
  end

  def +(other)
    raise TypeError, "unsupported operand types for +: #{@type} and #{other.type}"
  end

  def -(other)
    raise TypeError, "unsupported operand types for -: #{@type} and #{other.type}"
  end

  def !
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

# class IntegerVal < NumberVal
#   def initialize(value)
#     super(value)
#     @type = :int
#   end

#   def +(other)
#     IntegerVal.new(@value + other.value)
#   end

#   def -(other)
#     IntegerVal.new(@value - other.value)
#   end

#   def *(other)
#     IntegerVal.new(@value * other.value)
#   end

#   def /(other)
#     IntegerVal.new(@value / other.value)
#   end

#   def %(other)
#     IntegerVal.new(@value % other.value)
#   end
# end
# class FloatVal < NumberVal
#   def initialize(value)
#     super(value)
#     @type = :float
#   end

#   def +(other)
#     FloatVal.new(@value + other.value)
#   end

#   def -(other)
#     FloatVal.new(@value - other.value)
#   end

#   def *(other)
#     FloatVal.new(@value * other.value)
#   end

#   def /(other)
#     FloatVal.new(@value / other.value)
#   end

#   def %(other)
#     FloatVal.new(@value % other.value)
#   end
# end

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
    super(value, :boolean)
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
