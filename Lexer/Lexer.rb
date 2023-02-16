require_relative 'Token.rb'
require_relative '../Errors/Errors.rb'
require_relative '../TokenType.rb'

TOKEN_TYPES = {
  integer: /\A\d+(\.\d+)?/,
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

	# Divides the string into tokens
	def tokenize
		open_parens = 0 # Keep track of number of parens opened
		while (token = next_token)
			case token.type
			when TokenType::LPAREN
				open_parens += 1
			when TokenType::RPAREN
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
			last_open_paren = @tokens.select {|t| t.type == TokenType::LPAREN}.last # Get the last opened parenthesis

			line = @string.each_line.to_a[last_open_paren.line - 1] # Get the line where the error was
			# We have more opening parentheses than closing ones
			raise UnmatchedParenthesisError.new(
				"Unmathced closing parenthesis for opening parenthesis at line #{last_open_paren.line}, column #{last_open_paren.column} in #{line}")
		end

		@tokens << Token.new(TokenType::EOF, "", @line, @column) # Add a end of file token to be used by the parser
		return @tokens
	end

	private

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

		case @string[@position..-1]
		when TOKEN_TYPES[:integer]
			value = $~[0]
			# Check for whitespace between two numbers
			if @string[@position + value.length..-1] =~ /\A\s*\d+/
			  raise InvalidTokenError.new("Unexpected token, number separeted by whitespace at line #{@line}, column #{@column} in #{@current_line}")
			end

			if value.include?(".")
				token = Token.new(TokenType::FLOAT, value.to_f, @line, @column)		
			else
				# TODO Add check for if number has trailing digits when starting with 0
				if value.length > 1 && value[0].to_i == 0
					raise InvalidTokenError.new("Invalid octal digit at line #{@line}, column #{@column} in #{@current_line}")
				end
				token = Token.new(TokenType::INTEGER, value.to_i, @line, @column)
			end
			advance(value.length)
			return token
		when TOKEN_TYPES[:operator]
			token = Token.new(TokenType::OPERATOR, $~[0].to_sym, @line, @column)
			advance()
			return token
		when TOKEN_TYPES[:lparen]
			token = Token.new(TokenType::LPAREN, $~[0], @line, @column)
			advance()
			return token
		when TOKEN_TYPES[:rparen]
			token = Token.new(TokenType::RPAREN, $~[0], @line, @column)
			advance()
			return token
		end
        
        # If we get here, no token was matched, so we have an invalid character or token
        raise InvalidTokenError.new("Invalid character or unexpected token at line #{@line}, column #{@column} in #{@current_line}")
    end

	def peek_next(length = 1)
		return @string[@position + length]
	end

	# Advance were we are in the string
	def advance(length = 1)
		@position += length
		@column += length
	end
end

if __FILE__ == $0
  input = "1 + 2.3 * 03 - \n(4 / 2) - 2"
	# input = "1.3"

  #input = gets.chomp()
  lexer = Lexer.new(input)
  puts lexer.tokenize.map(&:to_s).inspect
end