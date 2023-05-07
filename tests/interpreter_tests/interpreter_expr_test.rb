require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterExpr < Test::Unit::TestCase
  def setup
    @parser = Parser.new
    @interpreter = Interpreter.new
    @env = Environment.new
  end

  def test_evaluate_numeric_literal
    input = '42'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(42, result.value)

    # Test negative number
    input = '-42'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(-42, result.value)
  end

  def test_evaluate_identifier
    @env.declare_var('x', Values::NumberVal.new(10, :int), 'int', false)
    input = 'x'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(10, result.value)
  end

  def test_evaluate_logical_and
    # Test true && true
    input = 'true && true'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    # Test true && false
    input = 'true && false'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)

    # Test false && true
    input = 'false && true'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)

    # Test false && false
    input = 'false && false'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)
  end

  def test_evaluate_logical_or
    # Test true || true
    input = 'true || true'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    # Test true || false
    input = 'true || false'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    # Test false || true
    input = 'false || true'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    # Test false || false
    input = 'false || false'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)
  end

  def test_evaluate_unary_expr
    # Test unary minus
    input = '-5'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(-5, result.value)

    # Test logical negation
    input = '!true'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)
  end

  def test_evaluate_binary_expr
    input = '3 - 10'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(-7, result.value)

    input = '3 * 10'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(30, result.value)

    input = '3.0 / 10'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(0.3, result.value)

    input = '3 % 2'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(1, result.value)

    # Test for precedence
    input = '3 + 10 * 2'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(23, result.value)
  end

  def test_evaluate_binary_expr_comparison
    input = '3 < 10'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    input = '3 > 10'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)

    input = '3.0 == 10'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(false, result.value)

    input = '3 != 2'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    input = '3 >= -4'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    input = '3 >= 3'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    input = '3 <= 3'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)

    input = '3 <= 10'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::BooleanVal, result)
    assert_equal(true, result.value)
  end
end
