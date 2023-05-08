require_relative 'expr'

module Nodes
  #
  # The node representing a propertycall expression
  #
  class PropertyCallExpr < Expr
    attr_reader :expr, :property_name

    #
    # Creates the propertyexpr node
    #
    # @param [Expr] expr The expression the method should be called on
    # @param [String] property_name The name of the property to call
    # @param [Integer] line At what line the property is called at
    #
    def initialize(expr, property_name, line)
      super(NODE_TYPES[:PropertyCallExpr], line)
      @expr = expr
      @property_name = property_name
    end

    #
    # Returns a string representation of the PropertyCall
    #
    # @return [String] A string representaion of the node
    #
    def to_s
      "Property name: #{@property_name}"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
      puts "#{' ' * (indent + 2)} Expr: #{expr.display_info(indent + 2)}"
      puts "#{' ' * (indent + 2)} Property name: #{property_name}"
    end
  end
end