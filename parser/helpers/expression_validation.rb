#
# All the expression valdiation helper functions for the parser
#
module ExpressionValidation
	private
	# Validate that we are trying to assign a correct type to our variable.
  #
  # @param [Expr] expression The expression we want to validate
  # @param [String] type What type we are trying to assign to
  def validate_assignment_type(expression, type)
    return unless [:NumericLiteral, :String, :Bool, :HashLiteral].include?(expression.type) # We can't know what type will be given until runtime of it is a func call and so on

    if !expression.instance_variable_defined?(:@value)
      if expression.type != NODE_TYPES[:CallExpr]
        validate_assignment_type(expression.left, type)
        validate_assignment_type(expression.right, type) if expression.instance_variable_defined?(:@right)
      end
      return
    end
    if expression.instance_of?(Nodes::ClassInstance)
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
            [NODE_TYPES[:Bool], NODE_TYPES[:Identifier]].include?(expression_type)
          when :string
            [NODE_TYPES[:String], NODE_TYPES[:Identifier]].include?(expression_type)
          else
            expression_type.to_sym == expected_type.to_sym
          end
  end
end