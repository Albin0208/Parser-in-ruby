require_relative 'expr'

module Nodes
  # A node representing an array literal expression.
  class ArrayLiteral < Expr
    attr_reader :value, :value_type

    # Creates a new ArrayLiteral node.
    #
    # @param [Array] value The elements of the array literal.
    # @param [Symbol] value_type The data type of the elements of the array.
    # @param [Integer] line The line number of the array literal in the source code.
    def initialize(value, value_type, line)
      super(NODE_TYPES[:ArrayLiteral], line)
      @value = value
      @value_type = value_type
    end

    # Returns a string representation of the ArrayLiteral node.
    #
    # @return [String] A string representation of the ArrayLiteral node.
    def to_s
      "ArrayLiteral: #{@value}"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}: #{} #{} #{@value_type}"
      @value.each() { |val| val.display_info(indent + 2) }
    end
  end
end