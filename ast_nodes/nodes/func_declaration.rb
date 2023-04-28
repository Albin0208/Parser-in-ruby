require_relative 'stmt'

class FuncDeclaration < Stmt
  attr_reader :type_specifier, :identifier, :params, :body
  attr_accessor :env

  def initialize(type_specifier, identifier, params, body)
    super(NODE_TYPES[:FuncDeclaration])
    @type_specifier = type_specifier
    @identifier = identifier
    @params = params
    @body = body
  end

  def to_s
    "Type: #{@type_specifier}, Ident: #{@identifier}, Params: #{@params}, body: #{@body}"
  end

  #
  # Display the information about the node as a tree structure
  #
  # @param [Integer] indent How much the next row should be indented
  #
  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * indent} Return type: #{@type_specifier}"
    puts "#{' ' * indent} Params:"
    @params.each { |param| param.display_info(indent + 2) unless @params.empty? }
    puts "#{' ' * indent} Body:"
    @body.each { |stmt| stmt.display_info(indent + 2) }
  end
end