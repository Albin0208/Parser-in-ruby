require 'logger'

require_relative 'token'
require_relative '../errors/errors'
require_relative '../token_type'

# Create an array of tuples so order doesn't matter then convert to hash
TOKEN_TYPES = [
  [:integer, /\A\d+(\.\d+)?/],
  [:string, /\A"([^"]*)"/],
  [:comparison, /\A((>=)|(<=)|(==)|(!=)|(<)|(>))/],
  [:unaryOperator, /\A[-+!]/],
  [:binaryoperator, %r{\A[+\-*/%]}],
  [:logical, /\A((&&)|(\|\|))/],
  [:lparen, /\A\(/],
  [:rparen, /\A\)/],
  [:lbrace, /\A\{/],
  [:rbrace, /\A\}/],
  [:assign, /\A=/],
  [:identifier, /\A([a-z]|_[a-z])\w*/i],
  [:separators, /\A,/]
].to_h.freeze

KEYWORDS = {
  const: TokenType::CONST,
  func: TokenType::FUNC,
  if: TokenType::IF,
  else: TokenType::ELSE,
  true: TokenType::BOOLEAN,
  false: TokenType::BOOLEAN,
  null: TokenType::NULL,

  # Type Specifiers
  int: TokenType::TYPE_SPECIFIER,
  float: TokenType::TYPE_SPECIFIER,
  bool: TokenType::TYPE_SPECIFIER,
  string: TokenType::TYPE_SPECIFIER
}.freeze

#
# The lexer which creates tokens from a text
#
class Lexer
  #
  # Creates a lexer
  #
  # @param [String] string The string that should be analysed
  # @param [Boolean] should_log If we should log to the terminal
  #
  def initialize(string, should_log = false)
    @string = string.rstrip # Remove any trailing whitespace
    @current_line = ''
    @position = 0
    @line = 1
    @column = 1

    @tokens = []

    @logger = Logger.new($stdout)
    @logger.level = should_log ? Logger::DEBUG : Logger::FATAL
  end

  #
  # Divides the string into tokens
  #
  # @return [Array] A Array of the tokens found
  #
  def tokenize
    stack = [] # Use a stack to keep track of open parentheses

    while (token = next_token())
      case token.type
      when TokenType::LPAREN
        stack.push(token)
      when TokenType::RPAREN
        stack.empty? ? raise_unmatched_paren_error(token) : stack.pop()
      end

      @tokens << token
    end

    unless stack.empty?
      raise_unmatched_paren_error(stack.last)
    end

    @tokens << Token.new(TokenType::EOF, '', @line, @column) # Add a end of file token to be used by the parser
    return @tokens
  end

  private

  #
  # Raise a unmatched parenthesis error if a open or close paren is missing
  #
  # @param [Token] token The paren token that misses a open or close paren
  #
  def raise_unmatched_paren_error(token)
    line_num = token.line
    tmp_line = @string.each_line.to_a[line_num - 1] # Get the line where the error was

    # We have an unmatched parenthesis
    error_type = token.type == TokenType::LPAREN ? "opening" : "closing"
    raise UnmatchedParenthesisError, "Unmatched #{error_type} parenthesis at line #{line_num}, column #{token.column} in #{tmp_line}"
  end

  # Get the next token
  #
  # @return [Token | nil] Return the new token or nil if we have reached the end of the input string
  def next_token
    return nil if at_eof()

    # Skip whitespace
    while @string[@position] =~ /\A\s/
      @line += 1 if @string[@position] == "\n" # New line found, update line value
      @column = @string[@position] == "\n" ? 1 : @column + 1 # New line found we want to reset column else add 1
      @position += 1 # Increase our position in the string
    end

    # Update the current line being parsed
    @current_line = @string.lines[@line - 1]

    @logger.debug("Parsing token at line #{@line}, column #{@column}, Token: #{@string[@position]}")

    # If we have found a comment, handle it and recursively call next_token
    if @string[@position] == '#'
      @logger.debug('Found comment token')
      while @string[@position] != "\n"
        @position += 1
        return nil if at_eof # We have reached the end of file
      end
      @position += 1 # Step past the new line
      @line += 1 # Increase line count to next
      @column = 1 # Reset to first index on line
      return next_token() # Call next_token to get the next token after the comment
    end

    # Match and handle tokens
    TOKEN_TYPES.each do |type, regex|
      if @string[@position..] =~ /\A#{regex}/
        return handle_token_match(type, $&)
      end
    end

    # If we get here, no token was matched, so we have an invalid character or token
    raise InvalidTokenError,
          "Invalid character or unexpected token at line #{@line}, column #{@column} in #{@current_line}"
  end

  ##################################################
  # 				       Helper functions			        	 #
  ##################################################

  # Create the token
  #
  # @param [String] match The value of the token we have matched
  # @param [String] type What type of token we want to create
  # @param [String] message The message we want to log
  # @param [Boolean] to_symbol If we want to convert the match to a symbol, Default: false
  #
  # @return [Token] A new Token if type @type
  def create_token(match, type, message, to_symbol = false)
    match = to_symbol ? match.to_sym : match

    # Handle unary operators
    if type == TokenType::UNARYOPERATOR
      # Check if the previous token is a binary operator, a left parenthesis or the beginning of the input
      previous_token = @tokens.last
      type = if previous_token.nil? ||
                previous_token.type == TokenType::LPAREN ||
                previous_token.type == TokenType::BINARYOPERATOR
               # This is a unary operator
               TokenType::UNARYOPERATOR
             else
               # This is a binary operator
               TokenType::BINARYOPERATOR
             end
    end

    token = Token.new(type, match, @line, @column)
    @logger.debug("#{message}: #{token.value}")
    advance(token.value.to_s.length)
    token
  end

  #
  # Handles a token match
  #
  # @param [Symbol] type What type of token this is
  # @param [String] match The match found
  #
  # @return [Token] The token created
  #
  def handle_token_match(type, match)
    return case type
          when :integer
            handle_number_match(match)
          when :string
            handle_string_match(match)
          when :identifier
            handle_identifier_match(match)
          else
            create_token(match, TokenType.const_get(type.to_s.upcase), "Found #{type} token", true)
          end
  end

  #
  # Handles when we have matched a number
  #
  # @param [String] match The value of the token we have matched
  #
  # @return [Token] A new number token
  def handle_number_match(match)
    # Check for whitespace between two numbers
    if @string[@position + match.length..] =~ /\A\s*\d+/
      raise InvalidTokenError,
            "Unexpected token, number separeted by whitespace at line #{@line}, column #{@column} in #{@current_line}"
    end

    # Check if we have a float
    return create_token(match.to_f, TokenType::FLOAT, 'Found float token') if match.include?('.')


    # Check for if number has trailing digits when starting with 0
    if match.length > 1 && match[0].to_i.zero?
      raise InvalidTokenError, "Invalid octal digit at line #{@line}, column #{@column} in #{@current_line}"
    end

    return create_token(match.to_i, TokenType::INTEGER, 'Found integer token')
  end

  #
  # Handles when we have matched a string
  #
  # @param [String] match The value of the token we have matched
  #
  # @return [Token] A new string token
  def handle_string_match(match)
    # TODO: Add support for escaping chars
    match = match[1..-2]
    tok = create_token(match.to_s, TokenType::STRING, 'Found string token')
    advance(2) # Advance for the quotes since we don't save them
    tok
  end

  #
  # Handle when we have matched a identifier
  #
  # @param [String] match The value of the token we have matched
  #
  # @return [Token] A new identifier token
  def handle_identifier_match(match)
    # Check if it is a keyword
    return create_token(match, KEYWORDS[match.to_sym], 'Found keyword token') if KEYWORDS.key?(match.to_sym)

    # If not it is a user defined keyword
    return create_token(match, TokenType::IDENTIFIER, 'Found identifier token')
  end

  #
  # Advance where we are in the string
  # @param [int] length How far we should advance, Default: 1
  def advance(length = 1)
    @position += length
    @column += length
  end

  #
  # Check if we have reached the end of the input string
  #
  # @return [Boolean] If we have reach the end of the input string
  def at_eof
    return @position >= @string.length
  end
end
