require_relative 'stmt'

module Nodes
  # This class represents the ast node for a elsif statement
  class ElsifStatement < Stmt
    attr_reader :body, :conditions

    #
    # Creates an elsif statment node
    #
    # @param [Array] body A list of all the nodes inside the if body
    # @param [Expr] conditions The conditions of the if
    #
    def initialize(body, conditions, line)
      super(NODE_TYPES[:ELSIF], line)
      @body = body # A list of all statements
      @conditions = conditions
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
    end
  end
end