require_relative 'expr'

module Nodes
  # This class represents the ast node for a numericliteral
  class NumericLiteral < Expr
    attr_accessor :value, :numeric_type

    #
    # Creates a numeric node
    #
    # @param [int, float] value The number the numeric node, can be an int or float
    #
    a = 2

    #
    # Creates a numeric node
    #
    # @param [Integer, float] value The number value of the node
    # @param [Symbol] type What type it is i.e int or float
    # @param [Integer] line At what line the node is declared
    #
    def initialize(value, type, line)
      super(NODE_TYPES[:NumericLiteral], line)
      @value = value
      @numeric_type = type
    end

    #
    # Returns a string representation of the node
    #
    # @return [String] A string representaion of the node
    #
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
end