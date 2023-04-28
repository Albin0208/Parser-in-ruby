require_relative 'stmt'

# This class represents the ast node for the program
class Program < Stmt
  attr_reader :body

  def initialize(body)
    super(NODE_TYPES[:Program])
    @body = body # A list of all statements
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
    @body.each { |stmt| stmt.display_info(indent + 2) }
  end
end