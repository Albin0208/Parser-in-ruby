require_relative 'stmt'

module Nodes
  class ForStmt < Stmt
    attr_reader :body, :condition, :var_dec, :expr
    #
    # Creates an While statment node
    #
    # @param [Array] body A list of all the nodes inside the while loop
    # @param [Expr] condition The condition of the loop
    # @param [VarDeclaration] var_dec Variable declaration to be used in loop
    # @param [Expr] expr What to do after each iteration
    #
    def initialize(body, condition, var_dec, expr, line)
      super(NODE_TYPES[:FOR_LOOP], line)
      @body = body # A list of all statements
      @condition = condition
      @var_dec = var_dec
      @expr = expr
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
      @condition.display_info(indent + 2)
      puts "#{' ' * indent} Expression:"
      @expr.display_info(indent + 2)
      puts "#{' ' * indent} Body:"
      @body.each { |stmt| stmt.display_info(indent + 2) }
    end
  end
end