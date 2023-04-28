require_relative 'stmt'

class ContinueStmt < Stmt
  def initialize
    super(NODE_TYPES[:ContinueStmt])
  end

  def to_s
    "Continue Stmt"
  end

  #
  # Display the information about the node as a tree structure
  #
  # @param [Integer] indent How much the next row should be indented
  #
  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
  end
end
