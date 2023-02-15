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

class MissingParenthesisError < StandardError
    def initialize(message)
        super(message)
    end
end