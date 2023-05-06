require_relative 'stmt'

class ForEachStmt < Stmt
  attr_reader :body, :identifier, :container
  #
  # Creates an While statment node
  #
  # @param [Array] body A list of all the nodes inside the while loop
  # @param [Expr] condition The condition of the loop
  # @param [VarDeclaration] var_dec Variable declaration to be used in loop
  # @param [Expr] expr What to do after each iteration
  #
  def initialize(body, identifier, container, line)
    super(NODE_TYPES[:FOR_EACH_LOOP], line)
    @body = body # A list of all statements
    @identifier = identifier
    @container = container
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
    puts "#{' ' * indent} Identifier: #{@identifier}"
    puts "#{' ' * indent} Container: "
    @container.display_info(indent + 2)
    puts "#{' ' * indent} Body:"
    @body.each { |stmt| stmt.display_info(indent + 2) }
  end
end