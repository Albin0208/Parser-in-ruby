require_relative '../environment'
require_relative '../../ast_nodes/nodes'

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
  # @param [Identifier] ast_node The identifier to look up.
  # @param [Environment] env The environment to evaluate the expression in.
  # @return [RunTimeVal] The value of the identifier in the environment.
  def eval_identifier(ast_node, env)
    return env.lookup_identifier(ast_node.symbol, ast_node.line)
  end

  # Evaluates a logical AND expression.
  #
  # @param [LogicalAndExpr] logic_and The logical AND expression to evaluate.
  # @param [Environment] env The environment to evaluate the expression in.
  # @return [BooleanVal] The result of the logical AND operation.
  def eval_logical_and_expr(logic_and, env)
    lhs = evaluate(logic_and.left, env)
    return lhs if lhs.value == false # Don't eval right side if we are false

    rhs = evaluate(logic_and.right, env)
    # We have come here so we know the expr is true if the right side is true
    BooleanVal.new(rhs.value == true)
  end

  # Evaluates a logical OR expression.
  #
  # @param [LogicalOrExpr] logic_or The logical OR expression to evaluate.
  # @param [Environment] env The environment to evaluate the expression in.
  # @return [BooleanVal] The result of the logical OR operation.
  def eval_logical_or_expr(logic_or, env)
    lhs = evaluate(logic_or.left, env)
    # Return early if lhs is true since only one of the statments have to be true
    if lhs.value == true
      return lhs
    end
    rhs = evaluate(logic_or.right, env)

    return BooleanVal.new(rhs.value == true)
  end

  # Evaluates a unary expression and returns the result
  #
  # @param unary [UnaryExpr] the unary expression to evaluate
  # @param env [Environment] the environment to use for variable lookups
  # @return [NumberVal, BooleanVal] the result of the evaluation
  def eval_unary_expr(unary, env)
    lhs = evaluate(unary.left, env)
    case unary.op
    when :-
      return NumberVal.new((-lhs).value, lhs.type)
    when :+
      return NumberVal.new((+lhs).value, lhs.type)
    when :!
      return BooleanVal.new((!lhs).value)
    end
  end

  #
  # Evaluates a binary expression by evaluation the left and right operands,
  # then performing the specified operation on the two.
  #
  # @param [BinaryExpr] binop The binary expression node to be evaluated
  # @param [Environment] env The environment in which we are evaluating
  #
  # @return [NumberVal, BooleanVal] the result of the binary operation
  #
  def eval_binary_expr(binop, env)
    lhs = evaluate(binop.left, env)
    rhs = evaluate(binop.right, env)

    raise "Line:#{binop.line} Error: Unsupported operand type for #{binop.op}: #{lhs.class} and #{rhs.class}" unless lhs.is_a?(RunTimeVal) && rhs.is_a?(RunTimeVal)

    lhs.send(binop.op, rhs)
  end

  # Evaluates an assignment expression and updates the environment accordingly.
  #
  # @param ast_node [AssignmentExpr] The AST node representing the assignment expression
  # @param env [Environment] The environment in which to evaluate the expression
  # @return [RunTimeVal] The new value of the assigned variable or container
  # @raise [RuntimeError] If the assignment target is not an identifier or container accessor
  def eval_assignment_expr(ast_node, env)
    case ast_node.assigne.type
    when :ContainerAccessor 
      return eval_assignment_to_container_access(ast_node, env)
    when :PropertyCallExpr
      # Evaluate the class value and check if it's a ClassVal
      class_value = evaluate(ast_node.assigne.expr, env)
      raise "Line: #{ast_node.line}: Error: Can't assign to property of non-class object" unless class_value.instance_of?(ClassVal)
  
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
  # @param ast_node [AssignmentExpr] The AST node representing the assignment to a container access expression.
  # @param env [Environment] The environment in which the assignment should be evaluated.
  # @return [RunTimeVal] The container value that was assigned to.
  def eval_assignment_to_container_access(ast_node, env)
    access_nodes = [ast_node.assigne]
    # Extract all the chained container accesses
    while access_nodes.last.identifier.is_a?(ContainerAccessor)
      access_nodes << access_nodes.last.identifier
    end
    # Grab the top container of the call chain
    container = env.lookup_identifier(access_nodes.last.identifier.symbol, ast_node.line)
    access_nodes.shift # Remove the node where the assignments is done since it is done later

    # Reverse traverse through all the container accesses
    access_nodes.reverse_each { |access| 
      access_key = evaluate(access.access_key, env)
      if container.is_a?(ArrayVal)
        # Wrap around from the back if it is negative
        access_key = access_key % container.length.value if access_key.negative?
      
        if access_key >= container.length.value
          raise "Line:#{ast_node.line}: Error: index #{access_key} out of bounds for array of length #{container.length.value}"
        end
      end
      unless container.key_type == access_key.type
        raise "Line: #{ast_node.line}: Error: Invalid key type, expected #{container.key_type} but got #{access_key.type}"
      end
      container = container.value[access_key.value]
    }

    # Retrive the final access key
    access_key = evaluate(ast_node.assigne.access_key, env)
    if container.is_a?(HashVal)
      unless container.key_type == access_key.type
        raise "Line: #{ast_node.line}: Error: Invalid key type, expected #{container.key_type} but got #{access_key.type}"
      end
    else # We have an array
      unless access_key.type == :int
        raise "Line:#{ast_node.line}: Error: Array expected a index of type int but got #{access_key.type}"
      end
      # Wrap around from the back if it is negative
      access_key = NumberVal.new(access_key.value % container.length.value, :int) if access_key.value.negative?
    
      if access_key.value >= container.length.value
        raise "Line:#{ast_node.line}: Error: index #{access_key} out of bounds for array of length #{container.length.value}"
      end
    end

    # Evaluate the assigned value
    value = evaluate(ast_node.value, env)
    if container.is_a?(ArrayVal)
      value_type = container.value_type.to_s.gsub('[]', '')
    else
      value_type = container.value_type
    end

    value = coerce_value_to_type(value_type, value, ast_node.line)

    # Assign the value to the container
    container.value[access_key.value] = value
    return value
  end

  # Evaluate a method call expression by first evaluating the receiver expression and
  # then looking up the method in the class hierarchy or the receiver's metaclass.
  #
  # @param ast_node [MethodCallExpr] the AST node representing the method call expression
  # @param call_env [Environment] the environment in which the method call is evaluated
  # @return [RunTimeVal] the result of calling the method with the given arguments
  # @raise [RuntimeError] if the method is not defined or the receiver is not a valid object or class
  def eval_method_call_expr(ast_node, call_env)
    evaled_expr = evaluate(ast_node.expr, call_env)
    err_class_name = evaled_expr.class
    # Check if we are calling a custom class
    if evaled_expr.instance_of?(ClassVal)
      # Grab the method, if error occurs it does not exist then set method to nil
      method = evaled_expr.class_instance.instance_env.lookup_identifier(ast_node.method_name, ast_node.line) rescue nil

      return call_function(method, ast_node, call_env) unless method.nil?
    end

    # Check if the method exists
    available_methods = evaled_expr.class.instance_methods() - Object.class.methods()
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
  # @param [PropertyCallExpr] ast_node The property call node
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
  # @param ast_node [CallExpr] the call expression node to evaluate
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
        if !evaled.is_a?(HashVal) && !evaled.is_a?(ArrayVal) && evaled.instance_variable_defined?(:@value)
          evaled.value
        else
          evaled
        end
      }
      NativeFunctions.dispatch(ast_node.func_name.symbol, param_results)
      return nil
    end
      raise "Line: #{ast_node.line}: Error: #{ast_node.func_name.symbol} is not a function" unless function.instance_of?(FuncDeclaration)

    return call_function(function, ast_node, call_env)
  end

  # Calls a function with the given arguments.
  #
  # @param [FuncDeclaration] function The function to call.
  # @param [CallExpr] ast_node The function call AST node.
  # @param [Environment] call_env The environment in which the function call occurs.
  # @return [RunTimeVal] The value returned by the function.
  def call_function(function, ast_node, call_env)
    env = Environment.new(function.env)
    validate_params(function, ast_node.params, call_env)
    declare_params(function, ast_node.params, call_env, env)

    return_value = nil
    begin
      function.body.each() { |stmt| evaluate(stmt, env) }
    rescue ReturnSignal => signal
      return_value = signal.return_node
    end

    expected_return_type = function.type_specifier.to_sym
    return NullVal.new() if expected_return_type == :void
    
    # Check that the return value is the same type as the return type of the function
    if return_value.type != expected_return_type
      raise "Line: #{ast_node.line}: Error: function expected a return type of #{function.type_specifier} but got #{return_value.type}"
    end

    return return_value
  end

  #
  # Validate the params to the function. Raises error if not valid params
  #
  # @param [FuncDeclaration] function The declaration of the function called
  # @param [Array] call_params A list of all the params passed to the function
  # @param [Environment] call_env Where the function was called
  #
  def validate_params(function, call_params, call_env)
    unless function.params.length == call_params.length
      types = function.params.map(&:value_type).join(", ")
      raise "Line: #{ast_node.line}: Error: Wrong number of arguments passed to function '#{function.type_specifier} #{function.identifier}(#{types})'. Expected '#{function.params.length}' but got '#{call_params.length}'"
    end

    function.params.zip(call_params) { |func_param, call_param| 
      # Grab the converter if it exits else convert to symbol
      type = NODE_TYPES_CONVERTER[func_param.value_type.to_sym] || func_param.value_type.to_sym
      evaled_call_param = evaluate(call_param, call_env)

      unless evaled_call_param.type.downcase == type.downcase
        raise "Line: #{ast_node.line}: Error: Expected parameter '#{func_param.identifier}' to be of type '#{type}', but got '#{evaled_call_param.type}'"
      end
    }
  end

  #
  # Declares all params passed to a function
  #
  # @param [FuncDeclaration] function The declaration of the function called
  # @param [Array] call_params A list of all the params passed to the function
  # @param [Environment] call_env Where the function was called
  # @param [Environment] env The environment for the current call of the function
  #
  def declare_params(function, call_params, call_env, env)
    function.params.zip(call_params) { |func_param, call_param| 
      evaled_call_param = evaluate(call_param, call_env)
      
      # Convert int passed to float and float passed to int
      case func_param.value_type
      when 'int'
        evaled_call_param = NumberVal.new(evaled_call_param.value.to_i, :int)
      when 'float'
        evaled_call_param = NumberVal.new(evaled_call_param.value.to_f, :float)
      end

      # Declare any var params
      env.declare_var(func_param.identifier, evaled_call_param, func_param.value_type, function.line, false)
    }
  end

  # Evaluates a hash literal expression.
  #
  # @param [HashLiteral] ast_node The hash literal to evaluate.
  # @param [Environment] env The environment to evaluate the expression in.
  # @return [HashVal] The result of the hash literal evaluation.
  def eval_hash_literal(ast_node, env)
    key_values = ast_node.key_value_pairs
    value_hash = {}

    key_values.map() { |pair| 
      key = evaluate(pair[:key], env)
      value = evaluate(pair[:value], env)
      # TODO check if correct for nested

      key = coerce_value_to_type(ast_node.key_type, key, ast_node.line)
      value = coerce_value_to_type(ast_node.value_type, value, ast_node.line)

      unless ast_node.value_type.is_a?(Array)
        # Check if the key type is correct
        raise "Line: #{ast_node.line}: Error: Hash expected key of type #{key.type} but got #{ast_node.key_type}" if key.type != ast_node.key_type
        raise "Line: #{ast_node.line}: Error: Hash expected value of type #{value.type} but got #{ast_node.value_type.to_s.gsub(',', ', ')}" if value.type != ast_node.value_type
      end
      value_hash[key.value] = value
    }
    # Build the hash type
    type = "Hash<#{ast_node.key_type},#{ast_node.value_type}>".to_sym

    return HashVal.new(value_hash, ast_node.key_type, ast_node.value_type, type)
  end

  # Evaluate a container accessor expression and return its value.
  #
  # @param ast_node [ContainerAccessor] the AST node representing the container accessor expression
  # @param env [Environment] the environment to evaluate the expression in
  # @return [RunTimeVal] the value of the container accessor expression
  # @raise [NameError] if the container identifier is not found in the environment
  #
  def eval_container_accessor(ast_node, env)
    container = evaluate(ast_node.identifier, env)
 
    unless container.is_a?(HashVal) || container.is_a?(ArrayVal)
      raise "Line: #{ast_node.line}: Error: Invalid type for container accessor, #{container.class}"
    end

    access_key = evaluate(ast_node.access_key, env).value

    if container.is_a?(ArrayVal)
      # Wrap around from the back if it is negative
      access_key = access_key % container.length.value if access_key.negative?

      if access_key >= container.length.value
        raise "Line:#{ast_node.line}: Error: index #{access_key} out of bounds for array of length #{container.length.value}"
      end
    end

    value = container.value[access_key]

    raise "Line: #{ast_node.line}: Error: Key: #{access_key} does not exist in container" if value.nil?
    return value ? value : NullVal.new()
  end

  #
  # Evaluates a creation of a class instance
  #
  # @param [ClassInstance] ast_node The ast node
  # @param [Environment] env The environment where the class instance is created
  #
  # @return [ClassVal] The class we wanted a instance of
  #
  def eval_class_instance(ast_node, env)
    class_instance = evaluate(ast_node.value, env).clone
    class_instance.create_instance(self)
    return ClassVal.new(ast_node.value.symbol, class_instance)
  end

  # Evaluates an array literal, ensuring that all elements have the correct type.
  #
  # @param ast_node [ArrayLiteral] The AST node representing the array literal.
  # @param env [Environment] The environment in which the array is being evaluated.
  # @return [ArrayVal] The resulting array value, with the appropriate type.
  # @raise [RuntimeError] If an element in the array has the wrong type and cannot be coerced.
  def eval_array_literal(ast_node, env)
    values = []

    ast_node.value.each() { |val|
      value = evaluate(val, env)
      values << coerce_value_to_type(ast_node.value_type, value, ast_node.line)
    }

    type = "#{ast_node.value_type}[]"
    
    return ArrayVal.new(values, type)
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
  
    if node_type == "int" && value.type == :float
      return value.to_int()
    elsif node_type == "float" && value.type == :int
      return value.to_float()
    end
  
    return value
  end
end