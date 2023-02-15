require_relative '../Lexer/Lexer.rb'
require_relative 'BinaryOperations'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @index = 0
  end

  def parse
    puts @tokens
  end
end

input = "1 + 2 * 3 - (4 / 2)"
lexer = Lexer.new(input)
tokens = lexer.tokenize
parser = Parser.new(tokens)
puts parser.parse
