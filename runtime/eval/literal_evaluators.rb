module Runtime
	#
  # The LiteralEvaluators module provides evaluation methods for literal nodes.
  #
	module LiteralEvaluators
		private
		# Evaluates a numeric literal AST node.
    #
    # @param ast_node [ASTNode] The numeric literal AST node.
    # @param env [Environment] The environment.
    # @return [NumberVal] The evaluated numeric value.
    def eval_numeric_literal(ast_node, env)
      Values::NumberVal.new(ast_node.value, ast_node.numeric_type)
    end

    # Evaluates a boolean literal AST node.
    #
    # @param ast_node [ASTNode] The boolean literal AST node.
    # @param env [Environment] The environment.
    # @return [BooleanVal] The evaluated boolean value.
    def eval_boolean_literal(ast_node, env)
      Values::BooleanVal.new(ast_node.value)
    end

    # Evaluates a string literal AST node.
    #
    # @param ast_node [ASTNode] The string literal AST node.
    # @param env [Environment] The environment.
    # @return [StringVal] The evaluated string value.
    def eval_string_literal(ast_node, env)
      Values::StringVal.new(ast_node.value)
    end

    # Evaluates a null literal AST node.
    #
    # @param ast_node [ASTNode] The null literal AST node.
    # @param env [Environment] The environment.
    # @return [NullVal] The evaluated null value.
    def eval_null_literal(ast_node, env)
      Values::NullVal.new
    end
	end
end