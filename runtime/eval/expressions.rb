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
  #puts ast_node.func_name
  #p env.variables.keys
  #puts env.variables.key?(ast_node.func_name)
  last_eval = NullVal.new
  body = env.lookup_var(ast_node.func_name.symbol)
  body.each() { |stmt| last_eval = evaluate(stmt, env)}

  return last_eval
end