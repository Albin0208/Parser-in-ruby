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
  env = Environment.new(call_env)
  function = env.lookup_identifier(ast_node.func_name.symbol)
  # Check that the correct number of params are passed
  if function.params.length != ast_node.params.length
    types = function.params.map(&:value_type).join(", ")
    raise "Error: Wrong number of arguments passed to function '#{function.type_specifier} #{function.identifier}(#{types})'. Expected '#{function.params.length}' but got '#{ast_node.params.length}'"
  end

  # Check that all params are the correct type
  function.params.zip(ast_node.params) { |func_param, call_param| 
    # Convert int and float to numericliteral
    type = ['int', 'float'].include?(func_param.value_type) ? :NumericLiteral : func_param.value_type.to_sym

    if call_param.type.downcase != type.downcase
      raise "Error: Expected parameter '#{func_param.identifier}' to have type '#{type}', but got '#{call_param.type}'"
    end

    # Convert int passed to float and float passed to int
    case func_param.value_type
    when 'int'
      call_param.value = call_param.value.to_i
    when 'float'
      call_param.value = call_param.value.to_f
    end
  }

  # TODO declare var params inside function Environment

  function.body.each() { |stmt| evaluate(stmt, env)}

  # Check that the return value is the same type as the return type of the function
  return_value = evaluate(function.return_stmt, env)

  # Check return type
  return_type = { 'int': :number, 'float': :number, 'bool': :boolean, 'string': :boolean }[function.type_specifier.to_sym]
  unless return_value.type == return_type
    raise "Error: function expected a return type of #{function.type_specifier} but got #{return_value.type}"
  end

  return return_value
end