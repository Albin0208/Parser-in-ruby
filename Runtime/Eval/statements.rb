# require_relative '../Interpreter.rb'
require_relative '../Enviroment.rb'

def eval_program(program, env)
    last_eval = NullVal.new()

    program.body.each {|stmt| last_eval = evaluate(stmt, env)}

    return last_eval
end

def eval_var_declaration(astNode, env)
    value = astNode.value ? evaluate(astNode.value, env) : NullVal.new()
    
    if not value.instance_of?(NullVal)
        # Convert to correct data type for int and float calculations
        value = case astNode.value_type
                when "int" then NumberVal.new(value.value.to_i)
                when "float" then NumberVal.new(value.value.to_f)
                else value
        end
    end

    env.declareVar(astNode.identifier, value, astNode.constant, astNode.value_type)
end

def eval_if_statement(astNode, env)
    last_eval = NullVal.new()

    # Check if the conditions of the statement is evaled to true
    if evaluate(astNode.conditions, env).value
        # TODO Set up new env for if so vars die after if is done
        # Eval the body of the if
        astNode.body.each {|stmt| last_eval = evaluate(stmt, env)}
    elsif astNode.else_body != nil
        # Eval the body of the else
        astNode.else_body.each {|stmt| last_eval = evaluate(stmt, env)}
    end

    return last_eval
end