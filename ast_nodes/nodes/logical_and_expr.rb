require_relative 'expr'

# This class represents the ast node for a logical and expression
class LogicalAndExpr < Expr
  attr_reader :left, :right, :op

  #
  # Creates a logical and node
  #
  # @param [Stmt] left The left side of the and expression
  # @param [Stmt] right The right side of the and expression
  #
  def initialize(left, right, line)
    super(NODE_TYPES[:LogicalAnd], line)
    @left = left
    @op = :"&&"
    @right = right
  end

  def to_s
    "(#{@left} && #{@right})"
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