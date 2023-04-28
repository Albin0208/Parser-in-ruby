require_relative 'stmt'

class HashDeclaration < Stmt
  attr_reader :value, :identifier, :constant, :key_type, :value_type

  #
  # Creates an hash declaration node
  #
  # @param [Boolean] constant If this var should be a constant
  # @param [Identifier] identifier The identifier for the var
  # @param [string] key_type What type the key has
  # @param [string] value_type What type the value is
  # @param [Expr] value The value that should be assigned or nil if only declaring
  #
  def initialize(constant, identifier, key_type, value_type, value = nil)
    super(NODE_TYPES[:HashDeclaration])
    @constant = constant
    @identifier = identifier
    @key_type = key_type
    @value_type = value_type
    @value = value
  end

  def to_s
    "Const: #{@constant}, Ident: #{@identifier}, Value: #{@value}, Type: #{@value_type}"
  end

  #
  # Display the information about the node as a tree structure
  #
  # @param [Integer] indent How much the next row should be indented
  #
  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@constant} #{@identifier}"
    puts "#{' ' * (indent + 2)} Key type: #{@key_type}"
    puts "#{' ' * (indent + 2)} Value type: #{@value_type}"
    puts "#{' ' * (indent + 2)} Value:"
    @value&.display_info(indent + 2)
  end
end