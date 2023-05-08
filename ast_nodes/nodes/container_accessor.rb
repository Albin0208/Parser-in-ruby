require_relative 'expr'

module Nodes
  #
  # A representation of a ContainerAccess
  #
  class ContainerAccessor < Expr
    attr_reader :identifier, :access_key

    #
    # Creates a new container accessor
    #
    # @param [Identifier] identifier The identifier of the container we want to access
    # @param [Expr] access_key The key of the container
    # @param [Integer] line At what line the access is done
    #
    def initialize(identifier, access_key, line)
      super(NODE_TYPES[:ContainerAccessor], line)
      @identifier = identifier
      @access_key = access_key
    end

    #
    # Retuns a string representation of the access
    #
    # @return [String]
    #
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