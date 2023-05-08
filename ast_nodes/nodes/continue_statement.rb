require_relative 'stmt'

module Nodes
  #
  # A representation of a continue
  #
  class ContinueStmt < Stmt
    #
    # Creates a new Continue node
    #
    # @param [Integer] line At what line the continue lies
    #
    def initialize(line)
      super(NODE_TYPES[:ContinueStmt], line)
    end

    #
    # Returns a string representation of the continue
    #
    # @return [String]
    #
    def to_s
      "Continue Stmt"
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