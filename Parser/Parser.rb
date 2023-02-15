require_relative '../Lexer/Lexer.rb'

class Node
  def eval
    raise NotImplementedError
  end
end

class IntegerNode < Node
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

    left_val.send(@op.to_sym, right_val)
  end
end


class Parser
  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    expression
  end

  private

  def expression
    term while match(TokenType::PLUS, TokenType::MINUS)
  end

  def term
    factor while match(TokenType::MULTIPLY, TokenType::DIVIDE)
  end

  def factor
    if match(TokenType::INTEGER)
      # Return an AST node for the integer value
      return LiteralNode.new(previous().literal)
    end

    if match(TokenType::LPAREN)
      # Parse the expression inside the parentheses
      expression
      consume(TokenType::RPAREN, "Expected ')' after expression.")
    end

    # If we haven't matched an integer or left parenthesis, it's an error
    raise ParseError.new("Expected expression.")
  end

  def match(*types)
    types.each do |type|
      if check(type)
        advance
        return true
      end
    end

    false
  end

  def consume(expected_type, error_message)
    if check(expected_type)
      advance
    else
      raise ParseError.new(error_message)
    end
  end

  def check(expected_type)
    return false if is_at_end?

    peek.type == expected_type
  end

  def is_at_end?
    peek.type == TokenType::EOF
  end

  def peek
    @tokens[@current]
  end

  def advance
    @current += 1 unless is_at_end?
    previous
  end

  def previous
    @tokens[@current - 1]
  end
end



# require_relative '../Lexer/Lexer.rb'
# require_relative 'BinaryOperations'

# class Parser
#   def initialize(tokens)
#     @tokens = tokens
#     @index = 0
#   end

#   def parse
#     puts @tokens
#   end
# end

input = "1 + 2 * 3 - (4 / 2)"
lexer = Lexer.new(input)
tokens = lexer.tokenize
parser = Parser.new(tokens)
puts parser.parse
