require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterString < Test::Unit::TestCase
  def setup
    @interpreter = Interpreter.new
    @env = Enviroment.new
  end

  def test_evaluate_string_literal
    # Test string literal
    ast = StringLiteral.new('Hello, world!')
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(StringVal, result)
    assert_equal('Hello, world!', result.value)

    # Test empty string literal
    ast = StringLiteral.new('')
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(StringVal, result)
    assert_equal('', result.value)
  end

  def test_evaluate_string_concatenation
    # Test string concatenation
    ast = BinaryExpr.new(StringLiteral.new('Hello'), :+, StringLiteral.new('world!'))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(StringVal, result)
    assert_equal('Helloworld!', result.value)

    # Test concatenation of a string with a number
    # ast = BinaryExpr.new(StringLiteral.new("The answer is "), :+, NumericLiteral.new(42))
    # result = @interpreter.evaluate(ast, @env)
    # assert_instance_of(StringVal, result)
    # assert_equal("The answer is 42", result.value)
  end

  def test_evaluate_string_multiplication
    ast = BinaryExpr.new(StringLiteral.new('Hello'), :*, NumericLiteral.new(3))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(StringVal, result)
    assert_equal('HelloHelloHello', result.value)
  end

  def test_evaluate_string_comparison
    # Test string equality comparison
    ast = BinaryExpr.new(StringLiteral.new('hello'), :==, StringLiteral.new('hello'))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    ast = BinaryExpr.new(StringLiteral.new('hello'), :==, StringLiteral.new('byeee'))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)

    # Test string inequality comparison
    ast = BinaryExpr.new(StringLiteral.new('hello'), :!=, StringLiteral.new('world'))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    ast = BinaryExpr.new(StringLiteral.new('hello'), :!=, StringLiteral.new('hello'))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)
  end

  def test_evaluate_string_with_escape_chars
    ast = StringLiteral.new('hello \n bye')
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(StringVal, result)
    assert_equal('hello \n bye', result.value)
  end
end
