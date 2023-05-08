require_relative 'stmt'

module Nodes
  # A node representing a for-each loop in the code.
  class ForEachStmt < Stmt
    attr_reader :body, :identifier, :container
    def initialize(body, identifier, container, line)
      super(NODE_TYPES[:FOR_EACH_LOOP], line)
      @body = body # A list of all statements
      @identifier = identifier
      @container = container
    end

    def to_s
      @body.map(&:to_s)
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
      puts "#{' ' * indent} Identifier: #{@identifier}"
      puts "#{' ' * indent} Container: "
      @container.display_info(indent + 2)
      puts "#{' ' * indent} Body:"
      @body.each { |stmt| stmt.display_info(indent + 2) }
    end
  end
end