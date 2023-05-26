module Runtime
	#
  # The ControlFlowEvaluator module provides evaluation methods for control flow nodes.
  #
	module ControlFlowEvaluator
		private
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

		# Evaluates a break statement AST node.
    #
    # @param ast_node [ASTNode] The break statement AST node.
    # @param env [Environment] The environment.
    # @raise [BreakSignal] A signal to break out of the current loop.
    def eval_break_stmt(ast_node, env)
      raise BreakSignal
    end

    # Evaluates a continue statement AST node.
    #
    # @param ast_node [ASTNode] The continue statement AST node.
    # @param env [Environment] The environment.
    # @raise [ContinueSignal] A signal to continue to the next iteration of the current loop.
    def eval_continue_stmt(ast_node, env)
      raise ContinueSignal
    end
	end
end