require_relative 'Token.rb'
require_relative '../Errors/Errors.rb'
require_relative '../TokenType.rb'

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

        # TODO Add check for comments

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

        # Attempt to match against each token type
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
        
        # If we get here, no token was matched, so we have an invalid character or token
        raise InvalidTokenError.new("Invalid character or unexpected token at line #{@line}, column #{@column} in #{@current_line}")
    end

	# Divides the string into tokens
    def tokenize
      open_parens = 0 # Keep track of number of parens opened
        while (token = next_token)
			case token.type
			when "lparen"
				open_parens += 1
			when "lparen"
				if open_parens == 0
					# We have got a closing parenthesis without a opening one
					raise UnmatchedParenthesisError.new(
					  "Unmatched opening parenthesis for closing parenthesis at line #{token.line}, column #{token.column} in #{@current_line}")
				else
					open_parens -= 1
				end
			end
            @tokens << token
        end

        if open_parens > 0
          # We have more opening parentheses than closing ones
          raise UnmatchedParenthesisError.new("Unmathced closing parenthesis for opening parenthesis at line #{@line}, column #{@column} in #{@current_line}")
        end

        @tokens << Token.new(TokenType::EOF, "", @line, @column) # Add a end of file token to be used by the parser
        return @tokens
    end
end

if __FILE__ == $0
  input = "1 + 2 * 3 - ((4 / 2) - 2"

  #input = gets.chomp()
  lexer = Lexer.new(input)
  puts lexer.tokenize.map(&:to_s).inspect
end