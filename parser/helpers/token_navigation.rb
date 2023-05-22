#
# All the navigation helper for the parser
# These functions are used to navigate through the list of tokens
#
module TokenNavigation
	private
	# Check if we are not at the end of file
  #
  # @return [Boolean] Return of we are at the end of file or not
  def not_eof
    return at().type != Utilities::TokenType::EOF
  end

  # Get what token we are at
  #
  # @return [Token] What token we have right now
  def at
    return @tokens.first
  end

  def next_token
    return @tokens[1]
  end

  # Eat the next token
  #
  # @return [Token] The token eaten
  def eat
    @logger.debug("Eating token: #{at()}")
    token = @tokens.shift()
    @location = token.position
    return token
  end

  # Eat the next token and make sure we have eaten the correct type
  #
  # @param token_types [Array] A list of token which we can expect
  #
  # @return [Token] Returns the expected token
  def expect(*token_types)
    token = eat() # Get the token

    if token_types.include?(token.type)
      return token
    end
    raise "Line:#{@location}: Error: Expected a token of type #{token_types.join(' or ')}, but found #{token.type} instead. #{token}"
  end
end