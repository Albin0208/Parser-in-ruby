require_relative 'expr'

# This class represents the ast node for a booleanliteral
class BooleanLiteral < Expr
  attr_reader :value

  #
  # Creates a boolean node
  #
  # @param [Boolean] value The value of the boolean, true or false
  #
  def initialize(value)
    super(NODE_TYPES[:Boolean])
    @value = value
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