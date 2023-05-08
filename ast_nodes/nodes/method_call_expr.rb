require_relative 'expr'

module Nodes
  class MethodCallExpr < Expr
    attr_reader :expr, :method_name, :params

    #
    # Creates the callexpr node
    #
    # @param [Expr] expr The expression the method should be called on
    # @param [String] method_name The name of the method to call
    # @param [Array] params A list of params that should be sent to the function later
    # @param [Integer] line At what line the expr is declared at
    #
    def initialize(expr, method_name, params, line)
      super(NODE_TYPES[:MethodCallExpr], line)
      @expr = expr
      @method_name = method_name
      @params = params
    end

    #
    # Returns a string representation of the Method call
    #
    # @return [String]
    #
    def to_s
      "Method name: #{@method_name}, Params: #{@params}"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
      puts "#{' ' * (indent + 2)} Expr: #{expr.display_info(indent + 2)}"
      puts "#{' ' * (indent + 2)} Method name: #{method_name}"
      puts "#{' ' * indent} Params:"
      @params.each { |param| param.display_info(indent + 2) unless @params.empty? }
    end
  end
end