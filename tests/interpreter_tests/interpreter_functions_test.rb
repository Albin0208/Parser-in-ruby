require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterFunctions < Test::Unit::TestCase
  def setup
    @interpreter = Interpreter.new
    @env = Environment.new
  end

 def test_evaluate_func_declaration
  # Test void function
  ast = FuncDeclaration.new("void", "test", [], [], nil)
  @interpreter.evaluate(ast, @env)
  identifiers = @env.identifiers
  assert_equal(1, identifiers.length)
  assert_true(identifiers.key?("test"))
  test_func = identifiers["test"]
  assert_instance_of(FuncDeclaration, test_func)
  assert_equal('void', test_func.type_specifier)
  assert_empty(test_func.params)
  assert_empty(test_func.body)
  assert_nil(test_func.return_stmt)

  # Test int function
  return_stmt = ReturnStmt.new(NumericLiteral.new(2))
  ast = FuncDeclaration.new("int", "test2", [], [return_stmt], return_stmt)
  @interpreter.evaluate(ast, @env)
  identifiers = @env.identifiers
  assert_equal(2, identifiers.length)
  assert_true(identifiers.key?("test2"))
  test_func = identifiers["test2"]
  assert_instance_of(FuncDeclaration, test_func)
  assert_equal('int', test_func.type_specifier)
  assert_empty(test_func.params)
  assert_equal(1, test_func.body.length)
  assert_equal(return_stmt, test_func.return_stmt)
 end

 def test_evaluate_func_call
  return_stmt = ReturnStmt.new(NumericLiteral.new(2))
  ast = Program.new([FuncDeclaration.new("int", 'test', [], [return_stmt], return_stmt), 
         CallExpr.new(Identifier.new('test'), [])])
  result = @interpreter.evaluate(ast, @env)
  assert_instance_of(NumberVal, result)
  assert_equal(2, result.value)
 end
end
