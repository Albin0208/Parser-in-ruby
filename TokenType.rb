# All the different token types available
class TokenType
	INTEGER = :INTEGER
	FLOAT = :FLOAT
	VAR = :VAR
	CONST = :CONST
	FUNC = :FUNC
	IF = :IF
	THEN = :THEN
	COMMA = :COMMA
	ENDSTMT = :ENDSTMT
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

LOGICCOMPARISON = [:<, :>, :>=, :==, :!=].freeze
ADD_OPS =  [:+, :-].freeze
MULT_OPS = [:*, :/, :%].freeze