require_relative '../environment'

module Runtime
  #
  # StatementEvaluator defines a set of methods that can evaluate
  # different types of AST nodes representing statements in a programming language.
  #
  # The module includes methods for evaluating variable declarations, function declarations, control flow
  # statements such as if and while, and more.
  module StatementsEvaluator
    private

    # Evaluates the statements in the given program's body in the given environment.
    #
    # @param program [Nodes::Program] the program node to evaluate
    # @param env [Environment] the environment to use for evaluation
    # @return [RunTimeVal] the result of evaluating the last statement in the program's body
    def eval_program(program, env)
      last_eval = Values::NullVal.new

      program.body.each { |stmt| last_eval = evaluate(stmt, env) }

      return last_eval
    end

    # Evaluates a variable declaration AST node and declares the variable in the environment.
    #
    # @param ast_node [Nodes::VarDeclaration] The variable declaration AST node to evaluate.
    # @param env [Environment] The environment to declare the variable in.
    # @return [RunTimeVal] The evaluated value of the variable declaration.
    def eval_var_declaration(ast_node, env)
      value = ast_node.value ? evaluate(ast_node.value, env) : Values::NullVal.new

      env.declare_var(ast_node.identifier, value, ast_node.value_type, ast_node.line, ast_node.constant)
      return value
    end

    # Evaluates a hash declaration AST node and declares a new variable in the given environment.
    #
    # @param ast_node [Nodes::HashDeclaration] the hash declaration node to evaluate
    # @param env [Environment] the environment in which to declare the new variable
    #
    # @raise [RuntimeError] if the evaluated value is not a HashVal or if its key and value types do not match the expected types
    def eval_hash_declaration(ast_node, env)
      value = ast_node.value ? evaluate(ast_node.value, env) : Values::NullVal.new
      unless value.instance_of?(Values::NullVal)
        if value.class != Values::HashVal
          raise "Line: #{ast_node.line}: Error: #{ast_node.identifier} expected a hash of type: Hash<#{ast_node.key_type}, #{ast_node.value_type.to_s.gsub(',', ', ')}> but got #{value.class}"
        end
        # Check if key and value types match the type of the assigned hash
        if value.key_type != ast_node.key_type || value.value_type != ast_node.value_type
          raise "Line: #{ast_node.line}: Error: #{ast_node.identifier} expected a hash of type: Hash<#{ast_node.key_type}, #{ast_node.value_type.to_s.gsub(',', ', ')}> but got Hash<#{value.key_type}, #{value.value_type.to_s.gsub(',', ', ')}>"
        end
      end
      type_specifier = "Hash<#{ast_node.key_type},#{ast_node.value_type}>".to_sym

      env.declare_var(ast_node.identifier, value, type_specifier, ast_node.line, ast_node.constant)
    end

    # Evaluates a function declaration and adds it to the current environment.
    #
    # @param ast_node [Nodes::FuncDeclaration] The AST node representing the function declaration to be evaluated.
    # @param env [Environment] The current environment.
    #
    def eval_func_declaration(ast_node, env)
      env.declare_func(ast_node.identifier, ast_node.type_specifier, ast_node, env)
    end

    # Evaluates an array declaration AST node and assigns the resulting value to a variable in the given environment.
    #
    # @param ast_node [Nodes::ArrayDeclaration] the AST node representing the array declaration
    # @param env [Environment] the environment in which to assign the resulting value
    #
    # @raise [RuntimeError] if the resulting value is not an instance of `Values::ArrayVal`
    def eval_array_declaration(ast_node, env)
      value = ast_node.value ? evaluate(ast_node.value, env) : Values::NullVal.new

      unless value.is_a?(Values::ArrayVal) || value.is_a?(Values::NullVal)
        raise "Line:#{value.line}: Error: Can't assign value of none array type to array"
      end

      env.declare_var(ast_node.identifier, value, ast_node.value_type, ast_node.line, ast_node.constant)
    end

    # Evaluates an if statement AST node
    #
    # @param ast_node [Nodes::IfStatement] the AST node to evaluate
    # @param env [Environment] the current execution environment
    # @return [RunTimeVal] the result of the last evaluated statement in the if statement
    def eval_if_statement(ast_node, env)
      last_eval = Values::NullVal.new

      # Check if the conditions of the statement is evaled to true
      if eval_condition(ast_node.conditions, env)
        # Set up new env for if so vars die after if is done
        if_env = Runtime::Environment.new(env)
        # Eval the body of the if
        ast_node.body.each { |stmt| last_eval = evaluate(stmt, if_env) }
        return last_eval
      end
      ast_node.elsif_stmts&.each do |elsif_stmt|
        if eval_condition(elsif_stmt.conditions, env)
          # Set up new env for if so vars die after if is done
          elsif_env = Runtime::Environment.new(env)
          elsif_stmt.body.each { |stmt| last_eval = evaluate(stmt, elsif_env) }
          return last_eval
        end
      end
      unless ast_node.else_body.nil?
        # Set up new env for if so vars die after if is done
        else_env = Runtime::Environment.new(env)
        # Eval the body of the else
        ast_node.else_body.each { |stmt| last_eval = evaluate(stmt, else_env) }
      end

      return last_eval
    end

    # Evaluate a return statement by evaluating its body expression and raising a ReturnSignal
    # with the resulting value to indicate that a return statement has been encountered.
    #
    # @param ast_node [Nodes::ReturnStmt] The AST node representing the return statement
    # @param env [Environment] The environment in which the statement is being evaluated
    #
    # @raise [ReturnSignal] The raised signal contains the value of the last evaluated expression
    #   and is caught by the calling function to return this value from the current function.
    def eval_return_stmt(ast_node, env)
      result = evaluate(ast_node.body, env)
      raise ReturnSignal, result
    end

    #
    # Evaluate a while statement
    #
    # @param [Nodes::WhileStmt] ast_node The while statement
    # @param [Environment] env The current environment
    #
    # @return [RuntimeVal] The result of the evaluation
    #
    def eval_while_stmt(ast_node, env)
      last_eval = Values::NullVal.new
      while eval_condition(ast_node.conditions, env)
        while_env = Runtime::Environment.new(env) # Setup a new environment for the while loop
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
    # @param [Nodes::ForStmt] ast_node The for statement
    # @param [Environment] env The current environment
    #
    # @return [RuntimeVal] The result of the evaluation
    #
    def eval_for_stmt(ast_node, env)
      last_eval = Values::NullVal.new
      cond_env = Runtime::Environment.new(env)
      evaluate(ast_node.var_dec, cond_env)
      while eval_condition(ast_node.condition, cond_env)
        for_env = Runtime::Environment.new(cond_env) # Setup a new environment for the while loop
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

    # Evaluates a for-each loop statement in the given environment.
    #
    # @param ast_node [Nodes::ForEachStmt] The AST node representing the for-each loop statement.
    # @param env [Environment] The environment in which to evaluate the statement.
    # @return [RunTimeVal] The result of evaluating the last statement in the loop body, or NullVal if the body was empty.
    def eval_for_each_stmt(ast_node, env)
      last_eval = Values::NullVal.new
      container = evaluate(ast_node.container, env)
      value_type = container.value_type.to_s.gsub('[]', '')

      unless container.is_a?(Values::ArrayVal)
        raise "Line:#{ast_node.line}: Error: For-loop expected #{ast_node.container} to be of type Array but got #{container.type}"
      end

      container.value.each() do |item|
        loop_env = Runtime::Environment.new(env)
        case item
        when String
          item = Values::StringVal.new(item)
        when Integer
          item = Values::NumberVal.new(item, :int)
        when Float
          item = Values::NumberVal.new(item, :float)
        when TrueClass, FalseClass
          item = Values::BooleanVal.new(item)
        end

        loop_env.declare_var(ast_node.identifier.symbol, item, value_type, ast_node.line)
        begin
          ast_node.body.each { |stmt| last_eval = evaluate(stmt, loop_env) }
        rescue BreakSignal
          break
        rescue ContinueSignal
        end
      end

      return last_eval
    end

    #
    # Evaluates a condition, For example for a if statement
    #
    # @param [Nodes::Expr, Nodes::NullLiteral] condition The condition to be evaluated
    # @param [Environment] env The current environment
    #
    # @return [Boolean] True or false depinding on the result of the condition
    #
    def eval_condition(condition, env)
      evaled_condition = evaluate(condition, env)

      return false if evaled_condition.instance_of?(Values::NullVal)

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
end
