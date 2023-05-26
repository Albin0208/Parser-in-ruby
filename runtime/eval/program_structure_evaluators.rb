module Runtime
	#
  # The ProgramStructureEvaluators module provides evaluation methods for program structure nodes.
  #
	module ProgramStructureEvaluators
		private
    #
    # Evaluates a creation of a class instance
    #
    # @param [Nodes::ClassInstance] ast_node The ast node
    # @param [Environment] env The environment where the class instance is created
    #
    # @return [ClassVal] The class we wanted a instance of
    #
    def eval_class_instance(ast_node, env)
      class_instance = evaluate(ast_node.value, env).clone
      class_instance.create_instance(self)

      # Eval the constructor if it exists
      unless class_instance.constructors.empty?
        eval_constructor(class_instance, ast_node.params, class_instance.instance_env, env)
      end
      return Values::ClassVal.new(ast_node.value.symbol, class_instance)
    end

    # Evaluates a constructor with the given parameters in the context of the current instance environment and global environment.
    #
    # @param ast_node [Nodes::ClassDeclaration] an array of constructor statements
    # @param params [Array] an array of parameter values to be passed to the constructor
    # @param instance_env [Environment] the instance environment of the current object
    # @param env [Environment] the global environment
    #
    # @raise [RuntimeError] if the wrong number or types of parameters are passed to the constructor
    def eval_constructor(ast_node, params, instance_env, env)
      matching_ctor = nil
      ast_node.constructors.each do |ctor|
        begin
          if (ctor.params.empty? && params.empty?) || validate_params(ctor, params, env)
            matching_ctor = ctor
            break
          end
        rescue StandardError => e # Recover if the validate params fails
        end
      end

      # Throw error if we have not found a constructor
      if matching_ctor.nil?
        param_types = params.map() { |param| param.is_a?(Nodes::NumericLiteral) ? param.numeric_type : param.type }.join(', ')
        raise "Line:#{ast_node.line}: Error: no matching constructor for #{ast_node.class_name.symbol}::Constructor(#{param_types})"
      end

      ctor_env = Environment.new(instance_env)

      declare_params(matching_ctor, params, env, ctor_env) unless params.empty?

      matching_ctor.body.each() { |stmt| evaluate(stmt, ctor_env) }
    end

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

      unless value.instance_of?(Values::NullVal)
        # Convert to correct data type for int and float calculations
        value = case ast_node.value_type
                when 'int' then Values::NumberVal.new(value.value.to_i, :int)
                when 'float' then Values::NumberVal.new(value.value.to_f, :float)
                else value
                end
      end

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

    # Evaluates a class declaration AST node and declares the class in the given environment.
    #
    # @param ast_node [ClassDeclaration] The AST node representing the class declaration to evaluate.
    # @param env [Environment] The environment in which the class declaration should be evaluated.
    def eval_class_declaration(ast_node, env)
      env.declare_class(ast_node.class_name.symbol, ast_node, env)
    end

	end
end