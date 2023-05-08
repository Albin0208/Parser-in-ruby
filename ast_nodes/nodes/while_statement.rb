require_relative 'stmt'

module Nodes
  #
  # The node for a while statment
  #
  class WhileStmt < Stmt
    attr_reader :body, :conditions

    #
    # Creates an While statment node
    #
    # @param [Array] body A list of all the nodes inside the while loop
    # @param [Expr] conditions The conditions of the loop
    # @param [Integer] line At what line the while loop starts
    #
    def initialize(body, conditions, line)
      super(NODE_TYPES[:WHILE_LOOP], line)
      @body = body # A list of all statements
      @conditions = conditions
    end

    #
    # Returns a string representation of the node
    #
    # @return [String] A string representation of the node
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
      @conditions.display_info(indent + 2)
      puts "#{' ' * indent} Body:"
      @body.each { |stmt| stmt.display_info(indent + 2) }
    end
  end
end