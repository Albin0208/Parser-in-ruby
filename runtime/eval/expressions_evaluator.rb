require_relative '../environment'
require_relative '../../ast_nodes/nodes'

module Runtime
  #
  # ExpressionsEvaluator defines a set of methods that can evaluate
  # different types of AST nodes representing expressions in a programming language.
  #
  # The module includes methods for evaluating identifiers,
  # binary expressions, unary expressions and more.
  module ExpressionsEvaluator
    private

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
        return NativeFunctions.dispatch(ast_node.func_name.symbol, param_results)
        # return nil
      end
      unless function.instance_of?(Nodes::FuncDeclaration)
        raise "Line: #{ast_node.line}: Error: #{ast_node.func_name.symbol} is not a function"
      end

      return call_function(function, ast_node, call_env)
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
        evaled_call_param = evaluate(call_param, call_env)

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
        evaled_call_param = evaluate(call_param, call_env)

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

    #
    # Evaluates a creation of a class instance
    #
    # @param [Nodes::ClassInstance] ast_node The ast node
    # @param [Environment] env The environment where the class instance is created
    #
    # @return [ClassVal] The class we wanted a instance of
    #
    def eval_class_instance(ast_node, env)
      class_instance = evaluate(ast_node.value, env).clone
      class_instance.create_instance(self)

      # Eval the constructor if it exists
      unless class_instance.constructors.empty?
        eval_constructor(class_instance, ast_node.params, class_instance.instance_env, env)
      end
      return Values::ClassVal.new(ast_node.value.symbol, class_instance)
    end

    # Evaluates a constructor with the given parameters in the context of the current instance environment and global environment.
    #
    # @param ast_node [Nodes::ClassDeclaration] an array of constructor statements
    # @param params [Array] an array of parameter values to be passed to the constructor
    # @param instance_env [Environment] the instance environment of the current object
    # @param env [Environment] the global environment
    #
    # @raise [RuntimeError] if the wrong number or types of parameters are passed to the constructor
    def eval_constructor(ast_node, params, instance_env, env)
      matching_ctor = nil
      ast_node.constructors.each do |ctor|
        begin
          if (ctor.params.empty? && params.empty?) || validate_params(ctor, params, env)
            matching_ctor = ctor
            break
          end
        rescue StandardError => e # Recover if the validate params fails
        end
      end

      # Throw error if we have not found a constructor
      if matching_ctor.nil?
        param_types = params.map() { |param| param.is_a?(Nodes::NumericLiteral) ? param.numeric_type : param.type }.join(', ')
        raise "Line:#{ast_node.line}: Error: no matching constructor for #{ast_node.class_name.symbol}::Constructor(#{param_types})"
      end

      ctor_env = Environment.new(instance_env)

      declare_params(matching_ctor, params, env, ctor_env) unless params.empty?

      matching_ctor.body.each() { |stmt| evaluate(stmt, ctor_env) }
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
  end
end
