require_relative 'stmt'

module Nodes
  # Represents an assignment statement, where a value is assigned to a variable.
  class AssignmentStmt < Stmt
    attr_reader :value, :assigne

    # Creates a new AssignmentStmt instance.
    #
    # @param [Expr] value The expression whose result will be assigned to the variable.
    # @param [Identifier] assigne The identifier of the variable to which the value will be assigned.
    # @param [Integer] line The line number of the assignment statement in the source code.
    def initialize(value, assigne, line)
      super(NODE_TYPES[:AssignmentExpr], line)
      @value = value
      @assigne = assigne
    end

    # Returns a string representation of the AssignmentStmt instance.
    #
    # @return [String] A string representation of the AssignmentStmt instance.
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
end