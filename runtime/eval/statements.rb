require_relative '../enviroment'

def eval_program(program, env)
  last_eval = NullVal.new

  program.body.each { |stmt| last_eval = evaluate(stmt, env) }

  last_eval
end

def eval_var_declaration(ast_node, env)
  value = ast_node.value ? evaluate(ast_node.value, env) : NullVal.new

  unless value.instance_of?(NullVal)
    # Convert to correct data type for int and float calculations
    value = case ast_node.value_type
            when 'int' then NumberVal.new(value.value.to_i)
            when 'float' then NumberVal.new(value.value.to_f)
            else value
            end
  end

  env.declare_var(ast_node.identifier, value, ast_node.value_type, ast_node.constant)
end

def eval_if_statement(ast_node, env)
  last_eval = NullVal.new

  # Check if the conditions of the statement is evaled to true
  if evaluate(ast_node.conditions, env).value
    # TODO: Set up new env for if so vars die after if is done
    # Eval the body of the if
    ast_node.body.each { |stmt| last_eval = evaluate(stmt, env) }
  elsif !ast_node.else_body.nil?
    # Eval the body of the else
    ast_node.else_body.each { |stmt| last_eval = evaluate(stmt, env) }
  end

  last_eval
end
