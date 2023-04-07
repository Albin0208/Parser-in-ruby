require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterFunctions < Test::Unit::TestCase
  def setup
    @parser = Parser.new()
    @interpreter = Interpreter.new
    @env = Environment.new
  end

 def test_evaluate_func_declaration
  # Test void function
  input = "func void test() {}"
  ast = @parser.produce_ast(input)
  @interpreter.evaluate(ast, @env)
  identifiers = @env.identifiers
  assert_equal(1, identifiers.length)
  assert_true(identifiers.key?("test"))
  test_func = identifiers["test"]
  assert_instance_of(FuncDeclaration, test_func)
  assert_equal('void', test_func.type_specifier)
  assert_empty(test_func.params)
  assert_empty(test_func.body)

  # Test int function
  input = "func int test2() { return 2 }"
  ast = @parser.produce_ast(input)
  @interpreter.evaluate(ast, @env)
  identifiers = @env.identifiers
  assert_equal(2, identifiers.length)
  assert_true(identifiers.key?("test2"))
  test_func = identifiers["test2"]
  assert_instance_of(FuncDeclaration, test_func)
  assert_equal('int', test_func.type_specifier)
  assert_empty(test_func.params)
  assert_equal(1, test_func.body.length)
 end

 def test_evaluate_func_declaration_with_params
  input = "func int add(int a, int b) { return a + b }"
  ast = @parser.produce_ast(input)
  @interpreter.evaluate(ast, @env)
  identifiers = @env.identifiers
  assert_equal(1, identifiers.length)
  assert_true(identifiers.key?("add"))
  test_func = identifiers["add"]
  assert_instance_of(FuncDeclaration, test_func)
  assert_equal('int', test_func.type_specifier)
  assert_equal(2, test_func.params.length)
  assert_instance_of(VarDeclaration, test_func.params[0])
  assert_instance_of(VarDeclaration, test_func.params[1])
  assert_instance_of(ReturnStmt, test_func.body[0])
 end

 def test_evaluate_func_call
  input = "func int test() { return 2 }
           test()"
  ast = @parser.produce_ast(input)
  result = @interpreter.evaluate(ast, @env)
  assert_instance_of(NumberVal, result)
  assert_equal(2, result.value)
 end

 def test_evaluate_func_call_with_params
  input = "func int add(int a, int b) { return a + b }
           add(2, 3)"
  ast = @parser.produce_ast(input)
  result = @interpreter.evaluate(ast, @env)
  assert_instance_of(NumberVal, result)
  assert_equal(5, result.value)
 end
end
