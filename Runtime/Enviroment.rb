require 'set'

class Enviroment
    attr_accessor :variables, :constants
    def initialize(parentEnv = nil)
        @parentEnv = parentEnv
        @variables = Hash.new()
        @constants = Set.new()
    end

    def declareVar(varname, value, is_constant = false)
        if @variables.has_key?(varname)
            # TODO Create a better error
            raise "Cannot declare \"#{varname}\" as it is already defined"
        end

        @variables[varname] = value
        @constants.add(varname) unless not is_constant
        return value
    end

    def assignVar(varname, value)
        env = resolve(varname)
        if env.constants.include?(varname)
            # TODO Create better error
            raise "Cannot reassign constant variable \"#{varname}\""
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