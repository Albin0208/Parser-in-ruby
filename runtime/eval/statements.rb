require_relative '../environment'

#
# StatementEvaluator defines a set of methods that can evaluate
# different types of AST nodes representing statements in a programming language.
#
# The module includes methods for evaluating variable declarations, function declarations, control flow
# statements such as if and while, and more.
module StatementEvaluator

  # Evaluates the statements in the given program's body in the given environment.
  #
  # @param program [Program] the program node to evaluate
  # @param env [Environment] the environment to use for evaluation
  # @return [RunTimeVal] the result of evaluating the last statement in the program's body
  def eval_program(program, env)
    last_eval = NullVal.new

    program.body.each { |stmt| last_eval = evaluate(stmt, env) }

    return last_eval
  end

  # Evaluates a variable declaration AST node and declares the variable in the environment.
  #
  # @param ast_node [VarDeclaration] The variable declaration AST node to evaluate.
  # @param env [Environment] The environment to declare the variable in.
  # @return [RunTimeVal] The evaluated value of the variable declaration.
  def eval_var_declaration(ast_node, env)
    value = ast_node.value ? evaluate(ast_node.value, env) : NullVal.new

    unless value.instance_of?(NullVal)
      # Convert to correct data type for int and float calculations
      value = case ast_node.value_type
              when 'int' then NumberVal.new(value.value.to_i, :int)
              when 'float' then NumberVal.new(value.value.to_f, :float)
              else value
              end
    end

    env.declare_var(ast_node.identifier, value, ast_node.value_type, ast_node.constant)
    return value
  end

  # Evaluates a hash declaration AST node and declares a new variable in the given environment.
  #
  # @param ast_node [HashDeclaration] the hash declaration node to evaluate
  # @param env [Environment] the environment in which to declare the new variable
  # 
  # @raise [RuntimeError] if the evaluated value is not a HashVal or if its key and value types do not match the expected types
  def eval_hash_declaration(ast_node, env)
    value = ast_node.value ? evaluate(ast_node.value, env) : NullVal.new
    unless value.instance_of?(NullVal)
      raise "Error: #{ast_node.identifier} expected a hash of type: Hash<#{ast_node.key_type}, #{ast_node.value_type}> but got #{value.class}" if value.class != HashVal
      # Check if key and value types match the type of the assigned hash
      if value.key_type != ast_node.key_type || value.value_type != ast_node.value_type
        raise "Error: #{ast_node.identifier} expected a hash of type: Hash<#{ast_node.key_type}, #{ast_node.value_type}> but got Hash<#{value.key_type}, #{value.value_type}>"
      end
    end
    type_specifier = "Hash<#{ast_node.key_type},#{ast_node.value_type}>".to_sym

    env.declare_var(ast_node.identifier, value, type_specifier, ast_node.constant)
  end

  # Evaluates a function declaration and adds it to the current environment.
  #
  # @param ast_node [FuncDeclaration] The AST node representing the function declaration to be evaluated.
  # @param env [Environment] The current environment.
  #
  def eval_func_declaration(ast_node, env)
    env.declare_func(ast_node.identifier, ast_node.type_specifier, ast_node, env)
  end

  # Evaluates an if statement AST node
  #
  # @param ast_node [IfStatement] the AST node to evaluate
  # @param env [Environment] the current execution environment
  # @return [RunTimeVal] the result of the last evaluated statement in the if statement
  def eval_if_statement(ast_node, env)
    last_eval = NullVal.new

    # Check if the conditions of the statement is evaled to true
    if eval_condition(ast_node.conditions, env)
      # Set up new env for if so vars die after if is done
      if_env = Environment.new(env)
      # Eval the body of the if
      ast_node.body.each { |stmt| last_eval = evaluate(stmt, if_env) }
      return last_eval
    end
    if !ast_node.elsif_stmts.nil?
      ast_node.elsif_stmts.each do |stmt|
        if eval_condition(stmt.conditions, env)
          # Set up new env for if so vars die after if is done
          elsif_env = Environment.new(env)
          stmt.body.each { |stmt| last_eval = evaluate(stmt, elsif_env) }
          return last_eval
        end
      end
    end
    if !ast_node.else_body.nil?
      # Set up new env for if so vars die after if is done
      else_env = Environment.new(env)
      # Eval the body of the else
      ast_node.else_body.each { |stmt| last_eval = evaluate(stmt, else_env) }
    end

    return last_eval
  end

  # Evaluate a return statement by evaluating its body expression and raising a ReturnSignal
  # with the resulting value to indicate that a return statement has been encountered.
  #
  # @param ast_node [ReturnStmt] The AST node representing the return statement
  # @param env [Environment] The environment in which the statement is being evaluated
  #
  # @raise [ReturnSignal] The raised signal contains the value of the last evaluated expression
  #   and is caught by the calling function to return this value from the current function.
  def eval_return_stmt(ast_node, env)
    result = evaluate(ast_node.body, env) 
    raise ReturnSignal.new(result)
  end

  #
  # Evaluate a while statement
  #
  # @param [WhileStmt] ast_node The while statement
  # @param [Environment] env The current environment
  #
  # @return [RuntimeVal] The result of the evaluation
  #
  def eval_while_stmt(ast_node, env)
    last_eval = NullVal.new
    while eval_condition(ast_node.conditions, env)
      while_env = Environment.new(env) # Setup a new environment for the while loop
      begin
        ast_node.body.each { |stmt| last_eval = evaluate(stmt, while_env) }
      rescue BreakSignal
        break
      rescue ContinueSignal
        next
      end
    end

    return last_eval
  end

  #
  # Evaluate a for statement
  #
  # @param [ForStmt] ast_node The for statement
  # @param [Environment] env The current environment
  #
  # @return [RuntimeVal] The result of the evaluation
  #
  def eval_for_stmt(ast_node, env)
    last_eval = NullVal.new
    cond_env = Environment.new(env)
    evaluate(ast_node.var_dec, cond_env)
    while eval_condition(ast_node.condition, cond_env)
      for_env = Environment.new(cond_env) # Setup a new environment for the while loop
      begin
        ast_node.body.each { |stmt| last_eval = evaluate(stmt, for_env) }
        evaluate(ast_node.expr, cond_env)
      rescue BreakSignal
        break
      rescue ContinueSignal
        evaluate(ast_node.expr, cond_env)
      end
    end

    return last_eval
  end

  #
  # Evaluates a condition, For example for a if statement
  #
  # @param [Expr | NullLiteral] condition The condition to be evaluated
  # @param [Environment] env The current environment
  #
  # @return [Boolean] True or false depinding on the result of the condition
  #
  def eval_condition(condition, env)
    evaled_condition = evaluate(condition, env)

    if evaled_condition.instance_of?(NullVal)
      return false
    end
      return evaled_condition.value
  end

  # Evaluates a class declaration AST node and declares the class in the given environment.
  #
  # @param ast_node [ClassDeclaration] The AST node representing the class declaration to evaluate.
  # @param env [Environment] The environment in which the class declaration should be evaluated.
  def eval_class_declaration(ast_node, env)
    env.declare_class(ast_node.class_name.symbol, ast_node, env)
  end
end