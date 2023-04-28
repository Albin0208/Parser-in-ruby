require_relative 'stmt'

class BreakStmt < Stmt
  def initialize
    super(NODE_TYPES[:BreakStmt])
  end

  def to_s
    "Break Stmt"
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