require 'set'

class Enviroment
    attr_accessor :variables, :constants, :var_types
    def initialize(parentEnv = nil)
        @parentEnv = parentEnv
        @variables = Hash.new()
        @var_types = Hash.new()
        @constants = Set.new()
    end

    def declareVar(varname, value, is_constant = false, value_type)
        if @variables.has_key?(varname)
            # TODO Create a better error
            raise RuntimeError, "Cannot declare \"#{varname}\" as it is already defined"
        end

        @variables[varname] = value
        @var_types[varname] = value_type
        @constants.add(varname) unless not is_constant
        
        return value
    end

    def assignVar(varname, value)
        env = resolve(varname)
        if env.constants.include?(varname)
            # TODO Create better error
            raise RuntimeError, "Cannot reassign constant variable \"#{varname}\""
        end

        # If the value is a number, try to convert it to int or float based on the variable type.
        # Otherwise, check if the value type matches the variable type.
        if value.type == :number
            value = case env.var_types[varname]
                    when "int" then NumberVal.new(value.value.to_i())
                    when "float" then  NumberVal.new(value.value.to_f())
                    end
        else
            # Check if the value type matches the variable type.
            if value.type != env.var_types[varname]
            # TODO: Create a more informative error message.
            raise RuntimeError, "Can't assign a value of type \"#{value.type}\" to a variable of type \"#{env.var_types[varname]}\"."
            end
        end

        env.variables[varname] = value

        return value
    end

    def resolve(varname)
        if @variables.has_key?(varname)
            return self
        end

        # TODO Create a better error
        raise "Cannot assign value to \"#{varname}\" since it is not defined" unless @parentEnv != nil

        return @parentEnv.resolve(varname)
    end

    def lookupVar(varname)
        env = resolve(varname)

        return env.variables[varname]
    end
end