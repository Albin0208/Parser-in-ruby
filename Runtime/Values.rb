# frozen_string_literal: true

class RunTimeVal
  attr_reader :value, :type

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
    raise TypeError, "unsupported operand types for !=: #{@type} and #{other.type}"
  end

  def ==(other)
    @value == other.value && @type == other.type
  end

  def to_s
    @value
  end
end

class NumberVal < RunTimeVal
  def initialize(value)
    super(value, :number)
  end

  def +(other)
    NumberVal.new(@value + other.value)
  end

  def -(other)
    NumberVal.new(@value - other.value)
  end

  def *(other)
    NumberVal.new(@value * other.value)
  end

  def /(other)
    NumberVal.new(@value / other.value)
  end

  def %(other)
    NumberVal.new(@value % other.value)
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
