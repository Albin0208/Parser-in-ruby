require_relative 'lexer'
require_relative 'BinaryOperations'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @index = 0
  end

  def parse
    expression
  end

  private

  def expression
    left = term

    while [Token::ADD, Token::SUBTRACT].include? current_token.type
      operator_token = current_token
      consume_token

      right = term

      left = BinaryOperation.new(left, operator_token.type, right)
    end

    left
  end

  def term
    left = factor

    while [Token::MULTIPLY, Token::DIVIDE].include? current_token.type
      operator_token = current_token
      consume_token

      right = factor

      left = BinaryOperation.new(left, operator_token.type, right)
    end

    left
  end

  def factor
    if current_token.type == Token::INTEGER
      integer_token = current_token
      consume_token
      return integer_token.value
    elsif current_token.type == Token::LPAREN
      consume_token
      expression_value = expression
      if current_token.type != Token::RPAREN
        raise "Expected )"
      end
      consume_token
      return expression_value
    else
      raise "Invalid syntax"
    end
  end

  def current_token
    @tokens[@index]
  end

  def consume_token
    @index += 1
  end
end

input = "1 + 2 * 3 - (4 / 2)"
lexer = Lexer.new(input)
tokens = lexer.tokenize
parser = Parser.new(tokens)
puts parser.parse
