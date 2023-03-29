# frozen_string_literal: true

require 'English'
require 'logger'

require_relative 'token'
require_relative '../errors/errors'
require_relative '../token_type'

TOKEN_TYPES = {
  integer: /\A\d+(\.\d+)?/,
  string: /\A"([^"]*)"/,
  operator: %r{\A[+\-*/%]},
  unaryOperator: /\A[-+!]/,
  logical: /\A((&&)|(\|\|))/,
  comparators: /\A((>=)|(<=)|(==)|(!=)|(<)|(>))/,
  lparen: /\A\(/,
  rparen: /\A\)/,
  lbrace: /\A\{/,
  rbrace: /\A\}/,
  assign: /\A=/,
  identifier: /\A([a-z]|_[a-z])\w*/i,
  separators: /\A,/
}.freeze

KEYWORDS = {
  'const' => TokenType::CONST,
  'func' => TokenType::FUNC,
  'if' => TokenType::IF,
  'else' => TokenType::ELSE,
  'true' => TokenType::BOOLEAN,
  'false' => TokenType::BOOLEAN,
  'null' => TokenType::NULL,

  # Type Specifiers
  'int' => TokenType::TYPE_SPECIFIER,
  'float' => TokenType::TYPE_SPECIFIER,
  'bool' => TokenType::TYPE_SPECIFIER,
  'string' => TokenType::TYPE_SPECIFIER
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
    open_parens = 0 # Keep track of number of parens opened
    while (token = next_token)
      case token.type
      when TokenType::LPAREN
        open_parens += 1
      when TokenType::RPAREN
        if open_parens.zero?
          # We have got a closing parenthesis without a opening one
          raise UnmatchedParenthesisError, "Unmatched opening parenthesis for closing parenthesis at line
						  #{token.line}, column #{token.column} in #{@current_line}"
        else
          open_parens -= 1
        end
      end
      @tokens << token
    end

    if open_parens.positive?
      last_open_paren = @tokens.select { |t| t.type == TokenType::LPAREN }.last # Get the last opened parenthesis

      line = @string.each_line.to_a[last_open_paren.line - 1] # Get the line where the error was
      # We have more opening parentheses than closing ones
      raise UnmatchedParenthesisError, "Unmathced closing parenthesis for opening parenthesis at line
				  #{last_open_paren.line}, column #{last_open_paren.column} in #{line}"
    end

    @tokens << Token.new(TokenType::EOF, '', @line, @column) # Add a end of file token to be used by the parser
    @tokens
  end

  private

  # Get the next token
  #
  # @return [Token | nil] Return the new token or nil if we have reached the end of the input string
  def next_token
    return nil if at_eof

    @current_line = @string[0..@string.length].match(/^\s*.*$/)

    # Skip whitespace
    while @string[@position] =~ /\A\s/
      @line += 1 if @string[@position] == "\n" # New line found, update line value
      @column = @string[@position] == "\n" ? 1 : @column + 1 # New line found we want to reset column else add 1
      @position += 1 # Increase our position in the string
    end

    @logger.debug("Parsing token at line #{@line}, column #{@column}, Token: #{@string[@position]}")

    # Add check for comments
    if @string[@position] =~ /\A#/
      @logger.debug('Found comment token')
      while @string[@position] != /\n/
        @position += 1
        return nil if at_eof # We have reached the end of file
      end
      @line += 1
      @column = 1 # Reset to first index on line
      return next_token # Call next_token to get the next token after the comment
    end

    token_matchers = [
      # [TOKEN_TYPES[:integer], TokenType::NUMBER],
      # [TOKEN_TYPES[:string], TokenType::STRING],
      [TOKEN_TYPES[:comparators], TokenType::COMPARISON],
      [TOKEN_TYPES[:unaryOperator], TokenType::UNARYOPERATOR],
      [TOKEN_TYPES[:operator], TokenType::BINARYOPERATOR],
      [TOKEN_TYPES[:logical], TokenType::LOGICAL],
      [TOKEN_TYPES[:assign], TokenType::ASSIGN],
      [TOKEN_TYPES[:lparen], TokenType::LPAREN],
      [TOKEN_TYPES[:rparen], TokenType::RPAREN],
      [TOKEN_TYPES[:lbrace], TokenType::LBRACE],
      [TOKEN_TYPES[:rbrace], TokenType::RBRACE],
      [TOKEN_TYPES[:separators], TokenType::COMMA],
      # [TOKEN_TYPES[:identifier], TokenType::IDENTIFIER]
    ]

    # Go through all simple tokens
    token_matchers.each do |pattern, type|
      if @string[@position..] =~ /\A#{pattern}/
        return create_token($LAST_MATCH_INFO[0], type, "Found #{type.to_s.downcase}", true)
      end
    end

    case @string[@position..]
    when TOKEN_TYPES[:integer]
      return handle_number_match($LAST_MATCH_INFO[0])
    when TOKEN_TYPES[:string]
      return handle_string_match($LAST_MATCH_INFO[0])
    when TOKEN_TYPES[:identifier]
      return handle_identifier_match($LAST_MATCH_INFO[0])
    end

    # If we get here, no token was matched, so we have an invalid character or token
    raise InvalidTokenError,
          "Invalid character or unexpected token at line #{@line}, column #{@column} in #{@current_line}"
  end

  ##################################################
  # 				Helper functions				 #
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

  def handle_whitespace
    if @string[@position] == "\n"
      @line += 1
      @column = 1
    else
      @column += 1
    end
    @position += 1
  end
  
  def handle_comment
    @logger.debug('Found comment token')
    while @string[@position] != /\n/
      @position += 1
      return nil if at_eof
    end
    @line += 1
    @column = 1
  end

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

    create_token(match.to_i, TokenType::INTEGER, 'Found integer token')
  end

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

  # Handle when we have matched a identifier
  #
  # @param [String] match The value of the token we have matched
  #
  # @return [Token] A new identifier token
  def handle_identifier_match(match)
    # Check if it is a keyword
    return create_token(match, KEYWORDS[match], 'Found keyword token') if KEYWORDS.key?(match)

    # # Create keyword token


    # If not it is a user defined keyword
    # # Create keyword token
    create_token(match, TokenType::IDENTIFIER, 'Found identifier token')
  end

  # Advance where we are in the string
  # @param [int] length How far we should advance, Default: 1
  def advance(length = 1)
    @position += length
    @column += length
  end

  # Check if we have reached the end of the input string
  #
  # @return [Boolean] If we have reach the end of the input string
  def at_eof
    @position >= @string.length
  end
end
