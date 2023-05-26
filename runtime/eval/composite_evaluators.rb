module Runtime
	#
  # The CompositeEvaluators module provides evaluation methods for composite nodes.
  #
	module CompositeEvaluators
		private
		# Evaluates a hash literal expression.
    #
    # @param [Nodes::HashLiteral] ast_node The hash literal to evaluate.
    # @param [Environment] env The environment to evaluate the expression in.
    # @return [HashVal] The result of the hash literal evaluation.
    def eval_hash_literal(ast_node, env)
      key_values = ast_node.key_value_pairs
      value_hash = {}

      key_values.map() { |pair|
        key = evaluate(pair[:key], env)
        value = evaluate(pair[:value], env)

        key = coerce_value_to_type(ast_node.key_type, key, ast_node.line)
        value = coerce_value_to_type(ast_node.value_type, value, ast_node.line)

        unless ast_node.value_type.is_a?(Array)
          # Check if the key type is correct
          if key.type != ast_node.key_type
            raise "Line: #{ast_node.line}: Error: Hash expected key of type #{key.type} but got #{ast_node.key_type}"
          end
          if value.type != ast_node.value_type
            raise "Line: #{ast_node.line}: Error: Hash expected value of type #{value.type} but got #{ast_node.value_type.to_s.gsub(',', ', ')}"
          end
        end
        value_hash[key.value] = value
      }
      # Build the hash type
      type = "Hash<#{ast_node.key_type},#{ast_node.value_type}>".to_sym

      return Values::HashVal.new(value_hash, ast_node.key_type, ast_node.value_type, type)
    end

		# Evaluates an array literal, ensuring that all elements have the correct type.
    #
    # @param ast_node [Nodes::ArrayLiteral] The AST node representing the array literal.
    # @param env [Environment] The environment in which the array is being evaluated.
    #
    # @return [ArrayVal] The resulting array value, with the appropriate type.
    # @raise [RuntimeError] If an element in the array has the wrong type and cannot be coerced.
    def eval_array_literal(ast_node, env)
      values = []

      ast_node.value.each() { |val|
        value = evaluate(val, env)
        values << coerce_value_to_type(ast_node.value_type, value, ast_node.line)
      }

      type = "#{ast_node.value_type}[]"

      return Values::ArrayVal.new(values, type)
    end

    # Evaluates an assignment expression and updates the environment accordingly.
    #
    # @param ast_node [Nodes::AssignmentExpr] The AST node representing the assignment expression
    # @param env [Environment] The environment in which to evaluate the expression
    #
    # @return [RunTimeVal] The new value of the assigned variable or container
    # @raise [RuntimeError] If the assignment target is not an identifier or container accessor
    def eval_assignment_expr(ast_node, env)
      case ast_node.assigne.type
      when :ContainerAccessor
        return eval_assignment_to_container_access(ast_node, env)
      when :PropertyCallExpr
        # Evaluate the class value and check if it's a ClassVal
        class_value = evaluate(ast_node.assigne.expr, env)
        unless class_value.instance_of?(Values::ClassVal)
          raise "Line: #{ast_node.line}: Error: Can't assign to property of non-class object"
        end

        # Assign the value to the class instance environment
        value = evaluate(ast_node.value, env)
        return class_value.class_instance.instance_env.assign_var(ast_node.assigne.property_name, value, ast_node.line)
      when NODE_TYPES[:Identifier]
        # Assign the value to the identifier
        env.assign_var(ast_node.assigne.symbol, evaluate(ast_node.value, env), ast_node.line)
      else
        raise "Line: #{ast_node.line}: Cannot assign to non-Identifier type"
      end
    end

    # Evaluates an assignment to a container access expression, which can be a single access or a chain of accesses.
    # @param ast_node [Nodes::AssignmentExpr] The AST node representing the assignment to a container access expression.
    # @param env [Environment] The environment in which the assignment should be evaluated.
    #
    # @return [RunTimeVal] The container value that was assigned to.
    def eval_assignment_to_container_access(ast_node, env)
      access_nodes = [ast_node.assigne]
      # Extract all the chained container accesses
      access_nodes << access_nodes.last.identifier while access_nodes.last.identifier.is_a?(Nodes::ContainerAccessor)
      # Grab the top container of the call chain
      if env.is_constant?(access_nodes.last.identifier.symbol)
        raise "Line:#{ast_node.line}: Error: Can't assign to a constant container"
      end
      
      container = env.lookup_identifier(access_nodes.last.identifier.symbol, ast_node.line)
      access_nodes.shift # Remove the node where the assignments is done since it is done later

      container = traverse_container_access(access_nodes, container, env, ast_node.line) 

      # Retrieve the final access key
      access_key = evaluate(ast_node.assigne.access_key, env)
      validate_access_key(ast_node, container, access_key)

      # Evaluate the assigned value
      value = evaluate(ast_node.value, env)
      value_type = if container.is_a?(Values::ArrayVal)
                     container.value_type.to_s.sub('[]', '')
                   else
                     container.value_type
                   end

      value = coerce_value_to_type(value_type, value, ast_node.line)

      # Assign the value to the container
      container.value[access_key.value] = value
      return Values::NullVal.new()
    end

		# Evaluates an identifier expression.
    #
    # @param [Nodes::Identifier] ast_node The identifier to look up.
    # @param [Environment] env The environment to evaluate the expression in.
    #
    # @return [RunTimeVal] The value of the identifier in the environment.
    def eval_identifier(ast_node, env)
      return env.lookup_identifier(ast_node.symbol, ast_node.line)
    end

		# Evaluates a logical AND expression.
    #
    # @param [Nodes::LogicalAndExpr] logic_and The logical AND expression to evaluate.
    # @param [Environment] env The environment to evaluate the expression in.
    #
    # @return [BooleanVal] The result of the logical AND operation.
    def eval_logical_and_expr(logic_and, env)
      lhs = evaluate(logic_and.left, env)
      return lhs if lhs.value == false # Don't eval right side if we are false

      rhs = evaluate(logic_and.right, env)
      # We have come here so we know the expr is true if the right side is true
      Values::BooleanVal.new(rhs.value == true)
    end

    # Evaluates a logical OR expression.
    #
    # @param [Nodes::LogicalOrExpr] logic_or The logical OR expression to evaluate.
    # @param [Environment] env The environment to evaluate the expression in.
    #
    # @return [BooleanVal] The result of the logical OR operation.
    def eval_logical_or_expr(logic_or, env)
      lhs = evaluate(logic_or.left, env)
      # Return early if lhs is true since only one of the statements have to be true
      return lhs if lhs.value == true

      rhs = evaluate(logic_or.right, env)

      return Values::BooleanVal.new(rhs.value == true)
    end

    # Evaluates a unary expression and returns the result
    #
    # @param unary [Nodes::UnaryExpr] the unary expression to evaluate
    # @param env [Environment] the environment to use for variable lookups
    #
    # @return [NumberVal, BooleanVal] the result of the evaluation
    def eval_unary_expr(unary, env)
      lhs = evaluate(unary.left, env)
      case unary.op
      when :-
        return Values::NumberVal.new((-lhs).value, lhs.type)
      when :+
        return Values::NumberVal.new((+lhs).value, lhs.type)
      when :!
        return Values::BooleanVal.new((!lhs).value)
      end
    end

    #
    # Evaluates a binary expression by evaluation the left and right operands,
    # then performing the specified operation on the two.
    #
    # @param [Nodes::BinaryExpr] binop The binary expression node to be evaluated
    # @param [Environment] env The environment in which we are evaluating
    #
    # @return [NumberVal, BooleanVal] the result of the binary operation
    #
    def eval_binary_expr(binop, env)
      lhs = evaluate(binop.left, env)
      rhs = evaluate(binop.right, env)

      unless lhs.is_a?(Values::RunTimeVal) && rhs.is_a?(Values::RunTimeVal)
        raise "Line:#{binop.line} Error: Unsupported operand type for #{binop.op}: #{lhs.class} and #{rhs.class}"
      end

      lhs.send(binop.op, rhs)
    end

	end
end