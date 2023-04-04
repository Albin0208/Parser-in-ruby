require_relative '../enviroment'
require_relative '../../ast_nodes/ast'

def eval_identifier(ast_node, env)
  env.lookup_var(ast_node.symbol)
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

def eval_call_expr(ast_node, env)
  function = env.lookup_var(ast_node.func_name.symbol)
  # Check that the correct number of params are passed
  unless function.params.length == ast_node.params.length
    types = []
    function.params.each() { |param| types << param.value_type}
    word = function.params.length < ast_node.params.length ? 'many' : 'few'
    params = types.join(', ')
    raise "Error: Too #{word} arguments to function \"#{function.type_specifier} #{function.identifier}(#{params})\". Expected \"#{function.params.length}\" but got \"#{ast_node.params.length}\""
  end

  # Check that all params are the correct type
  ast_node.params.each_with_index() { |param, index| 
    # Convert int and float to numericliteral
    type = function.params[0].value_type
    type = :NumericLiteral if ['int', 'float'].include?(type)

    unless param.type.downcase == type.downcase
      raise "Error: Missmatched parameter type. Got #{param.type.downcase} expected #{type.downcase}"
    end
  }

  # TODO Convert int passed to float and float passed to int
  # TODO declare var params inside function enviroment

  function.body.each() { |stmt| evaluate(stmt, env)}

  # Check that the return value is the same type as the return type of the function
  return_value = evaluate(function.return_stmt, env)

  type_matcher = {
    'int': :number,
    'float': :number,
    'bool': :boolean,
    'string': :boolean,
  }

  return_type = type_matcher[function.type_specifier.to_sym]
  unless return_value.type == return_type
    raise "Error: function expected a return type of #{function.type_specifier} but got #{return_value.type}"
  end

  return return_value
end