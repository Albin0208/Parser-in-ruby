require_relative 'stmt'

module Nodes
  class Constructor < Stmt
    attr_reader :params, :body
    attr_accessor :env

    def initialize(params, body, line)
      super(NODE_TYPES[:Constructor], line)
      @params = params
      @body = body
    end

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