# Error raised when an invalid token is encountered during parsing.
class InvalidTokenError < StandardError
end

# Error raised when the end of input is reached unexpectedly during parsing.
class EndOfInputError < StandardError
end

# Error raised when there is an unmatched parenthesis during parsing.
class UnmatchedParenthesisError < StandardError
end

# Error raised when an invalid string is encountered during parsing.
class InvalidStringError < StandardError
end
