require_relative 'expr'

module Nodes
  # Represents an instance of a class in the AST, with its corresponding parameters.
  class ClassInstance < Expr
    attr_reader :value, :params
    
    #
    # Creates a new ClassInstance node with the given value and parameters.
    #
    # @param value [Boolean] The value of the boolean, true or false.
    # @param params [Array] An array of parameters sent to the class constructor.
    # @param line [Integer] The line number where the node appears in the source code.
    #
    def initialize(value, params, line)
      super(NODE_TYPES[:ClassInstance], line)
      @value = value
      @params = params
    end

    # Returns the string representation of the class instance.
    #
    # @return [String] The class instance as a string
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