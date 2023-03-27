# frozen_string_literal: true

require 'set'

#
# The representation of an enviroment or scope
#
class Enviroment
  attr_accessor :variables, :constants, :var_types

  #
  # Creates a new enviroment
  #
  # @param [Enviroment] parent_env The parent enviroment if it exists
  #
  def initialize(parent_env: nil)
    @parent_env = parent_env
    @variables = {}
    @var_types = {}
    @constants = Set.new
  end

  #
  # Declare a new variable inside this enviroment
  #
  # @param [String] varname The name of the variable to be saved
  # @param [String, Int, Float, Boolean] value The value of the variable
  # @param [String] value_type What type is this var allowed to store
  # @param [Boolean] is_constant Is this var a constant variable
  #
  # @return [String, Int, Float, Boolean] The value assigned to the var
  #
  def declare_var(varname, value, value_type, is_constant = false)
    if @variables.key?(varname)
      # TODO: Create a better error
      raise "Cannot declare \"#{varname}\" as it is already defined"
    end

    @variables[varname] = value
    @var_types[varname] = value_type
    @constants.add(varname) if is_constant

    return value
  end

  #
  # Assign a new value to a variable
  #
  # @param [String] varname The name of the variable we want to assign to
  # @param [String, Int, Float, Boolean] value The value we want to assign
  #
  # @return [String, Int, Float, Boolean] The value we assigned
  #
  def assign_var(varname, value)
    env = resolve(varname)
    if env.constants.include?(varname)
      # TODO: Create better error
      raise "Cannot reassign constant variable \"#{varname}\""
    end

    # If the value is a number, try to convert it to int or float based on the variable type.
    # Otherwise, check if the value type matches the variable type.
    if value.type == :number
      value = case env.var_types[varname]
              when 'int' then NumberVal.new(value.value.to_i)
              when 'float' then NumberVal.new(value.value.to_f)
              end
    elsif value.type != env.var_types[varname]
      # Check if the value type matches the variable type.
      raise "Can't assign a value of type \"#{value.type}\" to a variable of type \"#{env.var_types[varname]}\"."
      # TODO: Create a more informative error message.
    end

    env.variables[varname] = value

    return value
  end

  #
  # Resolves a var name by finding what scope it exists in
  #
  # @param [String] varname The name of the variable
  #
  # @return [Enviroment] The enviroment that the var exists in
  #
  def resolve(varname)
    return self if @variables.key?(varname)

    # TODO: Create a better error
    raise "Cannot assign value to \"#{varname}\" since it is not defined" if @parent_env.nil?

    return @parent_env.resolve(varname)
  end

  #
  # Find the var name
  #
  # @param [String] varname The name of the variable
  #
  # @return [String, Int, Float, Boolean] The value of the var
  #
  def lookup_var(varname)
    env = resolve(varname)

    return env.variables[varname]
  end
end
