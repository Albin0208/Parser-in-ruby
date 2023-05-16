module Utilities
  # All the different token types available
  class TokenType
    ##########################
    #    Type Specifiers     #
    ##########################
    TYPE_SPECIFIER = :TYPE_SPECIFIER
    HASH_TYPE = :HASH_TYPE
    ARRAY_TYPE = :ARRAY_TYPE
    CLASS_TYPE = :CLASS_TYPE
    INTEGER = :INTEGER
    FLOAT = :FLOAT
    BOOLEAN = :BOOLEAN
    STRING = :STRING
    ##########################
    #   Control Statements   #
    ##########################
    IF = :IF
    ELSIF = :ELSIF
    ELSE = :ELSE
    FOR = :FOR
    WHILE = :WHILE
    BREAK = :BREAK
    CONTINUE = :CONTINUE
    ##########################
    #        Keywords        #
    ##########################
    CONST = :CONST
    FUNC = :FUNC
    NULL = :NULL
    VOID = :VOID
    RETURN = :RETURN
    HASH = :HASH
    IN = :IN
    CLASS = :CLASS
    CONSTRUCTOR = :CONSTRUCTOR
    ##########################
    #        Other        #
    ##########################
    COMMA = :COMMA
    DOT = :DOT
    ASSIGN = :ASSIGN
    LOGICAL = :LOGICAL
    COMPARISON = :COMPARISON
    UNARYOPERATOR = :UNARYOPERATOR
    BINARYOPERATOR = :BINARYOPERATOR
    IDENTIFIER = :IDENTIFIER
    LPAREN = :LPAREN
    RPAREN = :RPAREN
    LBRACE = :LBRACE
    RBRACE = :RBRACE
    LBRACKET = :LBRACKET
    RBRACKET = :RBRACKET
    EOF = :EOF
    NEW = :NEW
    FUNC_CALL = :FUNC_CALL
  end

  LOGICCOMPARISON = %i[< > >= <= == !=].freeze
  ADD_OPS =  %i[+ -].freeze
  MULT_OPS = %i[* / %].freeze
end