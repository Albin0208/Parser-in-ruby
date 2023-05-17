require_relative '../ast_nodes/nodes'
require_relative '../lexer/lexer'
require_relative '../utilities/token_type'
require_relative '../errors/errors'
require_relative 'helpers/helpers'

require 'logger'

#
# This is the parser which produces a AST from a list of tokens
#
class Parser
  include TokenNavigation
  include ExpressionValidation
  include HashValidation
  include FunctionHelpers
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

    @location = 1 # used to display the line number where the error is

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
    program = Nodes::Program.new([], @location)
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
    when Utilities::TokenType::CONST, Utilities::TokenType::TYPE_SPECIFIER, Utilities::TokenType::HASH, Utilities::TokenType::IDENTIFIER, Utilities::TokenType::ARRAY_TYPE
      return parse_assignment_stmt() if at().type == Utilities::TokenType::IDENTIFIER && next_token().type != Utilities::TokenType::IDENTIFIER

      return parse_var_declaration()
    when Utilities::TokenType::IF
      return parse_if_statement()
    when Utilities::TokenType::FOR, Utilities::TokenType::WHILE
      return parse_loops()
    when Utilities::TokenType::CLASS
      return parse_class_declaration()
    when Utilities::TokenType::FUNC
      return parse_function_declaration()
    when Utilities::TokenType::RETURN
      return parse_return()
    when Utilities::TokenType::BREAK
      raise "Line:#{at().line}: Error: Break cannot be used outside of loops" unless @parsing_loop

      expect(Utilities::TokenType::BREAK)
      return Nodes::BreakStmt.new(at().line)
    when Utilities::TokenType::CONTINUE
      raise "Line:#{at().line}: Error: Continue cannot be used outside of loops" unless @parsing_loop

      expect(Utilities::TokenType::CONTINUE)
      return Nodes::ContinueStmt.new(at().line)
    else
      return parse_expr()
    end
  end

  # Parses a class declaration and returns a ClassDeclaration AST node.
  #
  # @return [ClassDeclaration] The ClassDeclaration AST node.
  def parse_class_declaration
    expect(Utilities::TokenType::CLASS)

    class_name = parse_identifier()
    decl_location = class_name.line
    member_variables = []
    member_functions = []
    expect(Utilities::TokenType::LBRACE)

    constructors = []

    # Parse all class members
    while at().type != Utilities::TokenType::RBRACE
      stmt = if at().type == Utilities::TokenType::CONSTRUCTOR
               parse_constuctor()
             else
               parse_stmt()
             end

      # Check if the stmt is a func- or varDeclaration
      case stmt.type
      when :FuncDeclaration
        member_functions << stmt
      when :VarDeclaration, :HashDeclaration
        member_variables << stmt
      when :Constructor
        # Check if the same constructor already has been declared
        if constructor_already_exists?(constructors, stmt)
          raise "Line:#{stmt.line}: Error: Constructor already declared with the same parameters"
        end

        constructors << stmt
      end
    end
    expect(Utilities::TokenType::RBRACE)

    return Nodes::ClassDeclaration.new(class_name, constructors, member_variables, member_functions, decl_location)
  end

  # Checks if a constructor with the same signature as the given constructor statement
  # already exists in the array of constructors.
  #
  # @param constructors [Array] The array of constructors to check.
  # @param stmt [Constructor] The constructor statement to compare with existing constructors.
  # @return [Boolean] Returns true if a constructor with the same signature exists, false otherwise.
  def constructor_already_exists?(constructors, stmt)
    constructors.each() do |c|
      # If they have the same amount of params check if they are the same
      next unless c.params.length == stmt.params.length

      c.params.each_with_index() do |param, index|
        # Return false if they have different value type
        return false if param.value_type != stmt.params[index].value_type
      end
      # All the params have the same value type so return true
      return true
    end
    return false
  end

  # Parses a constructor declaration.
  #
  # @return [Constructor] The parsed constructor.
  def parse_constuctor
    expect(Utilities::TokenType::CONSTRUCTOR)
    expect(Utilities::TokenType::LPAREN)
    line = @location
    params = parse_function_params()
    expect(Utilities::TokenType::RPAREN)

    expect(Utilities::TokenType::LBRACE)
    body, = parse_function_body()
    expect(Utilities::TokenType::RBRACE)

    return Nodes::Constructor.new(params, body, line)
  end

  #
  # Parse a hash declaration
  #
  # @param [Boolean] is_const If the current hash declaration is a const or not
  # @return [HashDeclaration] The hash
  #
  def parse_hash_declaration(is_const)
    expect(Utilities::TokenType::HASH)
    key_type, value_type = parse_hash_type_specifier()

    identifier = parse_identifier()

    if at().type != Utilities::TokenType::ASSIGN
      unless is_const
        return Nodes::HashDeclaration.new(is_const, identifier.symbol, key_type.to_sym, value_type, identifier.line, nil)
      end

      @logger.error('Found Uninitialized constant')
      raise NameError, "Line:#{identifier.line}: Error: Uninitialized Constant. Constants must be initialize upon creation"
    end

    expect(Utilities::TokenType::ASSIGN)

    expression = parse_expr()

    return Nodes::HashDeclaration.new(is_const, identifier.symbol, key_type.to_sym, value_type, identifier.line, expression)
  end

  #
  # Parse an hash literal
  #
  # @return [HashLiteral] The hashliteral with all the key-value pairs
  #
  def parse_hash_literal
    key_type, value_type = parse_hash_type_specifier()

    expect(Utilities::TokenType::LBRACE) # Get the opening brace
    key_value_pairs = []

    keys = [] # All keys found

    # Parse all key value pairs
    while at().type != Utilities::TokenType::RBRACE
      key = parse_expr()

      # Check if key already has been defined
      if key_in_hash?(key, keys)#keys.include?(key.value)
        raise "Line:#{@location}: Error: Key: #{key} already exists in hash"
      end

      keys << key if key.is_a?(Nodes::StringLiteral) # Add the key
      validate_assignment_type(key, key_type) # Validate that the type is correct

      expect(Utilities::TokenType::ASSIGN)
      value = parse_expr()

      # validate_assignment_type(value, value_type) # Validate that the type is correct
      key_value_pairs << { key: key, value: value} # Create a new pair

      eat() if at().type == Utilities::TokenType::COMMA # The comma token
    end

    expect(Utilities::TokenType::RBRACE) # Get the closing brace

    return Nodes::HashLiteral.new(key_value_pairs, key_type.to_sym, value_type, @location)
  end



  #
  # Parse loops
  #
  # @return [Expr] The loop
  #
  def parse_loops
    case at().type
    when Utilities::TokenType::FOR # Parse for statement
      return parse_for_stmt()
    when Utilities::TokenType::WHILE # Parse while statement
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
    expect(Utilities::TokenType::FOR)

    # We have a for loop over a container
    return parse_for_loop_over_container() if next_token().type == Utilities::TokenType::IN

    for_start_location = @location
    var_dec = parse_var_declaration()
    if var_dec.value.nil?
      raise "Line:#{@location}: Error: Variable '#{var_dec.identifier}' has to be initialized in for-loop"
    end

    expect(Utilities::TokenType::COMMA)
    condition = parse_conditional_condition() # Parse the loop condition
    expect(Utilities::TokenType::COMMA)
    expr = parse_stmt()
    # Don't allow for every stmt, only assign-statement and expressions
    unless expr.is_a?(Nodes::Expr) || expr.is_a?(Nodes::AssignmentStmt)
      raise "Line:#{@location}: Error: Wrong type of expression given"
    end

    expect(Utilities::TokenType::LBRACE)
    body = parse_conditional_body()
    expect(Utilities::TokenType::RBRACE)

    @parsing_loop = false
    return Nodes::ForStmt.new(body, condition, var_dec, expr, for_start_location)
  end

  # Parses a for loop over a container and returns a ForEachStmt object.
  #
  # @return [ForEachStmt] The for loop statement object.
  def parse_for_loop_over_container
    identifier = parse_identifier()
    for_start_location = @location
    expect(Utilities::TokenType::IN)
    container = parse_expr()

    expect(Utilities::TokenType::LBRACE)
    body = parse_conditional_body()
    expect(Utilities::TokenType::RBRACE)

    @parsing_loop = false
    return Nodes::ForEachStmt.new(body, identifier, container, for_start_location)
  end

  # Parses a while loop statement.
  #
  # @return [WhileStmt] The WhileStmt AST node.
  #
  def parse_while_stmt
    @parsing_loop = true
    expect(Utilities::TokenType::WHILE)
    condition = parse_conditional_condition() # Parse the loop condition

    # Parse the loop body
    expect(Utilities::TokenType::LBRACE)
    body = parse_conditional_body()
    expect(Utilities::TokenType::RBRACE)

    @parsing_loop = false
    return Nodes::WhileStmt.new(body, condition, @location)
  end

  #
  # Parses a identifier
  #
  # @return [Expr] An expression matching the tokens
  #
  def parse_identifier
    return Nodes::Identifier.new(expect(Utilities::TokenType::IDENTIFIER).value, @location)

  end

  #
  # Parses a return statement
  #
  # @return [Return] The return statement with the expressions
  #
  def parse_return()
    unless @parsing_function
      raise "Line:#{@location}: Error: Unexpected return encountered. Returns are not allowed outside of functions"
    end

    expect(Utilities::TokenType::RETURN)
    expr = parse_expr()

    return Nodes::ReturnStmt.new(expr, @location)
  end

  # Parse a variable declaration
  #
  # @return [VarDeclaration] The Vardeclaration AST node
  #
  # @raise [NameError] If an uninitialized constant is found.
  def parse_var_declaration
    is_const = at().type == Utilities::TokenType::CONST # Get if const keyword is present

    eat() if is_const # eat the const keyword if we have a const

    return parse_hash_declaration(is_const) if at().type == Utilities::TokenType::HASH

    return parse_array_declaration(is_const) if at().type == Utilities::TokenType::ARRAY_TYPE

    type_specifier = expect(Utilities::TokenType::TYPE_SPECIFIER, Utilities::TokenType::IDENTIFIER).value # Get what type the var should be

    identifier = parse_identifier().symbol

    if at().type != Utilities::TokenType::ASSIGN
      return Nodes::VarDeclaration.new(is_const, identifier, type_specifier, @location, nil) unless is_const

      raise NameError, "Line:#{@location}: Error: Uninitialized Constant. Constants must be initialize upon creation"
    end

    expect(Utilities::TokenType::ASSIGN)
    expression = parse_expr()

    validate_assignment_type(expression, type_specifier) # Validate that the type is correct

    return Nodes::VarDeclaration.new(is_const, identifier, type_specifier, expression.line, expression)
  end

  # Parses an array declaration and returns an AST node representing the declaration.
  #
  # @param [Boolean] is_const A flag indicating whether the array is a constant
  # @return [ArrayDeclaration] An AST node representing the array declaration
  # @raise [NameError] if a constant is not initialized upon creation
  # @raise [SyntaxError] if the type of the assigned expression is not compatible with the declared type
  def parse_array_declaration(is_const)
    type = expect(Utilities::TokenType::ARRAY_TYPE).value.to_s.gsub(/\s/, '').to_sym

    identifier = parse_identifier()

    if at().type != Utilities::TokenType::ASSIGN
      return Nodes::ArrayDeclaration.new(is_const, identifier.symbol, type, identifier.line, nil) unless is_const

      raise NameError, "Line:#{@location}: Error: Uninitialized Constant. Constants must be initialize upon creation"
    end

    expect(Utilities::TokenType::ASSIGN)
    expression = parse_expr()

    validate_assignment_type(expression, type) # Validate that the type is correct

    return Nodes::ArrayDeclaration.new(is_const, identifier.symbol, type, identifier.line, expression)
  end

  #
  # Parse a function declaration
  #
  # @return [FuncDeclaration] The ast node representing a function
  #
  def parse_function_declaration
    expect(Utilities::TokenType::FUNC) # Eat the func keyword
    @parsing_function = true
    func_location = @location

    return_type = if at().type == Utilities::TokenType::HASH
                    "#{expect(Utilities::TokenType::HASH).value}#{expect(Utilities::TokenType::HASH_TYPE).value.to_s.delete(' ')}"
                  else
                    expect(Utilities::TokenType::VOID, Utilities::TokenType::TYPE_SPECIFIER, Utilities::TokenType::IDENTIFIER, Utilities::TokenType::HASH).value
                  end

    identifier = expect(Utilities::TokenType::IDENTIFIER).value # Expect a identifier for the func

    # Parse function parameters
    expect(Utilities::TokenType::LPAREN)
    params = parse_function_params()
    expect(Utilities::TokenType::RPAREN)

    expect(Utilities::TokenType::LBRACE) # Start of function body
    body, has_return_stmt = parse_function_body()

    if return_type != 'void' && !has_return_stmt
      raise "Line:#{@location}: Error: Function of type: '#{return_type}' expects a return statment"
    end

    expect(Utilities::TokenType::RBRACE) # End of function body
    @parsing_function = false

    return Nodes::FuncDeclaration.new(return_type, identifier, params, body, func_location)
  end

  # Parses conditional statments such as if, else if and else
  #
  # @return [IfStatement] The If statement AST node
  #
  def parse_if_statement
    expect(Utilities::TokenType::IF) # eat the if token

    if_condition = parse_conditional_condition() # Parses the if condition
    expect(Utilities::TokenType::LBRACE) # eat lbrace token
    if_body = parse_conditional_body() # parses the if body
    expect(Utilities::TokenType::RBRACE) # eat the rbrace token

    elsif_stmts = parse_elsif_statements() # Parse else ifs
    else_body = parse_else_statement() # Parse Else

    return Nodes::IfStatement.new(if_body, if_condition, else_body, elsif_stmts, @location)
  end

  #
  # Parses all elsif statments
  #
  # @return [Array] A list of all the elsifs found
  #
  def parse_elsif_statements
    elsif_stmts = []
    while at().type == Utilities::TokenType::ELSIF
      expect(Utilities::TokenType::ELSIF)
      elsif_condition = parse_conditional_condition() # Parse elsif condition
      expect(Utilities::TokenType::LBRACE) # eat lbrace token
      elsif_body = parse_conditional_body() # Parse elsif body
      expect(Utilities::TokenType::RBRACE) # eat the rbrace token
      elsif_stmts << Nodes::ElsifStatement.new(elsif_body, elsif_condition, @location)
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
    if at().type == Utilities::TokenType::ELSE
      expect(Utilities::TokenType::ELSE) # eat the Else token
      expect(Utilities::TokenType::LBRACE) # eat lbrace token
      else_body = parse_conditional_body()
      expect(Utilities::TokenType::RBRACE) # eat the rbrace token
    end

    return else_body
  end

  #
  # Parses the body of a conditional
  #
  # @return [Array] The list of all statements inside the body
  #
  def parse_conditional_body
    body = []
    body.append(parse_stmt()) while at().type != Utilities::TokenType::RBRACE # Parse the content of the if statement

    return body
  end

  #
  # Parses the condition of a if or elsif statement
  #
  # @return [Expr] The condition of the statement
  #
  def parse_conditional_condition
    raise "Line:#{@location}: Error: Conditional statement requires a condition" if at().type == Utilities::TokenType::LBRACE

    return parse_logical_expr()
  end

  # Parses a assignment statement
  #
  # @return [AssignmentExpr] The AST node
  def parse_assignment_stmt
    left = parse_expr()

    # Check if we have an assignment token
    if at().type == Utilities::TokenType::ASSIGN
      token = expect(Utilities::TokenType::ASSIGN).value
      value = parse_expr()
      value = Nodes::BinaryExpr.new(left, token[0], value, @location) if token.length == 2
      return Nodes::AssignmentStmt.new(value, left, value.line)
    end

    return left
  end

  # Parses a expression
  #
  # @return [Expr] The AST node matched
  def parse_expr
    expr = nil
    if at().type == Utilities::TokenType::IDENTIFIER && next_token().type == Utilities::TokenType::LPAREN
      expr = parse_func_call()
    elsif at().type == Utilities::TokenType::IDENTIFIER && next_token().type == Utilities::TokenType::LBRACKET # Parse array and hash access
      expr = parse_accessor()
    else
      expr = parse_logical_expr()
    end

    while at().type == Utilities::TokenType::DOT
      expect(Utilities::TokenType::DOT)
      expr = parse_method_and_property_call(expr)
    end

    if at().type == Utilities::TokenType::BINARYOPERATOR
      op = eat().value
      right = parse_expr()
      expr = Nodes::BinaryExpr.new(expr, op, right, @location)
    end

    return expr
  end

  #
  # Parses an accessor for a array or hash
  #
  # @param [ContainerAccessor, nil] prev_node if we have a chained access, get the last node
  # @return [ContainerAccessor] The accessor for a container
  #
  def parse_accessor(prev_node = nil)
    # Sets the identifier to the prev_node unless it is nil
    identifier = prev_node || parse_identifier()
    expect(Utilities::TokenType::LBRACKET)
    access_key = parse_expr()
    expect(Utilities::TokenType::RBRACKET)

    expr = Nodes::ContainerAccessor.new(identifier, access_key, @location)

    return at().type == Utilities::TokenType::LBRACKET ? parse_accessor(expr) : expr
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
    return parse_method_call(expr, identifier) if at().type == Utilities::TokenType::LPAREN

    # Parse a property access
    return parse_property_access(expr, identifier)
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
    expect(Utilities::TokenType::LPAREN)
    params = parse_call_params()
    expect(Utilities::TokenType::RPAREN)
    # Create a new MethodCall node
    node = Nodes::MethodCallExpr.new(expr, method_name.symbol, params, @location)

    # Parse all accessors if they exists
    node = parse_accessor(node) while at().type == Utilities::TokenType::LBRACKET

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
    node = Nodes::PropertyCallExpr.new(expr, property_name.symbol, @location)

    node = parse_accessor(node) while at().type == Utilities::TokenType::LBRACKET
    return node
  end

  #
  # Parses a function call
  #
  # @return [Expr] The function call
  #
  def parse_func_call
    identifier = parse_identifier()
    expect(Utilities::TokenType::LPAREN) # eat the start paren

    params = parse_call_params()

    expect(Utilities::TokenType::RPAREN) # Find ending paren
    node = Nodes::CallExpr.new(identifier, params, @location)

    node = parse_accessor(node) while at().type == Utilities::TokenType::LBRACKET
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
    while at().type != Utilities::TokenType::RPAREN
      params << if at().type == Utilities::TokenType::LBRACKET
                  parse_accessor(params.pop)
                else
                  parse_expr()
                end
      expect(Utilities::TokenType::COMMA) if at().type == Utilities::TokenType::COMMA
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
      left = Nodes::LogicalOrExpr.new(left, right, @location)
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
      eat() # eat the operator
      right = parse_comparison_expr()
      left = Nodes::LogicalAndExpr.new(left, right, @location)
    end

    return left
  end

  # Parses a comparison expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_comparison_expr
    left = parse_additive_expr()

    while Utilities::LOGICCOMPARISON.include?(at().value)
      comparator = eat().value # eat the comparator
      right = parse_additive_expr()
      left = Nodes::BinaryExpr.new(left, comparator, right, @location)
    end

    return left
  end

  # Parses a additive expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_additive_expr
    left = parse_multiplication_expr()

    while Utilities::ADD_OPS.include?(at().value)
      operator = eat().value # eat the operator
      right = parse_multiplication_expr()
      left = Nodes::BinaryExpr.new(left, operator, right, @location)
    end

    return left
  end

  # Parses a multiplication expression
  #
  # @return [Expr] The AST node matching the parsed expr
  def parse_multiplication_expr
    left = parse_unary_expr()

    while Utilities::MULT_OPS.include?(at().value)
      operator = eat().value # eat the operator
      right = parse_unary_expr()
      left = Nodes::BinaryExpr.new(left, operator, right, @location)
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
      return Nodes::UnaryExpr.new(right, operator, @location)
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
    when Utilities::TokenType::IDENTIFIER
      expr = if next_token().type == Utilities::TokenType::LPAREN
               parse_func_call()
             elsif next_token().type == Utilities::TokenType::LBRACKET
               parse_accessor()
             else
               parse_identifier()
             end
    when Utilities::TokenType::INTEGER
      expr = Nodes::NumericLiteral.new(expect(Utilities::TokenType::INTEGER).value.to_i, :int, @location)
    when Utilities::TokenType::FLOAT
      expr = Nodes::NumericLiteral.new(expect(Utilities::TokenType::FLOAT).value.to_f, :float, @location)
    when Utilities::TokenType::BOOLEAN
      expr = Nodes::BooleanLiteral.new(eat().value == "true", @location)
    when Utilities::TokenType::STRING
      expr = Nodes::StringLiteral.new(expect(Utilities::TokenType::STRING).value.to_s, @location)
    when Utilities::TokenType::HASH, Utilities::TokenType::TYPE_SPECIFIER, Utilities::TokenType::ARRAY_TYPE
      eat() if at().type == Utilities::TokenType::HASH # Eat the hash keyword, it is of no use in the parser
      expr = if at().type == Utilities::TokenType::ARRAY_TYPE || next_token().type == Utilities::TokenType::LBRACKET
                parse_array_literal()
              else
                parse_hash_literal()
              end
    when Utilities::TokenType::LPAREN
      expect(Utilities::TokenType::LPAREN) # Eat opening paren
      expr = parse_expr()
      expect(Utilities::TokenType::RPAREN) # Eat closing paren
    when Utilities::TokenType::NULL
      expect(Utilities::TokenType::NULL)
      expr = Nodes::NullLiteral.new(@location)
    when Utilities::TokenType::NEW
      expr = parse_class_instance()
    else
      raise InvalidTokenError, "Line:#{@location}: Unexpected token found: #{at().value}"
    end

    while at().type == Utilities::TokenType::DOT
      expect(Utilities::TokenType::DOT)
      expr = parse_method_and_property_call(expr)

      next unless at().type == Utilities::TokenType::BINARYOPERATOR

      op = eat().value
      right = parse_expr()
      expr = Nodes::BinaryExpr.new(expr, op, right, @location)
    end

    return expr
  end

  #
  # Parses an instance of a class
  #
  # @return [ClassInstance] The ast node for the class instance
  #
  def parse_class_instance
    expect(Utilities::TokenType::NEW)
    identifier = parse_identifier()

    expect(Utilities::TokenType::LPAREN)
    params = parse_call_params()
    expect(Utilities::TokenType::RPAREN)

    return Nodes::ClassInstance.new(identifier, params, @location)
  end

  # Parses an array literal expression.
  #
  # @return [ArrayLiteral] The array literal expression AST node.
  def parse_array_literal()
    if at().type == Utilities::TokenType::ARRAY_TYPE
      type = expect(Utilities::TokenType::ARRAY_TYPE).value.to_s.gsub(/[\[\]\s]/, '').to_sym
      return Nodes::ArrayLiteral.new([], type, @location)
    end

    # Check if it is a array of hashes
    if at().type == Utilities::TokenType::HASH_TYPE
      type = "Hash"
      type << expect(Utilities::TokenType::HASH_TYPE).value.to_s.gsub(/\s/, '')
    else
      type = expect(Utilities::TokenType::TYPE_SPECIFIER).value.to_sym
    end

    expect(Utilities::TokenType::LBRACKET)
    value = []
    while at().type != Utilities::TokenType::RBRACKET
      expr = parse_expr()
      value << expr
      expect(Utilities::TokenType::COMMA) if at().type == Utilities::TokenType::COMMA
    end

    expect(Utilities::TokenType::RBRACKET)

    return Nodes::ArrayLiteral.new(value, type, @location)
  end
end