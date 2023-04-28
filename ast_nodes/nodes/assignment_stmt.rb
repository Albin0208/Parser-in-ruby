require_relative 'stmt'

class AssignmentStmt < Stmt
  attr_reader :value, :assigne

  #
  # Creates an assignment expression
  #
  # @param [Expr] value The expr we want the result of to assign to the variable
  # @param [Identifier] assigne To what identifier we want to do the assignment to
  #
  def initialize(value, assigne)
    super(NODE_TYPES[:AssignmentExpr])
    @value = value
    @assigne = assigne
  end

  def to_s
    "Value: #{@value}, Assigne: #{@assigne}"
  end

  #
  # Display the information about the node as a tree structure
  #
  # @param [Integer] indent How much the next row should be indented
  #
  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@assigne}"
    @value.display_info(indent + 2)
  end
end