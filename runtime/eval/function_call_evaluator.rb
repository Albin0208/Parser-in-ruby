module Runtime
	#
  # The FunctionCallEvaluator module provides evaluation methods for function and method call nodes.
  #
	module FunctionCallEvaluator
		private
		# Evaluate a method call expression by first evaluating the receiver expression and
    # then looking up the method in the class hierarchy or the receiver's metaclass.
    #
    # @param ast_node [Nodes::MethodCallExpr] the AST node representing the method call expression
    # @param call_env [Environment] the environment in which the method call is evaluated
    #
    # @return [RunTimeVal] the result of calling the method with the given arguments
    # @raise [RuntimeError] if the method is not defined or the receiver is not a valid object or class
    def eval_method_call_expr(ast_node, call_env)
      evaled_expr = evaluate(ast_node.expr, call_env)
      err_class_name = evaled_expr.class
      # Check if we are calling a custom class
      if evaled_expr.instance_of?(Values::ClassVal)
        # Grab the method, if error occurs it does not exist then set method to nil
        method = begin
                   evaled_expr.class_instance.instance_env.lookup_identifier(ast_node.method_name, ast_node.line)
                 rescue StandardError
                   nil
                 end

        return call_function(method, ast_node, call_env) unless method.nil?
      end

      # Check if the method exists
      available_methods = evaled_expr.class.instance_methods() - Object.class.methods() << :to_s # Add back the to_s method
      unless available_methods.include?(ast_node.method_name.to_sym)
        raise "Line:#{ast_node.line}: Error: Method #{ast_node.method_name} is not defined in #{err_class_name}"
      end

      # Grab the methods
      method = evaled_expr.method(ast_node.method_name)
      args = ast_node.params.map() { |param| evaluate(param, call_env) }

      return method.call(*args)
    end

    #
    # Evaluates a property call ast node by evaluating the expression and looking
    # up the property name in the instance environment
    #
    # @param [Nodes::PropertyCallExpr] ast_node The property call node
    # @param [Environment] call_env From where the call is made
    #
    # @return [RunTimeVal] The value of the property being called
    #
    def eval_property_call_expr(ast_node, call_env)
      evaled_expr = evaluate(ast_node.expr, call_env)
      instance_env = evaled_expr.class_instance.instance_env

      return instance_env.lookup_identifier(ast_node.property_name, ast_node.line)
    end

    # Evaluates a call expression in the specified environment.
    #
    # @param ast_node [Nodes::CallExpr] the call expression node to evaluate
    # @param call_env [Environment] the environment to evaluate the call expression in
    # @raise [RuntimeError] if the specified function is not defined in the current environment
    # @raise [RuntimeError] if the return value of the function is not of the expected type
    #
    # @return [NullVal] A null value if the function is of type void
    # @return [RunTimeVal] the return value of the evaluated call expression
    def eval_call_expr(ast_node, call_env)
      function = call_env.lookup_identifier(ast_node.func_name.symbol, ast_node.line)
      if function.instance_of?(Symbol) && function == :native_func
        param_results = ast_node.params.map() { |param|
          evaled = evaluate(param, call_env)
          if !evaled.is_a?(Values::HashVal) && !evaled.is_a?(Values::ArrayVal) && evaled.instance_variable_defined?(:@value)
            evaled.value
          else
            evaled
          end
        }
        NativeFunctions.dispatch(ast_node.func_name.symbol, param_results)
        return nil
      end
      unless function.instance_of?(Nodes::FuncDeclaration)
        raise "Line: #{ast_node.line}: Error: #{ast_node.func_name.symbol} is not a function"
      end

      return call_function(function, ast_node, call_env)
    end
	end
end