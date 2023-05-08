require_relative 'stmt'

module Nodes
  #
  # A node representing a functiondeclaration
  #
  class FuncDeclaration < Stmt
    attr_reader :type_specifier, :identifier, :params, :body
    attr_accessor :env

    #
    # Creates an instance of a funcdeclaration
    #
    # @param [Symbol] type_specifier What return type the function has
    # @param [Identifier] identifier The name of the function
    # @param [Array] params All the params that the function takes
    # @param [Array] body All the statements in the function body
    # @param [Integer] line At what line the function is declared
    #
    def initialize(type_specifier, identifier, params, body, line)
      super(NODE_TYPES[:FuncDeclaration], line)
      @type_specifier = type_specifier
      @identifier = identifier
      @params = params
      @body = body
    end

    #
    # Returns a string representation of the function
    #
    # @return [String]
    #
    def to_s
      "Function declaration: Type: #{@type_specifier.gsub(',', ', ')}"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
      puts "#{' ' * (indent + 2)} Return type: #{@type_specifier}"
      puts "#{' ' * (indent + 2)} Params:"
      @params.each { |param| param.display_info(indent + 4) unless @params.empty? }
      puts "#{' ' * (indent + 2)} Body:"
      @body.each { |stmt| stmt.display_info(indent + 4) }
    end
  end
end