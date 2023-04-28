require_relative 'stmt'

# This class represents the ast node for a if statement
class IfStatement < Stmt
  attr_reader :body, :conditions, :else_body, :elsif_stmts

  #
  # Creates an if statment node
  #
  # @param [Array] body A list of all the nodes inside the if body
  # @param [Expr] conditions The conditions of the if
  # @param [Array] else_body A list of all the nodes inside the else body
  # @param [Array] elsif_stmts A list of all the elsif statements
  #
  def initialize(body, conditions, else_body, elsif_stmts)
    super(NODE_TYPES[:IF])
    @body = body # A list of all statements
    @conditions = conditions
    @else_body = else_body
    @elsif_stmts = elsif_stmts
  end

  def to_s
    @body.map(&:to_s)
  end

  #
  # Display the information about the node as a tree structure
  #
  # @param [Integer] indent How much the next row should be indented
  #
  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * indent} Conditions:"
    @conditions.display_info(indent + 2)
    puts "#{' ' * indent} Body:"
    @body.each { |stmt| stmt.display_info(indent + 2) }

    unless @elsif_stmts.nil?
      puts "#{' ' * indent} Elsifs:"
      @elsif_stmts.each { |stmt| stmt.display_info(indent + 2) }
    end

    return if @else_body.nil?

    puts "#{' ' * indent} Else body:"
    @else_body.each { |stmt| stmt.display_info(indent + 2) }
  end
end