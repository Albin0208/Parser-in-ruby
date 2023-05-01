require_relative 'stmt'

class ReturnStmt < Stmt
	attr_reader :return_type, :body

	def initialize(body)
		super(NODE_TYPES[:ReturnStmt])
		@body = body
	end

	def to_s
		"Return Body: #{@body}"
	end

	#
  # Display the information about the node as a tree structure
  #
  # @param [Integer] indent How much the next row should be indented
  #
	def display_info(indent = 0)
			puts "#{' ' * indent} #{self.class.name}"
			puts "#{' ' * (indent + 2)} Body:"
			@body&.display_info(indent + 4)
	end
end