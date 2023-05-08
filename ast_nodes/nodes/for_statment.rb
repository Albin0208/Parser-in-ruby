require_relative 'stmt'

module Nodes
  # A node representing a for loop in the code.
  class ForStmt < Stmt
    attr_reader :body, :condition, :var_dec, :expr

    #
    # Creates a For loop
    #
    # @param [Array] body The list of all statments in the body
    # @param [Expr] condition The condition for the loop to run
    # @param [VarDeclaration] var_dec The variabel declaren at the start of the for
    # @param [Expr] expr The expr that will run after every iteration
    # @param [Integer] line At what line the for loop starts
    #
    def initialize(body, condition, var_dec, expr, line)
      super(NODE_TYPES[:FOR_LOOP], line)
      @body = body # A list of all statements
      @condition = condition
      @var_dec = var_dec
      @expr = expr
    end

    #
    # Returns a string representation fo the for loop
    #
    # @return [String]
    #
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
      @condition.display_info(indent + 2)
      puts "#{' ' * indent} Expression:"
      @expr.display_info(indent + 2)
      puts "#{' ' * indent} Body:"
      @body.each { |stmt| stmt.display_info(indent + 2) }
    end
  end
end