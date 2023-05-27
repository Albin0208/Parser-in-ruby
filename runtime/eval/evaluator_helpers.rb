module Runtime
	module EvaluatorHelpers
		# Coerces a value to a specified type, if possible.
    #
    # @param node_type [String, Symbol] The desired type, as a string or symbol.
    # @param value [RunTimeVal] The value to be coerced.
    # @param line [Integer] The line number of the code being evaluated (for error messages).
    # @return [RunTimeVal] The coerced value, with the appropriate type.
    # @raise [RuntimeError] If the value cannot be coerced to the specified type.
    def coerce_value_to_type(node_type, value, line)
      node_type = node_type.to_s

      # Check that the type of the value matches the declared type,
      # or that it can be coerced to that type
      unless (value.type.to_s == node_type) ||
             (node_type == 'float' && value.type == :int) ||
             (node_type == 'int' && value.type == :float)
        raise "Line:#{line}: Error: Type mismatch: expected #{node_type}, but got #{value.type}"
      end

      if node_type == 'int' && value.type == :float
        return value.to_int()
      elsif node_type == 'float' && value.type == :int
        return value.to_float()
      end

      return value
    end

		    #
    # Validate the params to the function. Raises error if not valid params
    #
    # @param [Nodes::FuncDeclaration] function The declaration of the function called
    # @param [Array] call_params A list of all the params passed to the function
    # @param [Environment] call_env Where the function was called
    #
    # @raise StandardError Error if the params are not valid
    def validate_params(function, call_params, call_env)
      unless function.params.length == call_params.length
        types = function.params.map(&:value_type).join(', ')
        raise 'Error:' if function.is_a?(Nodes::Constructor)

        raise "Line: #{function.line}: Error: Wrong number of arguments passed to function '#{function.type_specifier} #{function.identifier}(#{types})'. Expected '#{function.params.length}' but got '#{call_params.length}'"
      end

      function.params.zip(call_params) { |func_param, call_param|
        # Grab the converter if it exits else convert to symbol
        type = if func_param.is_a?(Nodes::HashDeclaration)
                 # Build the hash type
                 "Hash<#{func_param.key_type},#{func_param.value_type}>".to_sym
               else
                 func_param.value_type.to_sym
               end

        evaled_call_param = call_param.is_a?(Values::RunTimeVal) ? call_param : evaluate(call_param, call_env)
        
        unless evaled_call_param.type.to_s.downcase == type.to_s.downcase
          raise "Line: #{function.line}: Error: Expected parameter '#{func_param.identifier}' to be of type '#{type}', but got '#{evaled_call_param.type}'"
        end
      }

      return true
    end


    #
    # Declares all params passed to a function
    #
    # @param [Nodes::FuncDeclaration] function The declaration of the function called
    # @param [Array] call_params A list of all the params passed to the function
    # @param [Environment] call_env Where the function was called
    # @param [Environment] env The environment for the current call of the function
    #
    def declare_params(function, call_params, call_env, env)
      function.params.zip(call_params) { |func_param, call_param|
        evaled_call_param = call_param.is_a?(Values::RunTimeVal) ? call_param : evaluate(call_param, call_env)

        type = if func_param.is_a?(Nodes::HashDeclaration)
                 # Build the hash type
                 "Hash<#{func_param.key_type},#{func_param.value_type}>".to_sym
               else
                 func_param.value_type
               end

        # Convert int passed to float and float passed to int
        case func_param.value_type
        when 'int'
          evaled_call_param = Values::NumberVal.new(evaled_call_param.value.to_i, :int)
        when 'float'
          evaled_call_param = Values::NumberVal.new(evaled_call_param.value.to_f, :float)
        end

        # Declare any var params
        env.declare_var(func_param.identifier, evaled_call_param, type, function.line, false)
      }
    end


    # Calls a function with the given arguments.
    #
    # @param [Nodes::FuncDeclaration] function The function to call.
    # @param [Nodes::CallExpr] ast_node The function call AST node.
    # @param [Environment] call_env The environment in which the function call occurs.
    #
    # @return [RunTimeVal] The value returned by the function.
    def call_function(function, ast_node, call_env)
      env = Runtime::Environment.new(function.env)
      validate_params(function, ast_node.params, call_env)
      declare_params(function, ast_node.params, call_env, env)

      return_value = nil
      begin
        function.body.each() { |stmt| evaluate(stmt, env) }
      rescue ReturnSignal => e
        return_value = e.return_node
      end

      expected_return_type = function.type_specifier.to_sym
      return Values::NullVal.new() if expected_return_type == :void

      # Check that the return value is the same type as the return type of the function
      if return_value.type != expected_return_type
        raise "Line: #{ast_node.line}: Error: function expected a return type of #{function.type_specifier} but got #{return_value.type}"
      end

      return return_value
    end

		    # Traverses the container accesses in reverse order and retrieves the final container.
    #
    # @param access_nodes [Array<ContainerAccessor>] The array of container access nodes in reverse order.
    # @param container [HashVal, ArrayVal] The initial container object.
    # @param env [Environment] The environment object.
    # @param line [Integer] The line number for error reporting.
    # @return [HashVal, ArrayVal] The final container object after traversing the container accesses.
    def traverse_container_access(access_nodes, container, env, line)
      # Reverse traverse through all the container accesses
      access_nodes.reverse_each { |access|
        access_key = evaluate(access.access_key, env).value
        if container.is_a?(Values::ArrayVal)
          # Wrap around from the back if it is negative
          # access_key = access_key.value
          access_key = access_key % container.length.value if access_key.negative?
          
          if access_key >= container.length.value
            raise "Line:#{ast_node.line}: Error: index #{access_key} out of bounds for array of length #{container.length.value}"
          end
        end

        container = container.value[access_key]
      }
      return container
    end

    # Validates the access key based on the container type.
    #
    # @param ast_node [ASTNode] The AST node being evaluated.
    # @param container [Object] The container object being accessed.
    # @param access_key [Object] The access key being validated.
    # @raise [RuntimeError] If the access key is invalid for the container.
    def validate_access_key(ast_node, container, access_key)
      if container.is_a?(Values::HashVal)
        unless container.key_type == access_key.type
          raise "Line: #{ast_node.line}: Error: Invalid key type, expected #{container.key_type} but got #{access_key.type}"
        end
      else
        unless access_key.type == :int
          raise "Line:#{ast_node.line}: Error: Array expected an index of type int but got #{access_key.type}"
        end
        
        if access_key.value.negative?
          access_key = Values::NumberVal.new(access_key.value % container.length.value, :int)
        end
        
        if access_key.value >= container.length.value
          raise "Line:#{ast_node.line}: Error: index #{access_key} out of bounds for array of length #{container.length.value}"
        end
      end
    end

	end
end