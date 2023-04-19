# All the different token types available
class TokenType
  INTEGER = :INTEGER
  FLOAT = :FLOAT
  CONST = :CONST
  FUNC = :FUNC
  IF = :IF
  ELSIF = :ELSIF
  ELSE = :ELSE
  BOOLEAN = :BOOLEAN
  STRING = :STRING
  NULL = :NULL
  COMMA = :COMMA
  DOT = :DOT
  ASSIGN = :ASSIGN
  LOGICAL = :LOGICAL
  COMPARISON = :COMPARISON
  UNARYOPERATOR = :UNARYOPERATOR
  BINARYOPERATOR = :BINARYOPERATOR
  IDENTIFIER = :IDENTIFIER
  RESERVED = :RESERVED
  LPAREN = :LPAREN
  RPAREN = :RPAREN
  LBRACE = :LBRACE
  RBRACE = :RBRACE
  EOF = :EOF
  TYPE_SPECIFIER = :TYPE_SPECIFIER
  FUNC_CALL = :FUNC_CALL
  VOID = :VOID
  RETURN = :RETURN
  FOR = :FOR
  WHILE = :WHILE
end

LOGICCOMPARISON = %i[< > >= <= == !=].freeze
ADD_OPS =  %i[+ -].freeze
MULT_OPS = %i[* / %].freeze
