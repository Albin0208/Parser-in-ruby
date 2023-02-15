class BinaryOperations
    attr_reader :lhs, :rhs

    def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs
    end

    def evaluate()
        raise NotImplementedError, "Subclasses must implement eveluate method"
    end 

    def to_s()
        return "#{@lhs} #{symbol} #{@rhs}"
    end

    def symbol()
        raise NotImplementedError, "Subclasses must implement symbol method"
    end
end

class Addition < BinaryOperations
    def evaluate()
        @lhs.evaluate + @rhs.evaluate
    end

    def symbol
        return "+"
    end
end

class Subtraction < BinaryOperations
    def evaluate()
        @lhs.evaluate - @rhs.evaluate
    end

    def symbol
        return "-"
    end
end

class Multiplication < BinaryOperations
    def evaluate()
        @lhs.evaluate * @rhs.evaluate
    end

    def symbol
        return "*"
    end
end

class Division < BinaryOperations
    def evaluate()
        @lhs.evaluate / @rhs.evaluate
    end

    def symbol
        return "/"
    end
end