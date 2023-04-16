require_relative '../environment'
require_relative '../../ast_nodes/ast'

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
    NumberVal.new(-lhs.value)
  when :+
    NumberVal.new(+lhs.value)
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

def eval_call_expr(ast_node, call_env)
  function = call_env.lookup_identifier(ast_node.func_name.symbol)

  raise "Error: #{ast_node.func_name.symbol} is not a function" unless function.instance_of?(FuncDeclaration)

  env = Environment.new(function.env)
  # Check that the correct number of params are passed
  if function.params.length != ast_node.params.length
    types = function.params.map(&:value_type).join(", ")
    raise "Error: Wrong number of arguments passed to function '#{function.type_specifier} #{function.identifier}(#{types})'. Expected '#{function.params.length}' but got '#{ast_node.params.length}'"
  end

  # Check that all params are the correct type
  function.params.zip(ast_node.params) { |func_param, call_param| 
    # Get the node_type of the value
    type = NODE_TYPES_CONVERTER[func_param.value_type.to_sym]

    evaled_call_param = evaluate(call_param, call_env)

    if evaled_call_param.type.downcase != type.downcase
      raise "Error: Expected parameter '#{func_param.identifier}' to be of type '#{type}', but got '#{evaled_call_param.type}'"
    end

    # Convert int passed to float and float passed to int
    case func_param.value_type
    when 'int'
      evaled_call_param = NumberVal.new(evaled_call_param.value.to_i)
    when 'float'
      evaled_call_param = NumberVal.new(evaled_call_param.value.to_f)
    end

    # Declare any var params
    env.declare_var(func_param.identifier, evaled_call_param, func_param.value_type, false)
  }

  last_eval = NullVal.new()
  return_value = nil
  begin
    function.body.each() { |stmt| last_eval = evaluate(stmt, env) }
  rescue ReturnSignal => signal
    return_value = signal.return_node
  end

  # Check that the return value is the same type as the return type of the function
  return_type = { 'int': :number, 'float': :number, 'bool': :boolean, 'string': :boolean }[function.type_specifier.to_sym]
  unless return_value.type == return_type
    raise "Error: function expected a return type of #{function.type_specifier} but got #{return_value.type}"
  end

  return return_value
end