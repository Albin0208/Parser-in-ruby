class TokenType
	INTEGER = :INTEGER
	FLOAT = :FLOAT
	LET = :LET
	CONST = :CONST
	ASSIGN = :ASSIGN
	LOGICAL = :LOGICAL
	COMPARISON = :COMPARISON
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

LogicComparison = [:<, :>, :>=, :==, :!=]

LogicExpression = ["&&".to_sym, "||".to_sym]