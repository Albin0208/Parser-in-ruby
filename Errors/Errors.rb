class InvalidTokenError < StandardError
    def initialize(message)
        super(message)
    end
end

class EndOfInputError < StandardError
    def initialize(message)
        super(message)
    end
end

class UnmatchedParenthesisError < StandardError
    def initialize(message)
        super(message)
    end
end