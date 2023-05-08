require_relative 'stmt'
module Nodes
  class BreakStmt < Stmt
      #
    # Creates a break statement node
    #
    # @param [Integer] line The line number of the break statement
    #
    def initialize(line)
      super(NODE_TYPES[:BreakStmt], line)
    end

    # Display the break as a string
    #
    # @return [String] The break as a string
    def to_s
      "Break Stmt"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
    end
  end
end