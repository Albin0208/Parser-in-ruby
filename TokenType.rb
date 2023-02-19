# All the different token types available
class TokenType
	INTEGER = :INTEGER
	FLOAT = :FLOAT
	LET = :LET
	CONST = :CONST
	ASSIGN = :ASSIGN
	LOGICAL = :LOGICAL
	COMPARISON = :COMPARISON
	UNARYOPERATOR = :UNARYOPERATOR
	BINARYOPERATOR = :BINARYOPERATOR
	IDENTIFIER = :IDENTIFIER
	RESERVED = :RESERVED
	LPAREN = :LPAREN
	RPAREN = :RPAREN
	EOF = :EOF
end

class Operators
	PLUS = :+
	MINUS = :-
	MULTIPLY = :*
	DIVIDE = :/
end

LogicComparison = [:<, :>, :>=, :==, :!=].freeze
ADD_OPS =  [:+, :-].freeze
MULT_OPS = [:*, :/, :%].freeze