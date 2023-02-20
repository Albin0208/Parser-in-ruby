require 'logger'

require_relative 'Token.rb'
require_relative '../Errors/Errors.rb'
require_relative '../TokenType.rb'

TOKEN_TYPES = {
	integer: /\A\d+(\.\d+)?/,
	operator: /\A[\+\-\*\/\%]/,
	unaryOperator: /\A[-\+](?=\d+(\.\d+)?)/,
	logical: /\A((&&)|(\|\|))/,
	comparators: /\A((>=)|(<=)|(==)|(!=)|(<)|(>))/,
	lparen: /\A\(/,
	rparen: /\A\)/,
	assign: /\A\=/,
	identifier: /\A([a-z]|_[a-z])\w*/i,
}

KEYWORDS = {
	"var" => TokenType::VAR,
	"const" => TokenType::CONST,
	"func" => TokenType::FUNC,
	"if" => TokenType::IF,
	"then" => TokenType::THEN,
	"end" => TokenType::ENDSTMT
}

# The lexer class
class Lexer
    def initialize(string, should_log = false)
        @string = string.rstrip # Remove any trailing whitespace
        @current_line = ""
        @position = 0
        @line = 1
        @column = 1

        @tokens = []

		@logger = Logger.new(STDOUT)
		@logger.level = should_log ? Logger::DEBUG : Logger::FATAL
    end 

	# Divides the string into tokens
	# @return Array - Return a Array of the tokens found
	def tokenize()
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

	# Get the next token
	# @return Token | nil - Return the new token or nil if we have reached the end of the input string
    def next_token()
        return nil if at_eof()
        @current_line = @string[0..@string.length].match(/^\s*.*$/) 	

        # Skip whitespace
        while @string[@position] =~ /\A\s/
            # We find a new line update the line and column value
            if @string[@position] == "\n"
                @line += 1
                @column = 1 # Reset to first index on line
            else
                @column += 1
            end
           @position += 1
        end

		@logger.debug("Parsing token at line #{@line}, column #{@column}, Token: #{@string[@position]}")

		# Add check for comments
		if @string[@position] =~ /\A#/
			@logger.debug("Found comment token")
			while @string[@position] != /\n/
				@position += 1
				return nil if at_eof() # We have reached the end of file
			end
			@line += 1
			@column = 1 # Reset to first index on line
			return next_token() # Call next_token to get the next token after the comment
		end

		case @string[@position..-1]
		when TOKEN_TYPES[:integer]
			return handle_number_match($~[0])
		when TOKEN_TYPES[:unaryOperator]
			return create_token($~[0], TokenType::UNARYOPERATOR, "Found unary operator token", true)
		when TOKEN_TYPES[:operator]
			return create_token($~[0], TokenType::BINARYOPERATOR, "Found binary operator token", true)
		when TOKEN_TYPES[:logical]
			return create_token($~[0], TokenType::LOGICAL, "Found logical token", true)
		when TOKEN_TYPES[:comparators]
			return create_token($~[0], TokenType::COMPARISON, "Found comparison token", true)
		when TOKEN_TYPES[:assign]
			return create_token($~[0], TokenType::ASSIGN, "Found assign token", true)
		when TOKEN_TYPES[:lparen]
			return create_token($~[0], TokenType::LPAREN, "Found left paren token", true)
		when TOKEN_TYPES[:rparen]
			return create_token($~[0], TokenType::RPAREN, "Found right paren token", true)
		when TOKEN_TYPES[:identifier]
			return handle_identifier_match($~[0])
		end
        
        # If we get here, no token was matched, so we have an invalid character or token
        raise InvalidTokenError.new("Invalid character or unexpected token at line #{@line}, column #{@column} in #{@current_line}")
    end

	##################################################
	# 				Helper functions				 #
	##################################################

	# Create the token
	# @param match - The value of the token we have matched
	# @param type - What type of token we want to create
	# @param message - The message we want to log
	# @param to_symbol - If we want to convert the match to a symbol, Default: false
	# @return Token - A new Token if type @type
	def create_token(match, type, message, to_symbol = false)
		match = to_symbol ? match.to_sym : match
		token = Token.new(type, match, @line, @column)
		@logger.debug("#{message}: #{token.value}")
		advance(token.value.to_s.length)
		return token
	end

	# Handles when we have matched a number
	# @param match - The value of the token we have matched
	# @return Token - A new number token
	def handle_number_match(match)
		# Check for whitespace between two numbers
		if @string[@position + match.length..-1] =~ /\A\s*\d+/
			raise InvalidTokenError.new("Unexpected token, number separeted by whitespace at line #{@line}, column #{@column} in #{@current_line}")
		end

		# Check if we have a float
		if match.include?(".")
			return create_token(match.to_f, TokenType::FLOAT, "Found float token")
		else
			# Check for if number has trailing digits when starting with 0
			if match.length > 1 && match[0].to_i == 0
				raise InvalidTokenError.new("Invalid octal digit at line #{@line}, column #{@column} in #{@current_line}")
			end
			return create_token(match.to_i, TokenType::INTEGER, "Found integer token")
		end
	end

	# Handle when we have matched a identifier
	# @param match - The value of the token we have matched
	# @return Token - A new identifier token
	def handle_identifier_match(match)
		# Check if it is a keyword
		if KEYWORDS.has_key?(match)
			# # Create keyword token
			return create_token(match, KEYWORDS[match], "Found keyword token")
		else
			# If not it is a user defined keyword
			# # Create keyword token
			return create_token(match, TokenType::IDENTIFIER, "Found identifier token")
		end
	end

	# Advance where we are in the string
	# @param length - How far we should advance, Default: 1
	def advance(length = 1)
		@position += length
		@column += length
	end

	# Check if we have reached the end of the input string
	# @return Boolean - If we have reach the end of the input string
	def at_eof
		return @position >= @string.length
	end
end

if __FILE__ == $0
#   input = "1 + 2.3 * 03 - \n(4 / 2) - 2"
	# input = "1.3"

  input = gets.chomp()
  lexer = Lexer.new(input)
  puts lexer.tokenize.map(&:to_s).inspect
end