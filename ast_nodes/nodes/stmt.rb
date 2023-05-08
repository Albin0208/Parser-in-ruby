module Nodes
  #
  # The class representing the parent for all statments
  # @abstract
  #
  class Stmt
    attr_reader :type, :line, :value

    #
    # Creates a new stmt node
    #
    # @param [Symbol] type What type of node it is
    # @param [Integer] line At what line the node is at
    #
    def initialize(type, line)
      @type = type
      @line = line
    end

    #
    # Creates a string representation of the node
    #
    # @return [String]
    #
    def to_s
      raise NotImplementedError, "to_s method is not implemented for #{self.class}"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      raise NotImplementedError, "display_info method is not implemented for #{self.class}"
    end
  end
end