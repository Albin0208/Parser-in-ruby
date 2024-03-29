#
# All the functions helpers for the parser
#
module FunctionHelpers
  private

  #
  # Recursively check if the statement has any return statements
  #
  # @param [Stmt] stmt The statement to check
  #
  # @return [Boolean] True if ReturnStmt exits otherwise false
  #
  def has_return_statement?(stmt)
    if stmt.instance_of?(Nodes::ReturnStmt)
      return true
    elsif stmt.instance_variable_defined?(:@body)
      return stmt.body.any? { |s| has_return_statement?(s) }
    else
      return false
    end
  end

  #
  # Parses a function body and gets if it has a return statement
  #
  # @return [Array & Boolean] Return the list of all statements and if the body has a return statement
  #
  def parse_function_body
    body = []
    has_return_stmt = false
    while at().type != Utilities::TokenType::RBRACE
      stmt = parse_stmt()
      # Don't allow for function declaration inside a function
      if stmt.type == NODE_TYPES[:FuncDeclaration]
        raise "Line:#{stmt.line}: Error: A function declaration is not allowed inside another function"
      end

      has_return_stmt ||= has_return_statement?(stmt) # ||= Sets has_return to true if it is false and keeps it true even if has_return_statements returns false

      body << stmt
    end

    return body, has_return_stmt
  end

  #
  # Parses the functions params
  #
  # @return [Array] A list of all the params of the function
  #
  def parse_function_params
    params = []
    if at().type != Utilities::TokenType::RPAREN
      params << parse_var_declaration()
      while at().type == Utilities::TokenType::COMMA
        expect(Utilities::TokenType::COMMA)
        params << parse_var_declaration()
      end
    end

    return params
  end
end
