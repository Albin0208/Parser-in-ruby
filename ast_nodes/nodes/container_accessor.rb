require_relative 'expr'

module Nodes
  class ContainerAccessor < Expr
    attr_reader :identifier, :access_key

    def initialize(identifier, access_key, line)
      super(NODE_TYPES[:ContainerAccessor], line)
      @identifier = identifier
      @access_key = access_key
    end

    def to_s
      "Identifier: #{@identifier}, Key: #{@access_key}"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
      puts "#{' ' * (indent + 2)} Identifier: #{@identifier}"
      puts "#{' ' * (indent + 2)} Key: #{@access_key}"
    end
  end
end