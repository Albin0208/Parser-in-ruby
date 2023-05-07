require_relative 'expr'

module Nodes
  class ArrayLiteral < Expr
    attr_reader :value, :value_type

    #
    # Creates an var declaration node
    #
    # @param [Boolean] constant If this var should be a constant
    # @param [Identifier] identifier The identifier for the var
    # @param [<Type>] value_type What type this var is
    # @param [Expr] value The value that should be assigned or nil if only declaring
    #
    def initialize(value, value_type, line)
      super(NODE_TYPES[:ArrayLiteral], line)
      @value = value
      @value_type = value_type
    end

    def to_s
      "Const: #{}, Ident: #{}, Value: #{@value}, Type: #{@value_type}"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}: #{} #{} #{@value_type}"
      @value.each() { |val| val.display_info(indent + 2) }
    end
  end
end