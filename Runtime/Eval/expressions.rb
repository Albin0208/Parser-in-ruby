require_relative '../Enviroment.rb'
require_relative '../Interpreter.rb'
require_relative '../../AST_nodes/ast.rb'

def eval_identifier(astNode, env)
    val = env.lookupVar(astNode.symbol)
    return val
end

def eval_logical_and_expr(binop, env)
    lhs = evaluate(binop.left, env)
    return BooleanVal.new(false) unless lhs.value == true # Don't eval right side if we are false

    rhs = evaluate(binop.right, env)
    # We have come here so we know the expr is true if the right side is true
    return BooleanVal.new(rhs.value == true)
end

def eval_logical_or_expr(binop, env)
    lhs = evaluate(binop.left, env)
    rhs = evaluate(binop.right, env)

    return BooleanVal.new(lhs.value == true ||rhs.value == true)
end

def eval_unary_expr(binop, env)
    lhs = evaluate(binop.left, env)
    case binop.op
    when :-
        return NumberVal.new(-lhs.value)
    when :+
        return NumberVal.new(+lhs.value)
    end
end

def eval_binary_expr(binop, env)
    lhs = evaluate(binop.left, env)
    rhs = evaluate(binop.right, env)

    return lhs.send(binop.op, rhs)
end

def eval_assignment_expr(astNode, env)
    if astNode.assigne.type != NODE_TYPES[:Identifier]
        raise "Cannot assign to none Identifier type"
    end

    return env.assignVar(astNode.assigne.symbol, evaluate(astNode.value, env))
end