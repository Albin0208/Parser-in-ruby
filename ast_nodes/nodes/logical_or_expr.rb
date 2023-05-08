require_relative 'expr'

module Nodes
  # This class represents the ast node for a logical or expression
  class LogicalOrExpr < Expr
    attr_reader :left, :right, :op

    #
    # Creates a logical or node
    #
    # @param [Expr] left The left side of the or expression
    # @param [Expr] right The right side of the or expression
    # @param [Integer] line At what line the expr is declared at
    #
    def initialize(left, right, line)
      super(NODE_TYPES[:LogicalOr], line)
      @left = left
      @op = :"||"
      @right = right
    end

    #
    # Returns a string representation of the or expr
    #
    # @return [String]
    #
    def to_s
      "(#{@left} || #{@right})"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
      @left.display_info(indent + 2)
      @right.display_info(indent + 2)
    end
  end
end