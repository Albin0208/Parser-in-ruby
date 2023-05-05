module ParserHelpers
	private

  #
  # Recursivly check if the statment has any return statments
  #
  # @param [Stmt] stmt The statement to check
  #
  # @return [Boolean] True if ReturnStmt exits otherwise false
  #
  def has_return_statement?(stmt)
    if stmt.instance_of?(ReturnStmt)
      return true
    elsif stmt.instance_variable_defined?(:@body)
      return stmt.body.any? { |s| has_return_statement?(s) }
    else
      return false
    end
  end
end