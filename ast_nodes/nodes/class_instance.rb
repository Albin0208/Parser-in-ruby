require_relative 'expr'

module Nodes
  class ClassInstance < Expr
    attr_reader :value, :params
    #
    # Creates a class node
    #
    # @param [Boolean] value The value of the boolean, true or false
    #
    def initialize(value, params, line)
      super(NODE_TYPES[:ClassInstance], line)
      @value = value
      @params = params
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