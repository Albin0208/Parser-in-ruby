require_relative '../environment'
require_relative '../../ast_nodes/nodes'

module ExpressionsEvaluator

  def eval_identifier(ast_node, env)
    env.lookup_identifier(ast_node.symbol)
  end

  def eval_logical_and_expr(binop, env)
    lhs = evaluate(binop.left, env)
    return BooleanVal.new(false) unless lhs.value == true # Don't eval right side if we are false

    rhs = evaluate(binop.right, env)
    # We have come here so we know the expr is true if the right side is true
    BooleanVal.new(rhs.value == true)
  end

  def eval_logical_or_expr(binop, env)
    lhs = evaluate(binop.left, env)
    rhs = evaluate(binop.right, env)

    BooleanVal.new(lhs.value == true || rhs.value == true)
  end

  def eval_unary_expr(binop, env)
    lhs = evaluate(binop.left, env)
    case binop.op
    when :-
      return NumberVal.new(-lhs.value, lhs.type)
    when :+
      return NumberVal.new(-lhs.value, lhs.type)
    when :!
      BooleanVal.new(!lhs.value)
    end
  end

  def eval_binary_expr(binop, env)
    lhs = evaluate(binop.left, env)
    rhs = evaluate(binop.right, env)

    lhs.send(binop.op, rhs)
  end

  def eval_assignment_expr(ast_node, env)
    raise 'Cannot assign to none Identifier type' if ast_node.assigne.type != NODE_TYPES[:Identifier]

    env.assign_var(ast_node.assigne.symbol, evaluate(ast_node.value, env))
  end

  def eval_method_call_expr(ast_node, call_env)
    evaled_expr = evaluate(ast_node.expr, call_env)
    # TODO Fix another error message
    # Check if the method exists
    available_methods = evaled_expr.class.instance_methods() - Object.class.methods()
    unless available_methods.include?(ast_node.method_name.to_sym)
      raise "#{ast_node.method_name} is not defined in #{evaled_expr.class}"
    end
    # Grab the methods
    method = evaled_expr.method(ast_node.method_name)

    args = ast_node.params.map() { |param| evaluate(param, call_env)}

    return method.call(*args)
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
    function = call_env.lookup_identifier(ast_node.func_name.symbol)
    if function.instance_of?(Symbol) && function == :native_func
      param_results = ast_node.params.map() { |param| 
        evaled = evaluate(param, call_env)
        evaled.instance_variable_defined?(:@value) ? evaled.value : evaled }
      NativeFunctions.dispatch(ast_node.func_name.symbol, param_results)
      return nil
    end
    raise "Error: #{ast_node.func_name.symbol} is not a function" unless function.instance_of?(FuncDeclaration)

    env = Environment.new(function.env)
    validate_params(function, ast_node.params, call_env)
    declare_params(function, ast_node.params, call_env, env)

    return_value = nil
    begin
      function.body.each() { |stmt| evaluate(stmt, env) }
    rescue ReturnSignal => signal
      return_value = signal.return_node
    end

    # Check that the return value is the same type as the return type of the function
    expected_return_type = {'bool': :boolean}.fetch(function.type_specifier.to_sym, function.type_specifier.to_sym)
    return NullVal.new() if expected_return_type == :void
    unless return_value.type == expected_return_type
      raise "Error: function expected a return type of #{function.type_specifier} but got #{return_value.type}"
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
      raise "Error: Wrong number of arguments passed to function '#{function.type_specifier} #{function.identifier}(#{types})'. Expected '#{function.params.length}' but got '#{call_params.length}'"
    end

    function.params.zip(call_params) { |func_param, call_param| 
      # Grab the converter if it exits else convert to symbol
      type = NODE_TYPES_CONVERTER[func_param.value_type.to_sym] || func_param.value_type.to_sym
      evaled_call_param = evaluate(call_param, call_env)

      unless evaled_call_param.type.downcase == type.downcase
        raise "Error: Expected parameter '#{func_param.identifier}' to be of type '#{type}', but got '#{evaled_call_param.type}'"
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
      env.declare_var(func_param.identifier, evaled_call_param, func_param.value_type, false)
    }
  end

  def eval_hash_literal(ast_node, env)
    key_values = ast_node.key_value_pairs
    value_hash = {}

    key_values.map() { |pair| 
      key = evaluate(pair[:key], env)
      value = evaluate(pair[:value], env)

      # Check if the key type is correct
      # TODO Improve error message
      raise "Error: Key type is incorrect" if key.type != ast_node.key_type
      raise "Error: Value type is incorrect" if value.type != ast_node.value_type

      value_hash[key.value] = value
    }
    type = "Hash<#{ast_node.key_type},#{ast_node.value_type}>".to_sym

    return HashVal.new(value_hash, ast_node.key_type, ast_node.value_type, type)
  end

  def eval_container_accessor(ast_node, env)
    container = env.lookup_identifier(ast_node.identifier.symbol)
    access_key = evaluate(ast_node.access_key, env)
    value = container.value[access_key.value]
    return value ? value : NullVal.new()
  end
end