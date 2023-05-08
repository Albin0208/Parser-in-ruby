require_relative 'expr'

module Nodes
  # This class represents the ast node for a binary expression
  class BinaryExpr < Expr
    attr_reader :left, :op, :right

    #
    # Creates a binary expression node
    #
    # @param [Expr] left The left side of the expression
    # @param [Symbol] op The operator to be used for the expression
    # @param [Expr] right The right side of the expression
    #
    def initialize(left, op, right, line)
      super(NODE_TYPES[:BinaryExpr], line)
      @left = left
      @op = op
      @right = right
    end

    # Returns a string representation of the BinaryExpr.
    #
    # @return [String] A string representation of the BinaryExpr.
    def to_s
      "(#{@left} #{@op} #{@right})"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}: #{@op}"
      @left.display_info(indent + 2)
      @right.display_info(indent + 2)
    end
  end
end