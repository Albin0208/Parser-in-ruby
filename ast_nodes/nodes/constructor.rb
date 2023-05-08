require_relative 'stmt'

module Nodes
  # A node representing a constructor definition in a class.
  class Constructor < Stmt
    attr_reader :params, :body
    attr_accessor :env

    #
    # Creates a new instance of a construcot
    #
    # @param [Array] params The list of all params that the constructor takes
    # @param [Array] body A list of all the statments in the body
    # @param [Integer] line At what line the constructor stars
    #
    def initialize(params, body, line)
      super(NODE_TYPES[:Constructor], line)
      @params = params
      @body = body
    end

    # Returns a string representation of the constructor
    #
    # @return [String]
    def to_s
      "Constructor"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
      puts "#{' ' * (indent + 2)} Params:"
      @params.each { |param| param.display_info(indent + 4) unless @params.empty? }
      puts "#{' ' * (indent + 2)} Body:"
      @body.each { |stmt| stmt.display_info(indent + 4) }
    end
  end
end