require_relative 'expr'

module Nodes
  # This class represents the ast node for a booleanliteral
  class BooleanLiteral < Expr
    attr_reader :value

    #
    # Creates a boolean node
    #
    # @param [Boolean] value The value of the boolean, true or false
    #
    def initialize(value, line)
      super(NODE_TYPES[:Boolean], line)
      @value = value
    end

    def to_s
      @value.to_s
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}: #{@value}"
    end
  end
end