require_relative 'expr'

module Nodes
	#
	# The ast node for a call expression to a function
	#
	class CallExpr < Expr
		attr_reader :func_name, :params

		#
		# Creates the callexpr node
		#
		# @param [String] func_name The name of the function to call
		# @param [Array] params A list of params that should be sent to the function later
		# @param [Integer] line The line number in the source code where the node is created.
		#
		def initialize(func_name, params, line)
			super(NODE_TYPES[:CallExpr], line)
			@func_name = func_name
			@params = params
		end

		
		# Returns a string representation of the CallExpr node.
		#
		# @return [String]
		def to_s
			"Func name: #{@func_name}, Params: #{@params}"
		end

		#
		# Display the information about the node as a tree structure
		#
		# @param [Integer] indent How much the next row should be indented
		#
		def display_info(indent = 0)
			puts "#{' ' * indent} #{self.class.name}"
			puts "#{' ' * (indent + 2)} Func name: #{func_name}"
			puts "#{' ' * indent} Params:"
			@params.each { |param| param.display_info(indent + 2) unless @params.empty? }
		end
	end
end