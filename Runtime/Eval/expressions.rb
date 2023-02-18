require_relative '../Enviroment.rb'
require_relative '../Interpreter.rb'

def eval_identifier(astNode, env)
    val = env.lookupVar(astNode.symbol)
    return val
end

def eval_logical_and_expr(binop, env)
    lhs = evaluate(binop.left, env)
    rhs = evaluate(binop.right, env)

    return lhs && rhs
end

def eval_binary_expr(binop, env)
    lhs = evaluate(binop.left, env)
    rhs = evaluate(binop.right, env)

    return lhs.send(binop.op, rhs)

    # if lhs.type == "number" and rhs.type == "number"
    #     return eval_numeric_binary_expr(lhs, binop.op, rhs)
    # end

    # return "nil"
end

def eval_assignment_expr(astNode, env)
    if astNode.assigne.type == TokenType::IDENTIFIER
        raise "Cannot assign to none Identifier type"
    end

    return env.assignVar(astNode.assigne.symbol, evaluate(astNode.value, env))
end

# def eval_numeric_binary_expr(lhs, operator, rhs)
#     return NumberVal.new(lhs.value.send(operator, rhs.value))
# end