require_relative 'stmt'

module Nodes
	#
	# The node representing a return statment
	#
	class ReturnStmt < Stmt
		attr_reader :return_type, :body

		#
		# Creates a new return statment
		#
		# @param [Expr] body The expression of which the return shuold return the result of
		# @param [Integer] line At what line the return is at
		#
		def initialize(body, line)
			super(NODE_TYPES[:ReturnStmt], line)
			@body = body
		end

		#
		# Returns a string representation of the return statement
		#
		# @return [String] A string representaion of the node
		#
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
end