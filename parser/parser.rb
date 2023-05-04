require_relative '../ast_nodes/nodes'
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
    @parsing_function = false # Flag to keep track of function parsing. Use for not allowing return outside functions
    @parsing_loop = false # Flag to keep track of loop parsing. Use for not allowing break and continue outside loops

    @location = 1 # used to display the line number where ther error is

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
    when TokenType::CONST, TokenType::TYPE_SPECIFIER, TokenType::HASH, TokenType::IDENTIFIER
      if at().type == TokenType::IDENTIFIER && next_token().type != TokenType::IDENTIFIER
        return parse_assignment_stmt()
      end
      return parse_var_declaration()
    when TokenType::IF
      return parse_if_statement()
    when TokenType::FOR, TokenType::WHILE
      return parse_loops()
    when TokenType::CLASS
      return parse_class_declaration()
    when TokenType::FUNC
      return parse_function_declaration()
    when TokenType::RETURN
      return parse_return()
    when TokenType::BREAK
      raise "Line:#{@location}: Error: Break cannot be used outside of loops" unless @parsing_loop
      expect(TokenType::BREAK)
      return BreakStmt.new()
    when TokenType::CONTINUE
      raise "Line:#{@location}: Error: Continue cannot be used outside of loops" unless @parsing_loop
      expect(TokenType::CONTINUE)
      return ContinueStmt.new()
    else
      return parse_expr()
    end
  end

  # Parses a class declaration and returns a ClassDeclaration AST node.
  #
  # @return [ClassDeclaration] The ClassDeclaration AST node.
  def parse_class_declaration 
    expect(TokenType::CLASS)

    class_name = parse_identifier()
    member_variables = []
    member_functions = []
    expect(TokenType::LBRACE)

    # Parse all class members
    while at().type != TokenType::RBRACE
      stmt = parse_stmt()

      # Check if the stmt is a func- or varDeclaration
      case stmt.type
      when :FuncDeclaration
        member_functions << stmt
      when :VarDeclaration, :HashDeclaration
        member_variables << stmt
      end
    end
    expect(TokenType::RBRACE)

    return ClassDeclaration.new(class_name, member_variables, member_functions)
  end

  #
  # Parse a hash declaration
  #
  # @param [Boolean] is_const If the current hash declaration is a const or not
  # @return [HashDeclaration] The hash
  #
  def parse_hash_declaration(is_const)
    key_type, value_type = parse_hash_type_specifier()

    identifier = parse_identifier().symbol

    if at().type != TokenType::ASSIGN
      return HashDeclaration.new(is_const, identifier, key_type.to_sym, value_type, nil) unless is_const

      @logger.error('Found Uninitialized constant')
      raise NameError, "Line:#{@location}: Error: Uninitialized Constant. Constants must be initialize upon creation"
    end

    expect(TokenType::ASSIGN)

    expression = nil
    if at().type == TokenType::IDENTIFIER
      expression = parse_expr()
    else # Else we want a hash literal
      expression = parse_hash_literal()
    end

    return HashDeclaration.new(is_const, identifier, key_type.to_sym, value_type, expression)
  end

  #
  # Parse an hash literal
  #
  # @return [HashLiteral] The hashliteral with all the key-value pairs
  #
  def parse_hash_literal
    key_type, value_type = parse_hash_type_specifier()

    expect(TokenType::LBRACE) # Get the opening brace
    key_value_pairs = []

    keys = [] # All keys found
    
    # Parse all key value pairs
    while at().type != TokenType::RBRACE
      key = parse_expr()

      # Check if key allready has been defined
      if key.type != NODE_TYPES[:Identifier] && keys.include?(key)
        raise "Line:#{@location}: Error: Key: '#{key}' already exists in hash"
      end
      validate_assignment_type(key, key_type) # Validate that the type is correct

      expect(TokenType::ASSIGN)
      value = parse_expr()

      #validate_assignment_type(value, value_type) # Validate that the type is correct
      key_value_pairs << { key: key, value: value} # Create a new pair

      keys << key # Add the key
      eat() if at().type == TokenType::COMMA # The comma token
    end

    expect(TokenType::RBRACE) # Get the closing brace

    return HashLiteral.new(key_value_pairs, key_type.to_sym, value_type)
  end

  #
  # Parses the hash_type specifier
  #
  # @return [String & String] The key and value types
  #
  def parse_hash_type_specifier
    expect(TokenType::HASH)

    hash_type = expect(TokenType::HASH_TYPE).value.to_s

    hash_type = hash_type.gsub(/[<>\s]|(Hash)/, '').split(',')
    hash_type = parse_nested_hash(hash_type)
    value_type = hash_type[1]
    if value_type.is_a?(Array)
      pretty_type = ""
      flatt_type = value_type.flatten
      flatt_type.flatten.each_with_index() { |type, index| 
        if index < flatt_type.flatten.length - 1
          pretty_type << "Hash<#{type}, "
        else
          pretty_type << "#{type}"
        end
      }
      pretty_type << '>' * (flatt_type.flatten.length - 1)
      value_type = pretty_type
    end

    return hash_type[0], value_type.to_sym
  end

  def parse_nested_hash(hash_type)
    if hash_type.length == 1
      return hash_type.first.to_sym
    end

    return [hash_type.shift.to_sym, parse_nested_hash(hash_type)]
  end

  #
  # Parse loops
  #
  # @return [Expr] The loop
  #
  def parse_loops
    case at().type
    when TokenType::FOR # Parse for statement
      return parse_for_stmt()
    when TokenType::WHILE # Parse while statement
      return parse_while_stmt()
    end
  end

  #
  # Parse a for-loop
  #
  # @return [ForStmt] The for statment
  #
  # @raise [RuntimeError] If the variable in the for-loop is not initialized.
  # @raise [RuntimeError] If the expression given is not an Expr or AssignmentStmt.
  #
  def parse_for_stmt
    @parsing_loop = true
    expect(TokenType::FOR)
    var_dec = parse_var_declaration()
    raise "Line:#{@location}: Error: Variable '#{var_dec.identifier}' has to be initialized in for-loop" if var_dec.value.nil?
    expect(TokenType::COMMA)
    condition = parse_conditional_condition() # Parse the loop condition
    expect(TokenType::COMMA)
    expr = parse_stmt()
    # Don't allow for every stmt, only assignstatement and expressions
    unless expr.is_a?(Expr) || expr.is_a?(AssignmentStmt)
      raise "Line:#{@location}: Error: Wrong type of expression given"
    end

    expect(TokenType::LBRACE)
    body = parse_conditional_body()
    expect(TokenType::RBRACE)

    @parsing_loop = false
    return ForStmt.new(body, condition, var_dec, expr)
  end

  # Parses a while loop statement.
  #
  # @return [WhileStmt] The WhileStmt AST node.
  #
  def parse_while_stmt
    @parsing_loop = true
    expect(TokenType::WHILE)
    condition = parse_conditional_condition() # Parse the loop condition

    # Parse the loop body
    expect(TokenType::LBRACE)
    body = parse_conditional_body()
    expect(TokenType::RBRACE)

    @parsing_loop = false
    return WhileStmt.new(body, condition)
  end

  #
  # Parses a identifier
  #
  # @return [Expr] An expression matching the tokens
  #
  def parse_identifier
    return Identifier.new(expect(TokenType::IDENTIFIER).value)
    
  end

  #
  # Parses a return statement
  #
  # @return [Return] The return statement with the expressions
  #
  def parse_return()
    raise "Line:#{@location}: Error: Unexpected return encountered. Returns are not allowed outside of functions" unless @parsing_function

    expect(TokenType::RETURN)
    expr = parse_expr()

    return ReturnStmt.new(expr)
  end

  # Parse a variable declaration
  #
  # @return [VarDeclaration] The Vardeclaration AST node
  #
  # @raise [NameError] If an uninitialized constant is found.
  def parse_var_declaration
    is_const = at().type == TokenType::CONST # Get if const keyword is present

    eat() if is_const # eat the const keyword if we have a const

    return parse_hash_declaration(is_const) if at().type == TokenType::HASH

    type_specifier = expect(TokenType::TYPE_SPECIFIER, TokenType::IDENTIFIER).value # Get what type the var should be

    identifier = parse_identifier().symbol
    
    if at().type != TokenType::ASSIGN
      return VarDeclaration.new(is_const, identifier, type_specifier, nil) unless is_const
      raise NameError, "Line:#{@location}: Error: Uninitialized Constant. Constants must be initialize upon creation"
    end

    expect(TokenType::ASSIGN)
    expression = parse_expr()

    validate_assignment_type(expression, type_specifier) # Validate that the type is correct

    return VarDeclaration.new(is_const, identifier, type_specifier, expression)
  end

  # Validate that we are trying to assign a correct type to our variable.
  #
  # @param [Expr] expression The expression we want to validate
  # @param [String] type What type we are trying to assign to
  def validate_assignment_type(expression, type)
    return unless [:NumericLiteral, :String, :Boolean, :HashLiteral].include?(expression.type) # We can't know what type will be given until runtime of it is a func call and so on

    if !expression.instance_variable_defined?(:@value)
      if expression.type != NODE_TYPES[:CallExpr]
        validate_assignment_type(expression.left, type)
        validate_assignment_type(expression.right, type) if expression.instance_variable_defined?(:@right)
      end
      return
    end
    if expression.instance_of?(ClassInstance)
      expression = expression.value.symbol
    else
      expression = expression.type
    end

    unless valid_assignment_type?(expression, type)
      raise InvalidTokenError, "Line:#{@location}: Error: Can't assign #{expression} value to value of type #{type}"
    end
  end

  # Checks whether a given expression type is valid for a variable of a certain type.
  #
  # @param expression_type [String] What type the expression is
  # @param expected_type [String] The expected type for the expression
  #
  # @return [Boolean] true if the expression type is valid for the variable type otherwise false
  def valid_assignment_type?(expression_type, expected_type)
    return case expected_type.to_sym
          when :int, :float
            [NODE_TYPES[:NumericLiteral], NODE_TYPES[:Identifier]].include?(expression_type)
          when :bool
            [NODE_TYPES[:Boolean], NODE_TYPES[:Identifier]].include?(expression_type)
          when :string
            [NODE_TYPES[:String], NODE_TYPES[:Identifier]].include?(expression_type)
          else
            expression_type.to_sym == expected_type.to_sym
          end
  end

  #
  # Parse a function declaration
  #
  # @return [FuncDeclaration] The ast node representing a function
  #
  def parse_function_declaration
    expect(TokenType::FUNC) # Eat the func keyword
    @parsing_function = true

    if at().type == TokenType::HASH
      return_type = "#{expect(TokenType::HASH).value}#{expect(TokenType::HASH_TYPE).value.to_s.delete(' ')}"
    else
      return_type = expect(TokenType::VOID, TokenType::TYPE_SPECIFIER, TokenType::IDENTIFIER, TokenType::HASH).value
    end

    identifier = expect(TokenType::IDENTIFIER).value # Expect a identifier for the func

    # Parse function parameters
    expect(TokenType::LPAREN)
    params = parse_function_params()
    expect(TokenType::RPAREN)

    expect(TokenType::LBRACE) # Start of function body
    body, has_return_stmt = parse_function_body()

    if return_type != 'void' && !has_return_stmt
      raise "Line:#{@location}: Error: Function of type: '#{return_type}' expects a return statment"
    end
    expect(TokenType::RBRACE) # End of function body
    @parsing_function = false
    return FuncDeclaration.new(return_type, identifier, params, body)
  end

  #
  # Parses a function body and gets if it has a return statement
  #
  # @return [Array & Boolean] Return the list of all statments and if the body has a return statment
  #
  def parse_function_body
    body = []
    has_return_stmt = false
    while at().type != TokenType::RBRACE
      stmt = parse_stmt()
      # Don't allow for function declaration inside a function
      raise "Line:#{@location}: Error: A function declaration is not allowed inside another function" if stmt.type == NODE_TYPES[:FuncDeclaration]
      
      has_return_stmt ||= has_return_statement?(stmt) # ||= Sets has_return to true if it is false and keeps it true even if has_return_statements returns false

      body << stmt
    end

    return body, has_return_stmt
  end

  #
  # Recursivly check if the statment has any return statments
  #
  # @param [Stmt] stmt The statement to check
  #
  # @return [Boolean] True if ReturnStmt exits otherwise false
  #
  def has_return_statement?(stmt)
    if stmt.instance_of?(ReturnStmt)
      return true
    elsif stmt.instance_variable_defined?(:@body)
      return stmt.body.any? { |s| has_return_statement?(s) }
    else
      return false
    end
  end

  #
  # Parses the functions params
  #
  # @return [Array] A list of all the params of the function
  #
  def parse_function_params
    params = []
    if at().type != TokenType::RPAREN
      params << parse_var_declaration()
      while at().type == TokenType::COMMA
        expect(TokenType::COMMA)
        params << parse_var_declaration()
      end
    end

    return params
  end

  # Parses conditional statments such as if, else if and else
  #
  # @return [IfStatement] The If statement AST node
  #
  def parse_if_statement
    expect(TokenType::IF) # eat the if token

    if_condition = parse_conditional_condition() # Parses the if condition
    expect(TokenType::LBRACE) # eat lbrace token
    if_body = parse_conditional_body() # parses the if body
    expect(TokenType::RBRACE) # eat the rbrace token

    elsif_stmts = parse_elsif_statements() # Parse else ifs
    else_body = parse_else_statement() # Parse Else

    return IfStatement.new(if_body, if_condition, else_body, elsif_stmts)
  end

  #
  # Parses all elsif statments
  #
  # @return [Array] A list of all the elsifs found
  #
  def parse_elsif_statements
    elsif_stmts = []
    while at().type == TokenType::ELSIF
      expect(TokenType::ELSIF)
      elsif_condition = parse_conditional_condition() # Parse elsif condition
      expect(TokenType::LBRACE) # eat lbrace token
      elsif_body = parse_conditional_body() # Parse elsif body
      expect(TokenType::RBRACE) # eat the rbrace token
      elsif_stmts << ElsifStatement.new(elsif_body, elsif_condition)
    end

    return elsif_stmts
  end

  #
  # Parses a else statment
  #
  # @return [Array] The list of all the staments inside the else
  #
  def parse_else_statement
    else_body = nil
    if at().type == TokenType::ELSE
      expect(TokenType::ELSE) # eat the Else token
      expect(TokenType::LBRACE) # eat lbrace token
      else_body = parse_conditional_body()
      expect(TokenType::RBRACE) # eat the rbrace token
    end

    return else_body
  end

  #
  # Parses the body of a conditional
  #
  # @return [Array] The list of all statments inside the body
  #
  def parse_conditional_body
    body = []
    body.append(parse_stmt()) while at().type != TokenType::RBRACE # Parse the content of the if statment

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
      raise "Line:#{@location}: Error: Conditional statment requires a condition"
    end
    
    return condition
  end

  # Parses a assignment statement
  #
  # @return [AssignmentExpr] The AST node
  def parse_assignment_stmt
    left = parse_expr()

    # Check if we have an assignment token
    if at().type == TokenType::ASSIGN
      token = expect(TokenType::ASSIGN).value
      value = parse_expr()
      if token.length == 2
        value = BinaryExpr.new(left, token[0], value)
      end
      return AssignmentStmt.new(value, left)
    end

    return left
  end

  # Parses a expression
  #
  # @return [Expr] The AST node matched
  def parse_expr
    expr = nil
    if at().type == TokenType::IDENTIFIER && next_token().type == TokenType::LPAREN
      expr = parse_func_call()
    elsif at().type == TokenType::IDENTIFIER && next_token().type == TokenType::LBRACKET # Parse array and hash access
      expr = parse_accessor()
    else
      expr = parse_logical_expr()
    end

    while at().type == TokenType::DOT
      expect(TokenType::DOT)
      expr = parse_method_and_property_call(expr)
    end

    if at().type == TokenType::BINARYOPERATOR
      op = eat().value
      right = parse_expr()
      expr = BinaryExpr.new(expr, op, right)
    end

    return expr
  end

  #
  # Parses an accessor for a array or hash
  #
  # @params [ContainerAccessor] prev_node if we have a chained access, get the last node
  # @return [ContainerAccessor] The accessor for a container
  #
  def parse_accessor(prev_node = nil)
    identifier = prev_node ? prev_node : parse_identifier()
    expect(TokenType::LBRACKET)
    access_key = parse_expr()
    expect(TokenType::RBRACKET)

    expr = ContainerAccessor.new(identifier, access_key)
    
    return at().type == TokenType::LBRACKET ? parse_accessor(expr) : expr
  end

  #
  # Parses a method or property call
  #
  # @param [Expr] expr The expression
  #
  # @return [Expr] A MethodCallExpr, PropertyCallExpr
  #
  def parse_method_and_property_call(expr)
    identifier = parse_identifier()
    # Parses a method call
    if at().type == TokenType::LPAREN
      return parse_method_call(expr, identifier)
    else # Parse a property access
      return parse_property_access(expr, identifier)
    end
  end

  #
  # Parse a method call
  #
  # @param [Expr] expr The expression the method is called on
  # @param [Identifier] method_name The name of the method
  #
  # @return [MethodCallExpr] The method call
  #
  def parse_method_call(expr, method_name)
    expect(TokenType::LPAREN)
    params = parse_call_params()
    expect(TokenType::RPAREN)
    node = MethodCallExpr.new(expr, method_name.symbol, params)
    while at().type == TokenType::LBRACKET
      node = parse_accessor(node)
    end
    
    return node
  end
  
  #
  # Parse a property call
  #
  # @param [Expr] expr The expression the property is called on
  # @param [Identifier] property_name The name of the property
  #
  # @return [PropertyCallExpr] The property call
  #
  def parse_property_access(expr, property_name)
    node = PropertyCallExpr.new(expr, property_name.symbol)

    while at().type == TokenType::LBRACKET
      node = parse_accessor(node)
    end
    return node
  end

  #
  # Parses a function call
  #
  # @return [Expr] The function call
  #
  def parse_func_call
    identifier = parse_identifier()
    expect(TokenType::LPAREN) # eat the start paren

    params = parse_call_params()

    expect(TokenType::RPAREN) # Find ending paren
    node = CallExpr.new(identifier, params)

    while at().type == TokenType::LBRACKET
      node = parse_accessor(node)
    end
    return node
  end

  #
  # Parses all the call params to a function or method
  #
  # @return [Array] A list of all the params
  #
  def parse_call_params
    # Parse any params
    params = []
    while at().type != TokenType::RPAREN
      if at().type == TokenType::LBRACKET# && next_token().type != TokenType::RBRACKET
        params << parse_accessor(params.pop)
      else
        params << parse_expr()
      end
      expect(TokenType::COMMA) if at().type == TokenType::COMMA
    end

    return params
  end

  # Parses a logical expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_logical_expr
    left = parse_logical_and_expr()

    # Check for logical or
    while at().value == :"||"
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
    while at().value == :"&&"
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

    while LOGICCOMPARISON.include?(at().value)
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

    while ADD_OPS.include?(at().value)
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

    while MULT_OPS.include?(at().value)
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
    if %i[- + !].include?(at().value)
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
    expr = nil
    case at().type
    when TokenType::IDENTIFIER
      if next_token().type == TokenType::LPAREN
        expr = parse_func_call()
      elsif next_token().type == TokenType::LBRACKET
        expr = parse_accessor()
      else
        expr = parse_identifier()
      end
    when TokenType::INTEGER
      expr = NumericLiteral.new(expect(TokenType::INTEGER).value.to_i, :int)
    when TokenType::FLOAT
      expr = NumericLiteral.new(expect(TokenType::FLOAT).value.to_f, :float)
    when TokenType::BOOLEAN
      expr = BooleanLiteral.new(eat().value == "true")
    when TokenType::STRING
      expr = StringLiteral.new(expect(TokenType::STRING).value.to_s)
    when TokenType::HASH
      expr = parse_hash_literal()
    when TokenType::LPAREN
      expect(TokenType::LPAREN) # Eat opening paren
      expr = parse_expr()
      expect(TokenType::RPAREN) # Eat closing paren
    when TokenType::NULL
      expect(TokenType::NULL)
      expr = NullLiteral.new()
    when TokenType::NEW
      expect(TokenType::NEW)
      expr = ClassInstance.new(parse_identifier())
    else
      raise InvalidTokenError.new("Line:#{@location}: Unexpected token found: #{at().value}")
    end

    while at().type == TokenType::DOT
      expect(TokenType::DOT)
      expr = parse_method_and_property_call(expr)

      if at().type == TokenType::BINARYOPERATOR
        op = eat().value
        right = parse_expr()
        expr = BinaryExpr.new(expr, op, right)
      end
    end

    return expr
  end


  ##################################################
  # 				       Helper functions				         #
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
    @location = @tokens[0].line
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
    token = @tokens.shift()
    @location = token.line
    return token
  end

  # Eat the next token and make sure we have eaten the correct type
  #
  # @param token_types [Array] A list of token which we can expect
  #
  # @return [Token] Returns the expected token
  def expect(*token_types)
    token = eat() # Get the token

    if token_types.include?(token.type)
      return token
    end
    raise "Line:#{@location}: Error: Expected a token of type #{token_types.join(' or ')}, but found #{token.type} instead"
  end
end