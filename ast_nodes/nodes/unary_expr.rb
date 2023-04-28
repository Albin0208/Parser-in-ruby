require_relative 'expr'

# This class represents the ast node for a unary expression
class UnaryExpr < Expr
  attr_reader :left, :op

  #
  # Creates a unary expression
  #
  # @param [Expr] left The expression
  # @param [Symbol] op The operator for the expression
  #
  def initialize(left, op)
    super(NODE_TYPES[:UnaryExpr])
    @left = left
    @op = op
  end

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