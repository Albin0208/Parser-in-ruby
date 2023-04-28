require_relative 'expr'

# This class represents the ast node for a stringliteral
class StringLiteral < Expr
  attr_reader :value

  #
  # Creates a string node
  #
  # @param [String] value The value of the string node
  #
  def initialize(value)
    super(NODE_TYPES[:String])
    @value = value
  end

  def to_s
    "\"#{@value}\""
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