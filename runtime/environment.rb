require 'set'
require_relative '../runtime/native_functions.rb'

module Runtime
  #
  # The representation of an Environment or scope
  #
  class Environment
    attr_reader :identifiers, :constants, :identifiers_type, :parent_env, :global_env

    @@global_env = nil

    #
    # Creates a new environment
    #
    # @param [Environment] parent_env The parent Environment if it exists
    #
    def initialize(parent_env = nil)
      @parent_env = parent_env
      @identifiers = {}
      @identifiers_type = {}
      @constants = Set.new
    end

    #
    # Declares all the native functions in this scope
    #
    #
    def setup_native_functions
      raise "The native functions has already been setup in another scope: #{@@global_env}" unless @@global_env.nil?

      @@global_env = self
      NativeFunctions::FUNCTIONS.each() do |func_name|
                                          @constants.add(func_name)
                                          @identifiers[func_name] = :native_func
                                        end
    end

    #
    # Setter for @@global_env
    #
    # @param [Object] other What we want to assign
    #
    def global_env=(other)
      @@global_env = other
    end

    #
    # Declare a new variable inside this Environment
    #
    # @param [String] varname The name of the variable to be saved
    # @param [String, Int, Float, Boolean] value The value of the variable
    # @param [String] value_type What type is this var allowed to store
    # @param [Boolean] is_constant Is this var a constant variable
    #
    # @return [String, Int, Float, Boolean] The value assigned to the var
    #
    def declare_var(varname, value, value_type, line, is_constant = false)
      # Check if the variable is already declared in the current scope
      if find_scope(varname)
        raise "Line: #{line}: Cannot declare variable '#{varname}' since it is already defined in this scope"
      end

      if value.type != :null
        if value.type == :int && value_type == 'int'
          value = Values::NumberVal.new(value.value.to_i, :int)
        elsif value.type == :float && value_type == 'float'
          value = Values::NumberVal.new(value.value.to_f, :float)
        elsif value.type.to_sym != value_type.to_sym
          raise "Line: #{line}: Cannot assign a value of type \"#{value.type}\" to a variable of type \"#{value_type}\"."
        end
      end

      @identifiers[varname] = value
      @identifiers_type[varname] = value_type
      @constants.add(varname) if is_constant

      return value
    end

    #
    # Declare a new function inside this Environment
    #
    # @param [String] func_name The name of the function to be saved
    # @param [String] return_type What type is this function allowed to return
    # @param [FuncDeclaration] node The func declaration node
    # @param [Environment] env The parent environment of the funcation. Where the function is declared
    #
    # @return [String, Int, Float, Boolean] The value assigned to the var
    #
    def declare_func(func_name, return_type, node, env)
      # Check if the var is already declared in the current scope
      if find_scope(func_name)
        raise "Line: #{node.line}: Cannot declare function '#{func_name}' since it is already defined in this scope"
      end
      node.env = env

      @identifiers[func_name] = node
      @identifiers_type[func_name] = return_type
    end

    #
    # Declare a new class inside this Environment
    #
    # @param [String] class_name The name of the class
    # @param [ClassDeclaration] node The class node
    # @param [Environment] env The parent environment for the class
    #
    def declare_class(class_name, node, env)
      # Check if the class is Already declared
      if find_scope(class_name)
        raise "Line: #{node.line}: Cannot declare Class '#{class_name}' since it is already defined in this scope"
      end

      node.env = env
      @identifiers[class_name] = node
      @identifiers_type[class_name] = class_name
    end

    #
    # Assign a new value to a variable
    #
    # @param [String] varname The name of the variable we want to assign to
    # @param [String, Int, Float, Boolean] value The value we want to assign
    #
    # @return [String, Int, Float, Boolean] The value we assigned
    #
    def assign_var(varname, value, line)
      env = find_scope(varname)

      raise "Line: #{line}: Error: \"#{varname}\" was not declared in any scope" if env.nil?
      raise "Line: #{line}: Cannot reassign constant variable \"#{varname}\"" if env.constants.include?(varname)
      raise "Line: #{line}: Cannot assign a value to a function \"#{varname}\"" if is_function?(varname, env)

      var_type = env.identifiers_type[varname]

      if value.type == :int || value.type == :float
        case var_type
        when 'int'
          value = Values::NumberVal.new(value.value.to_i, :int)
        when 'float'
          value = Values::NumberVal.new(value.value.to_f, :float)
        end
      elsif value.type.to_sym != var_type.to_sym
        raise "Line: #{line}: Cannot assign a value of type \"#{value.type}\" to a variable of type \"#{var_type}\"."
      end

      env.identifiers[varname] = value

      return value
    end

    #
    # Find the value of the identifier
    #
    # @param [String] identifier The name of the identifier
    #
    # @return [String, Int, Float, Boolean] The value of the var
    #
    def lookup_identifier(identifier, line = nil)
      env = find_scope(identifier)

      raise "Line: #{line}: Error: \"#{identifier}\" was not declared in any scope" if env.nil?

      return env.identifiers[identifier]
    end

    #
    # Checks if the variable is a constant
    #
    # @param [String] identifier The name of the identifier
    #
    # @return [Boolean] If the var is constant or not
    #
    def is_constant?(identifier)
      env = find_scope(identifier)

      return env.constants.include?(identifier)
    end

    protected

    #
    # Resolves a identifier name by finding what scope it exists in
    #
    # @param [String] identifier The name of the identifier
    #
    # @return [Environment | nil] The environment that the identifier exists in or nil if it does not exist
    #
    def find_scope(identifier)
      return self if @identifiers.key?(identifier)

      return nil if @parent_env.nil?

      return @parent_env.find_scope(identifier)
    end

    private

    # Checks if the variable in the given environment is a function.
    #
    # @param varname [String] The name of the variable to check.
    # @param env [Environment] The environment to check for the variable.
    # @return [Boolean] Whether the variable is a function.
    def is_function?(varname, env)
      return env.identifiers.key?(varname) && env.identifiers[varname].type == NODE_TYPES[:FuncDeclaration]
    end
  end
end