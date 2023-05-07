module Nodes
  class Stmt
    attr_reader :type, :line, :value

    def initialize(type, line)
      @type = type
      @line = line
    end

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