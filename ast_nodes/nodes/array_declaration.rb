require_relative 'stmt'

module Nodes
    #
    # A node representing an array declaration statement.
    #
  class ArrayDeclaration < Stmt
    attr_reader :value, :identifier, :constant, :value_type

    #
    # Creates a new instance of the ArrayDeclaration class.
    #
    # @param constant [Boolean] whether this array is declared as a constant.
    # @param identifier [Identifier] the identifier for this array.
    # @param value_type [Symbol] the type of the values in this array.
    # @param line [Integer] the line number where this node appears in the source code.
    # @param value [Expr, nil] the value assigned to this array, if any.
    def initialize(constant, identifier, value_type, line, value = nil)
      super(NODE_TYPES[:ArrayDeclaration], line)
      @constant = constant
      @identifier = identifier
      @value_type = value_type
      @value = value
    end

    #
    # Returns a string representation of this ArrayDeclaration node.
    #
    # @return [String] a string representation of this ArrayDeclaration node.
    #
    def to_s
      "Const: #{@constant}, Ident: #{@identifier}, Value: #{@value}, Type: #{@value_type}"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}: #{@constant} #{@identifier} #{@value_type}"
      @value&.display_info(indent + 2)
    end
  end
end