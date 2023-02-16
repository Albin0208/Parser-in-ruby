require_relative '../Lexer/Lexer.rb'

class Node
  def eval
    raise NotImplementedError
  end
end

class NumberNode < Node
  def initialize(value)
    @value = value
  end

  def eval
    @value
  end
end

class BinaryOpNode < Node
  def initialize(left, op, right)
    @left = left
    @op = op
    @right = right
  end

  def eval
    left_val = @left.eval
    right_val = @right.eval

    left_val.send(@op, right_val)
  end
end


class Parser
  def initialize(tokens)
    @tokens = tokens
    @current_index = -1
    @current_token = nil
    advance()
  end

  def parse
    node = nil
    while !@current_token.type.eql?(TokenType::EOF)
      node = expression()
    end

    return node
  end

  private

  def expression
    node = term()

    while @current_token.type == TokenType::OPERATOR && [Operators::PLUS, Operators::MINUS].include?(@current_token.value)
      token = @current_token
      if token.value == Operators::PLUS
        consume(TokenType::OPERATOR)
        node = BinaryOpNode.new(node, token.value, term())
      elsif token.value == Operators::MINUS
        consume(TokenType::OPERATOR)
        node = BinaryOpNode.new(node, token.value, term())
      end
    end

    return node
  end

  def term
    node = factor()

    while @current_token.type == TokenType::OPERATOR && [Operators::MULTIPLY, Operators::DIVIDE].include?(@current_token.value)
      token = @current_token
      if token.value == Operators::MULTIPLY
        consume(TokenType::OPERATOR)
        node = BinaryOpNode.new(node, token.value, factor())
      elsif token.value == Operators::DIVIDE
        consume(TokenType::OPERATOR)
        node = BinaryOpNode.new(node, token.value, factor())
      end
    end
  
    return node
  end

  def factor
    token = @current_token
    case token.type
    when TokenType::INTEGER, TokenType::FLOAT
      consume(token.type) # consume the number token
      return NumberNode.new(token.value)
    when TokenType::LPAREN
      consume(TokenType::LPAREN) # consume the opening parenthesis token
      expr = expression
      consume(TokenType::RPAREN) # consume the closing parenthesis token
      return expr
    else
      raise "Invalid syntax: expected a number or an expression in parentheses, but found #{token.value} at line #{token.line}, column #{token.column}"
    end
  end

  def consume(token_type)
    if @current_token.type == token_type
      advance()
    else
      raise "Invalid syntax"
    end
  end

  def advance
    @current_index += 1
    if @current_index < @tokens.length
      @current_token = @tokens[@current_index]
    end
  end
  
end

input = "3 * (4+3)"
lexer = Lexer.new(input)
tokens = lexer.tokenize

parser = Parser.new(tokens)
puts parser.parse().eval