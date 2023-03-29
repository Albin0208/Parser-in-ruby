# frozen_string_literal: true

require_relative '../ast_nodes/ast'
require_relative '../lexer/lexer'
require_relative '../token_type'
require_relative '../errors/errors'

require 'logger'

#
# This is the parser which produces a AST from a list of tokens
#
class Parser
  #
  # Creates the parser
  #
  # @param [Boolean] logging If the parser should log to the terminal
  #
  def initialize(logging = false)
    @tokens = []
    @logging = logging

    @logger = Logger.new($stdout)
    @logger.level = logging ? Logger::DEBUG : Logger::FATAL
  end

  # Produce a AST from the sourceCode
  #
  # @param [String] source_code The string of code
  #
  # @return [Program] Return the top node in the AST
  def produce_ast(source_code)
    @tokens = Lexer.new(source_code, @logging).tokenize
    puts @tokens.map(&:to_s).inspect if @logging # Display the tokens list
    program = Program.new([])

    # Parse until end of file
    program.body.append(parse_stmt) while not_eof

    program
  end

  private

  # Parses a statement of different types
  #
  # @return [Stmt] The statement parsed as a AST node
  def parse_stmt
    case at.type
    when TokenType::CONST, TokenType::TYPE_SPECIFIER
      @logger.debug("(#{at.value}) matched var declaration")
      parse_var_declaration
    when TokenType::IF
      parse_conditional
    when TokenType::IDENTIFIER
      parse_assignment_stmt
    else
      parse_expr
    end
  end

  # Parse a variable declaration
  #
  # @return [VarDeclaration] The Vardeclaration AST node
  def parse_var_declaration
    is_const = at.type == TokenType::CONST # Get if const keyword is present

    eat() if is_const # eat the const keyword if we have a const
    type_specifier = eat().value # Get what type the var should be

    identifier = expect(TokenType::IDENTIFIER).value
    @logger.debug("Found indentifier from var declaration: #{identifier}")

    if at.type != TokenType::ASSIGN
      return VarDeclaration.new(is_const, identifier, type_specifier, nil) unless is_const

      @logger.error('Found Uninitialized constant')
      raise NameError, 'Uninitialized Constant. Constants must be initialize upon creation'
    end

    expect(TokenType::ASSIGN)
    expression = parse_expr

    validate_type(expression, type_specifier) # Validate that the type is correct

    VarDeclaration.new(is_const, identifier, type_specifier, expression)
  end

  # Validate that we are trying to assign a correct type to our variable.
  #
  # @param [Expr] expression The expression we want to validate
  # @param [String] type What type we are trying to assign to
  def validate_type(expression, type)
    if !expression.instance_variables.include?(:@value) && expression.type != NODE_TYPES[:Identifier]
      @logger.debug('Validating left side of expression')
      validate_type(expression.left, type)
      if expression.instance_variables.include?(:@right)
        @logger.debug('Validating right side of expression')
        validate_type(expression.left, type)
      end
      return # If we get here the type is correct
    end
    case type
    when 'int', 'float'
      # Make sure we either are assigning an integer or a variabel to the integer var
      if expression.type != NODE_TYPES[:NumericLiteral] && expression.type != NODE_TYPES[:Identifier]
        raise InvalidTokenError, "Can't assign none numeric value to value of type #{type}"
      end
    when 'bool'
      # Make sure we either are assigning a bool or a variabel to the bool var
      if expression.type != NODE_TYPES[:Boolean] && expression.type != NODE_TYPES[:Identifier]
        raise InvalidTokenError, "Can't assign none numeric value to value of type #{type}"
      end
    when 'string'
      # Make sure we either are assigning a string or a variabel to the string var
      if expression.type != NODE_TYPES[:String] && expression.type != NODE_TYPES[:Identifier]
        raise InvalidTokenError, "Can't assign none string value to value of type #{type}"
      end
    end
  end

  # Parses conditional statments such as if, else if and else
  #
  # @return [IfStatement] The If statement AST node
  def parse_conditional
    expect(TokenType::IF) # eat the if token

    conditions = nil
    while at.type != TokenType::LBRACE # Parse the conditions of the if statment
      conditions = parse_logical_expr # Add the condition expr to the conditions array
    end
    expect(TokenType::LBRACE) # ea) lbrace token
    # TODO Parse else if

    body = []
    body.append(parse_stmt) while at.type != TokenType::RBRACE # Parse the content of teh if statment
    expect(TokenType::RBRACE) # eat the rbrace token

    else_body = nil
    if at.type == TokenType::ELSE
      else_body = []
      eat() # eat the Else token
      expect(TokenType::LBRACE) # eat lbrace token
      while at.type != TokenType::RBRACE # Parse the conditions of the if statment
        else_body.append(parse_stmt) # Add the condition expr to the conditions array
      end
      expect(TokenType::RBRACE)
    end

    IfStatement.new(body, conditions, else_body)
  end

  # Parses a assignment statement
  #
  # @return [AssignmentExpr] The AST node
  def parse_assignment_stmt
    @logger.debug('Parsing assign expression')
    identifier = parse_identifier

    # Check if we have an assignment token
    if at().type == TokenType::ASSIGN
      expect(TokenType::ASSIGN)
      value = parse_expr # Parse the right side
      return AssignmentExpr.new(value, identifier)
    end

    return identifier
  end

  # Parses a expression
  #
  # @return [Stmt] The AST node matched
  def parse_expr
    # case at().type
    # else
    parse_logical_expr
    # end
  end

  # Orders of Precedence (Lowests to highest)
  # AssignmentExpr
  # MemberExpr
  # FunctionCall
  # Logical
  # Comparison
  # AdditiveExpr
  # MultiplyExpr
  # UnaryExpr
  # PrimaryExpr

  # Parses a logical expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_logical_expr
    left = parse_logical_and_expr

    # Check for logical or
    while at.value == :"||"
      eat().value # eat the operator
      right = parse_logical_and_expr
      left = LogicalOrExpr.new(left, right)
    end

    left
  end

  # Parses a logical expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_logical_and_expr
    left = parse_comparison_expr

    # Check for logical and
    while at.value == :"&&"
      eat().value # eat the operator
      right = parse_comparison_expr()
      left = LogicalAndExpr.new(left, right)
    end

    left
  end

  # Parses a comparison expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_comparison_expr
    left = parse_additive_expr()

    while LOGICCOMPARISON.include?(at.value)
      comparetor = eat().value # eat the comparetor
      right = parse_additive_expr()
      left = BinaryExpr.new(left, comparetor, right)
    end

    left
  end

  # Parses a additive expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_additive_expr
    left = parse_multiplication_expr()

    while ADD_OPS.include?(at.value)
      operator = eat().value # eat the operator
      right = parse_multiplication_expr()
      left = BinaryExpr.new(left, operator, right)
    end

    left
  end

  # Parses a multiplication expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_multiplication_expr
    left = parse_unary_expr()

    while MULT_OPS.include?(at.value)
      operator = eat().value # eat the operator
      right = parse_unary_expr()
      left = BinaryExpr.new(left, operator, right)
    end

    left
  end

  # Parses a unary expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_unary_expr
    # while %i[- + !].include?(at.value)
    if %i[- + !].include?(at.value)
      operator = eat().value # eat the operator
      right = parse_primary_expr()
      return UnaryExpr.new(right, operator)
    end

    return parse_primary_expr()
  end

  # Parses a primary expression.
  # This is the smallest part of the expr, such as numbers and so on
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_primary_expr
    tok = at().type
    case tok
    when TokenType::IDENTIFIER
      return parse_identifier()
    when TokenType::INTEGER
      return NumericLiteral.new(expect(TokenType::INTEGER).value.to_i)
    when TokenType::FLOAT
      return NumericLiteral.new(expect(TokenType::FLOAT).value.to_f)
    when TokenType::BOOLEAN
      return BooleanLiteral.new(eat().value == "true")
    when TokenType::STRING
      return StringLiteral.new(expect(TokenType::STRING).value.to_s)
    when TokenType::LPAREN
      expect(TokenType::LPAREN) # Eat opening paren
      value = parse_expr()
      expect(TokenType::RPAREN) # Eat closing paren
      return value
    when TokenType::NULL
      expect(TokenType::NULL)
      return NullLiteral.new()
    else
      raise InvalidTokenError.new("Unexpected token found: #{at()}")
    end
  end

  # Parse a identifier and create a new identifier node
  # @return [Identifier] - The identifier node created
  def parse_identifier
    id = expect(TokenType::IDENTIFIER) # Make sure we have a identifer
    @logger.debug("Found identifer: #{id.value}")
    return Identifier.new(id.value)
  end

  ##################################################
  # 				Helper functions				 #
  ##################################################

  # Check if we are not at the end of file
  #
  # @return [Boolean] Return of we are at the end of file or not
  def not_eof
    return at().type != TokenType::EOF
  end

  # Get what token we are at
  #
  # @return [Token] What token we have right now
  def at
    return @tokens[0]
  end

  # Eat the next token
  #
  # @return [Token] The token eaten
  def eat
    @logger.debug("Eating token: #{at()}")
    return @tokens.shift()
  end

  # Eat the next token and make sure we have eaten the correct type
  #
  # @param [String] token_type What type of token we are expecting
  #
  # @return [Token] Returns the expected token
  def expect(token_type)
    prev = eat()
    raise "Parse error: Expected #{token_type} but got #{prev.type}" if !prev || prev.type != token_type

    return prev
  end
end