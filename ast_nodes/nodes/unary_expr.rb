require_relative 'expr'

module Nodes
  # This class represents the ast node for a unary expression
  class UnaryExpr < Expr
    attr_reader :left, :op

    #
    # Creates a unary expression
    #
    # @param [Expr] left The expression
    # @param [Symbol] op The operator for the expression
    # @param [Integer] line At what line the node is declared at
    #
    def initialize(left, op, line)
      super(NODE_TYPES[:UnaryExpr], line)
      @left = left
      @op = op
    end

    #
    # Returns a string representation of the node
    #
    # @return [String] A string representation of the node
    #
    def to_s
      "(#{@op}#{@left})"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}: #{@op}"
      @left.display_info(indent + 2)
    end
  end
end