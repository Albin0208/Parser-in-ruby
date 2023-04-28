require_relative 'expr'

# This class represents the ast node for a numericliteral
class NumericLiteral < Expr
  attr_accessor :value, :numeric_type

  #
  # Creates a numeric node
  #
  # @param [int, float] value The number the numeric node, can be an int or float
  #
  def initialize(value, type)
    super(NODE_TYPES[:NumericLiteral])
    @value = value
    @numeric_type = type
  end

  def to_s
    @value.to_s
  end

  #
  # Display the information about the node as a tree structure
  #
  # @param [Integer] indent How much the next row should be indented
  #
  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@value}"
  end
end