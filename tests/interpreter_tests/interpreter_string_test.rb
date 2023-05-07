require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterString < Test::Unit::TestCase
  def setup
    @parser = Parser.new
    @interpreter = Interpreter.new
    @env = Environment.new
  end

  def test_evaluate_string_literal
    # Test string literal
    input = "'Hello, world!'"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::StringVal, result)
    assert_equal('Hello, world!', result.value)

    # Test empty string literal
    input = "''"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::StringVal, result)
    assert_equal('', result.value)
  end

  def test_evaluate_string_concatenation
    # Test string concatenation
    input = "'Hello' + 'world!'"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::StringVal, result)
    assert_equal('Helloworld!', result.value)

    # Test concatenation of a string with a number
    # ast = BinaryExpr.new(StringLiteral.new("The answer is "), :+, NumericLiteral.new(42))
    # result = @interpreter.evaluate(ast, @env)
    # assert_instance_of(Values::StringVal, result)
    # assert_equal("The answer is 42", result.value)
  end

  def test_evaluate_string_multiplication
    input = "'Hello' * 3"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::StringVal, result)
    assert_equal('HelloHelloHello', result.value)
  end

  def test_evaluate_string_comparison
    # Test string equality comparison
    input = "'hello' == 'hello'"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    input = "'hello' == 'byeee'"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)

    # Test string inequality comparison
    input = "'Hello' != 'world!'"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    input = "'Hello' != 'Hello'"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)
  end

  def test_evaluate_string_with_escape_chars
    input = '"hello \\\n bye"'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::StringVal, result)
    assert_equal('hello \n bye', result.value)
  end
end
