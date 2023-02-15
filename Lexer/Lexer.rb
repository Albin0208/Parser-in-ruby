require_relative 'Token.rb'
require_relative '../Errors/Errors.rb'
require_relative '../TokenType.rb'

# TOKEN_TYPES = {
#   integer: /\d/,
#   operator: /[\+\-\*\/]/,
#   lparen: /\(/,
#   rparen:  /\)/,
# }
TOKEN_TYPES = {
  integer: /\A\d+/,
  operator: /\A[\+\-\*\/]/,
  lparen: /\A\(/,
  rparen: /\A\)/,
}

class Lexer
    def initialize(string)
        @string = string.rstrip # Remove any trailing whitespace
        @current_line = ""
        @position = 0
        @line = 1
        @column = 1

        @tokens = []
    end 

    def next_token()
      return nil if @position >= @string.length
      @current_line = @string[0..@string.length].match(/^\s*.*$/) 
        # Skip whitespace
        while @string[@position] =~ /\s/
            # We find a new line update the line and column value
            if @string[@position] == "\n"
                @line += 1
                @column = 1 # Reset to first index on line
            else
                @column += 1
            end
           @position += 1
        end

        # case @string[@position]
        # when TOKEN_TYPES[:integer]
        #   # Parse integer
        #   start_pos = @position
        #   # Eat all the integers
        #   while @position < @string.length && @string[@position] =~ TOKEN_TYPES[:integer]
        #     @position += 1
        #   end
        #   token = Token.new(TokenType::INTEGER, @string[start_pos..@position-1].to_i, @line, @column)
        #   @column += @position - start_pos # Step forward the column the length of the number
        #   return token
    
        # when TOKEN_TYPES[:operators]
        #   # Parse operator
        #   token = Token.new("operator", @string[@position], @line, @column)
        #   advance()
        #   return token
    
        # when TOKEN_TYPES[:lparen]
        #   # Create left paren token
        #   token = Token.new(TokenType::LPAREN, @string[@position], @line, @column)
        #   advance()
        #   return token
    
        # when TOKEN_TYPES[:rparen]
        #   # Create right paren token
        #   token = Token.new(TokenType::RPAREN, @string[@position], @line, @column)
        #   advance()
        #   return token
        #   else
        #     raise MySyntaxError.new("Invalid character or unexpected token at line #{@line}, column #{@column} in #{@current_line}")
        #   end   
        TOKEN_TYPES.each do |token_type, regex|
          # Match against the regex from the position to the end of the string
          if @string[@position..-1] =~ /#{regex}/
            value = $~[0] # Get the value of the first match
            token = Token.new(token_type.to_s, value, @line, @column) # Create a new token with the token type and value
            @column += value.length
            @position += value.length
            return token
          end
        end
        # If We get here we have got a invalid token
        raise MySyntaxError.new("Invalid character or unexpected token at line #{@line}, column #{@column} in #{@current_line}")
    end

    # def advance
    #   @position += 1
    #   @column += 1
    # end

	# Divides the string into tokens
    def tokenize
        while (token = next_token)
            @tokens << token
        end
        @tokens << Token.new(TokenType::EOF, "", @line, @column) # Add a end of file token to be used by the parser
        return @tokens
    end
end

input = "1 + 2 * 3 - (4 / 2)
-45"

#input = gets.chomp()
lexer = Lexer.new(input)
puts lexer.tokenize.map(&:to_s).inspect