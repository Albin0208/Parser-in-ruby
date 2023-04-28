require_relative 'expr'

# This class represents the ast node for a identifier
class Identifier < Expr
  attr_reader :symbol

  #
  # Creates an identifier node
  #
  # @param [Symbol] symbol A symbol of the name for the identifier
  #
  def initialize(symbol)
    super(NODE_TYPES[:Identifier])
    @symbol = symbol
  end

  def to_s
    @symbol
  end

  #
  # Display the information about the node as a tree structure
  #
  # @param [Integer] indent How much the next row should be indented
  #
  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@symbol}"
  end
end