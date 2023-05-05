module ParserHelpers
	private
	# Check if we are not at the end of file
  #
  # @return [Boolean] Return of we are at the end of file or not
  def not_eof
    return at().type != TokenType::EOF
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
    @location = token.line
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
    raise "Line:#{@location}: Error: Expected a token of type #{token_types.join(' or ')}, but found #{token.type} instead"
  end

	# Determines whether a given key is present in a list of keys.
	#
	# @param key [StringLiteral, SymbolLiteral] the key to search for
	# @param keys [Array<StringLiteral, SymbolLiteral>] the list of keys to search
	# @return [Boolean] true if the key is present in the list of keys, false otherwise
	def key_in_hash?(key, keys)
		unless key.is_a?(StringLiteral) || key.is_a?(StringLiteral)
			return false
		end
		keys.each() { |k|
			return true if k.value == key.value
		}
		return false
	end

	# Validate that we are trying to assign a correct type to our variable.
  #
  # @param [Expr] expression The expression we want to validate
  # @param [String] type What type we are trying to assign to
  def validate_assignment_type(expression, type)
    return unless [:NumericLiteral, :String, :Boolean, :HashLiteral].include?(expression.type) # We can't know what type will be given until runtime of it is a func call and so on

    if !expression.instance_variable_defined?(:@value)
      if expression.type != NODE_TYPES[:CallExpr]
        validate_assignment_type(expression.left, type)
        validate_assignment_type(expression.right, type) if expression.instance_variable_defined?(:@right)
      end
      return
    end
    if expression.instance_of?(ClassInstance)
      expression = expression.value.symbol
    else
      expression = expression.type
    end

    unless valid_assignment_type?(expression, type)
      raise InvalidTokenError, "Line:#{@location}: Error: Can't assign #{expression} value to value of type #{type}"
    end
  end

  # Checks whether a given expression type is valid for a variable of a certain type.
  #
  # @param expression_type [String] What type the expression is
  # @param expected_type [String] The expected type for the expression
  #
  # @return [Boolean] true if the expression type is valid for the variable type otherwise false
  def valid_assignment_type?(expression_type, expected_type)
    return case expected_type.to_sym
          when :int, :float
            [NODE_TYPES[:NumericLiteral], NODE_TYPES[:Identifier]].include?(expression_type)
          when :bool
            [NODE_TYPES[:Boolean], NODE_TYPES[:Identifier]].include?(expression_type)
          when :string
            [NODE_TYPES[:String], NODE_TYPES[:Identifier]].include?(expression_type)
          else
            expression_type.to_sym == expected_type.to_sym
          end
  end

end