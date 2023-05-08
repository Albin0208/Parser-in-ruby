require_relative 'expr'

module Nodes
  # This class represents the ast node for a stringliteral
  class StringLiteral < Expr
    attr_reader :value

    #
    # Creates a string node
    #
    # @param [String] value The value of the string node
    # @param [Integer] line at what the line the node is declared
    #
    def initialize(value, line)
      super(NODE_TYPES[:String], line)
      @value = value
    end

    #
    # Return a string representation of the node
    #
    # @return [String] The string representation of the node
    #
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
end