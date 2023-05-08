require_relative 'stmt'

module Nodes
  # This class represents the ast node for the program
  class Program < Stmt
    attr_reader :body

    #
    # Creates a new program node
    #
    # @param [Array] body A list with all the statments of the program
    # @param [Integer] line The line at which the program starts
    #
    def initialize(body, line)
      super(NODE_TYPES[:Program], line)
      @body = body # A list of all statements
    end

    #
    # Return a string representation of the program
    #
    # @return [String] A string representation of the program
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
      @body.each { |stmt| stmt.display_info(indent + 2) }
    end
  end
end