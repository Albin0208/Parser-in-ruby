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
    program.body.append(parse_stmt()) while not_eof()

    return program
  end

  private

  # Parses a statement of different types
  #
  # @return [Stmt] The statement parsed as a AST node
  def parse_stmt
    case at().type
    when TokenType::CONST, TokenType::TYPE_SPECIFIER
      @logger.debug("(#{at.value}) matched var declaration")
      return parse_var_declaration()
    when TokenType::IF
      return parse_conditional()
    when TokenType::IDENTIFIER
      if next_token().type == TokenType::LPAREN
        left = parse_func_call()
        if at().type == TokenType::BINARYOPERATOR
          op = eat().value
          right = parse_expr()
          return BinaryExpr.new(left, op, right)
        end
        return left
      elsif next_token().type == TokenType::BINARYOPERATOR
        return parse_expr()
      else
        return parse_assignment_stmt()
      end
    when TokenType::FUNC
      return parse_function_declaration()
    else
      return parse_expr()
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
    expression = parse_func_call_with_binary_operation()
        
    validate_assignment_type(expression, type_specifier) # Validate that the type is correct

    return VarDeclaration.new(is_const, identifier, type_specifier, expression)
  end

  def parse_func_call_with_binary_operation
    if at().type == TokenType::IDENTIFIER && next_token().type == TokenType::LPAREN
      expression = parse_func_call()
      if at().type == TokenType::BINARYOPERATOR
        op = eat().value
        right = parse_expr()
        return BinaryExpr.new(expression, op, right)
      end
    end
    return parse_expr()
  end

  # Validate that we are trying to assign a correct type to our variable.
  #
  # @param [Expr] expression The expression we want to validate
  # @param [String] type What type we are trying to assign to
  def validate_assignment_type(expression, type)
    return if expression.type == NODE_TYPES[:Identifier] # The expr is a identifier we can't tell what type from the parser

    if !expression.instance_variables.include?(:@value)
      @logger.debug("Validating #{type} variable assignment")
      if expression.type != NODE_TYPES[:CallExpr]
        validate_assignment_type(expression.left, type)
        validate_assignment_type(expression.right, type) if expression.instance_variables.include?(:@right)
      end
      return
    end

    unless valid_assignment_type?(expression.type, type)
      raise InvalidTokenError, "Can't assign #{expression.type.downcase} value to value of type #{type}"
    end
  end

  # Checks whether a given expression type is valid for a variable of a certain type.
  #
  # @param type [String] The type of the variable being assigned
  # @param type [String] The type of the expression being assigned
  #
  # @return [Boolean] true if the expression type is valid for the variable type otherwise false
  def valid_assignment_type?(expression_type, type)
    return case type
          when 'int', 'float'
            [NODE_TYPES[:NumericLiteral], NODE_TYPES[:Identifier]].include?(expression_type)
          when 'bool'
            [NODE_TYPES[:Boolean], NODE_TYPES[:Identifier]].include?(expression_type)
          when 'string'
            [NODE_TYPES[:String], NODE_TYPES[:Identifier]].include?(expression_type)
          else
            false
          end
  end

  #
  # Parse a function declaration
  #
  # @return [FuncDeclaration] The ast node representing a function
  #
  def parse_function_declaration
    expect(TokenType::FUNC) # Eat the func keyword

    return_type = nil
    if at().type == TokenType::VOID
      return_type = expect(TokenType::VOID).value
    else
      return_type = expect(TokenType::TYPE_SPECIFIER).value # Expect a type specificer for the function
    end

    identifier = expect(TokenType::IDENTIFIER).value # Expect a identifier for the func

    # Parse function parameters
    expect(TokenType::LPAREN)
    params = []
    if at().type != TokenType::RPAREN
      params << parse_var_declaration()
      while at().type == TokenType::COMMA
        expect(TokenType::COMMA)
        params << parse_var_declaration()
      end
    end
    expect(TokenType::RPAREN)

    expect(TokenType::LBRACE) # Start of function body
    return_stmt = nil
    body = []
    while at().type != TokenType::RBRACE && at().type != TokenType::RETURN
      stmt = parse_stmt()
      # Don't allow for function declaration inside a function
      raise "Error: A function declaration is not allowed inside another function" if stmt.type == NODE_TYPES[:FuncDeclaration]
      body.append(stmt) 
    end
    if return_type != 'void'
      # Parse return statement
      expect(TokenType::RETURN)
      return_body = []
      return_body.append(parse_expr()) while at().type != TokenType::RBRACE
      return_stmt = ReturnStmt.new(return_type, return_body)
    end
    expect(TokenType::RBRACE) # End of function body

    return FuncDeclaration.new(return_type, identifier, params, body, return_stmt)
  end

  # Parses conditional statments such as if, else if and else
  #
  # @return [IfStatement] The If statement AST node
  def parse_conditional
    expect(TokenType::IF) # eat the if token

    # Parse if condition and body
    if_condition = parse_conditional_condition()
    if_body = parse_conditional_body()

    # Parse else ifs
    elsif_stmts = []
    while at().type == TokenType::ELSIF
      expect(TokenType::ELSIF)

      # Parse elsif condtion and body
      elsif_condition = parse_conditional_condition()
      elsif_body = parse_conditional_body()

      elsif_stmts << ElsifStatement.new(elsif_body, elsif_condition)
    end

    else_body = nil
    if at.type == TokenType::ELSE
      expect(TokenType::ELSE) # eat the Else token
      expect(TokenType::LBRACE) # eat lbrace token
      else_body = parse_conditional_body()
    end

    return IfStatement.new(if_body, if_condition, else_body, elsif_stmts)
  end

  #
  # Parses the body of a conditional
  #
  # @return [Array] The list of all statments inside the body
  #
  def parse_conditional_body
    body = []
    body.append(parse_stmt()) while at().type != TokenType::RBRACE # Parse the content of the if statment
    expect(TokenType::RBRACE) # eat the rbrace token

    return body
  end

  #
  # Parses the condition of a if or elsif statement
  #
  # @return [Expr] The condition of the statment
  #
  def parse_conditional_condition
    condition = nil
    if at().type != TokenType::LBRACE
      condition = parse_logical_expr() 
    else
      # TODO Fix error message
      raise "Conditional statment requires a condition"
    end
    expect(TokenType::LBRACE) # eat lbrace token
    return condition
  end

  # Parses a assignment statement
  #
  # @return [AssignmentExpr] The AST node
  def parse_assignment_stmt
    @logger.debug('Parsing assign expression')
    identifier = parse_identifier()

    # Check if we have an assignment token
    if at().type == TokenType::ASSIGN
      expect(TokenType::ASSIGN)
      value = parse_func_call_with_binary_operation()
      return AssignmentExpr.new(value, identifier)
    end

    return identifier
  end

  # Parses a expression
  #
  # @return [Stmt] The AST node matched
  def parse_expr
    # return parse_func_call()
    if at().type == TokenType::IDENTIFIER && next_token().type == TokenType::LPAREN
      return parse_func_call()
    else
      return parse_logical_expr()
    end
  end

  #
  # Parses a function call
  #
  # @return [Expr] The function call
  #
  def parse_func_call
    identifier = parse_identifier() # Get the identifier
    expect(TokenType::LPAREN) # eat the start paren

    # Parse any params
    params = []
    if at().type != TokenType::RPAREN
      params << parse_expr()
      while at().type == TokenType::COMMA
        expect(TokenType::COMMA)
        params << parse_expr()
      end
    end

    expect(TokenType::RPAREN) # Find ending paren
    return CallExpr.new(identifier, params)
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
    left = parse_logical_and_expr()

    # Check for logical or
    while at.value == :"||"
      eat().value # eat the operator
      right = parse_logical_and_expr()
      left = LogicalOrExpr.new(left, right)
    end

    return left
  end

  # Parses a logical expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_logical_and_expr
    left = parse_comparison_expr()

    # Check for logical and
    while at.value == :"&&"
      eat().value # eat the operator
      right = parse_comparison_expr()
      left = LogicalAndExpr.new(left, right)
    end

    return left
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

    return left
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

    return left
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

    return left
  end

  # Parses a unary expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_unary_expr
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
    case at().type
    when TokenType::IDENTIFIER
      if next_token().type == TokenType::LPAREN
        return parse_func_call()
      end
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

  def next_token
    return @tokens[1]
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