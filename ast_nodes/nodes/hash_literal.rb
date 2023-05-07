require_relative 'expr'

module Nodes
  class HashLiteral < Expr
    attr_reader :key_value_pairs, :key_type, :value_type

    #
    # Create a new HashLiteral
    #
    # @param [Array] key_value_pairs The list of all key value pairs
    #
    def initialize(key_value_pairs, key_type, value_type, line)
      super(NODE_TYPES[:HashLiteral], line)
      @key_value_pairs = key_value_pairs
      @key_type = key_type
      @value_type = value_type
    end

    def to_s
      "HashLiteral"
    end

    #
    # Display the information about the node as a tree structure
    #
    # @param [Integer] indent How much the next row should be indented
    #
    def display_info(indent = 0)
      puts "#{' ' * indent} #{self.class.name}"
      @key_value_pairs.each() { |pair| puts "#{' ' * (indent + 2)} Key: #{pair[:key]} Value: #{pair[:value]}" }
    end
  end
end