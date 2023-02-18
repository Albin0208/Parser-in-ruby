require_relative '../Interpreter.rb'
require_relative '../Enviroment.rb'

def eval_program(program, env)
    last_eval = "nil"

    program.body.each {|stmt| last_eval = evaluate(stmt, env)}

    return last_eval
end

def eval_var_declaration(astNode, env)
    value = astNode.value ? evaluate(astNode.value, env) : NullVal.new()
    env.declareVar(astNode.identifier, value, astNode.constant)
end
