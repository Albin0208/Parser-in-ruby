require_relative 'expr'

module Nodes
  # This class represents the ast node for a null literal
  class NullLiteral < Expr
    attr_reader :value

    #
    # Creates a null node
    #
    def initialize(line)
      super(NODE_TYPES[:Null], line)
      @value = 'null'
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
end