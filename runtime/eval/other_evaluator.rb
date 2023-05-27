module Runtime
	#
  # The OtherEvaluator module provides evaluation methods for other nodes.
  #
	module OtherEvaluator
		private
		# Evaluate a container accessor expression and return its value.
		#
		# @param ast_node [Nodes::ContainerAccessor] the AST node representing the container accessor expression
		# @param env [Environment] the environment to evaluate the expression in
		# @return [RunTimeVal] the value of the container accessor expression
		# @raise [NameError] if the container identifier is not found in the environment
		#
		def eval_container_accessor(ast_node, env)
			container = evaluate(ast_node.identifier, env)
	
			unless container.is_a?(Values::HashVal) || container.is_a?(Values::ArrayVal)
			raise "Line: #{ast_node.line}: Error: Invalid type for container accessor, #{container.class}"
			end
	
			access_key = evaluate(ast_node.access_key, env).value
	
			if container.is_a?(Values::ArrayVal)
			# Wrap around from the back if it is negative
			access_key = access_key % container.length.value if access_key.negative?
		
				if access_key >= container.length.value
					raise "Line:#{ast_node.line}: Error: index #{access_key} out of bounds for array of length #{container.length.value}"
				end
			end
	
			value = container.value[access_key]
	
			raise "Line: #{ast_node.line}: Error: Key: #{access_key} does not exist in container" if value.nil?
	
			# Return the value unless it is nil
			return value || Values::NullVal.new()
		end
	end
end