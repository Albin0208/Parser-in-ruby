require_relative 'stmt'

class ArrayDeclaration < Stmt
  attr_reader :value, :identifier, :constant, :value_type

  #
  # Creates an var declaration node
  #
  # @param [Boolean] constant If this var should be a constant
  # @param [Identifier] identifier The identifier for the var
  # @param [<Type>] value_type What type this var is
  # @param [Expr] value The value that should be assigned or nil if only declaring
  #
  def initialize(constant, identifier, value_type, line, value = nil)
    super(NODE_TYPES[:ArrayDeclaration], line)
    @constant = constant
    @identifier = identifier
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
    puts "#{' ' * indent} #{self.class.name}: #{@constant} #{@identifier} #{@value_type}"
    @value&.display_info(indent + 2)
  end
end