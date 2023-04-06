require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterExpr < Test::Unit::TestCase
  def setup
    @interpreter = Interpreter.new
    @env = Environment.new
  end

  def test_evaluate_numeric_literal
    ast = NumericLiteral.new(42)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(42, result.value)

    # Test negative number
    ast = NumericLiteral.new(-42)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(-42, result.value)
  end
  
  def test_evaluate_identifier
    @env.declare_var('x', NumberVal.new(10), 'int', false)
    ast = Identifier.new('x')
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(10, result.value)
  end

  def test_evaluate_logical_and
    # Test true && true
    ast = LogicalAndExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(true))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    # Test true && false
    ast = LogicalAndExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(false))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)

    # Test false && true
    ast = LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)

    # Test false && false
    ast = LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(false))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)
  end

  def test_evaluate_logical_or
    # Test true || true
    ast = LogicalOrExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(true))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    # Test true || false
    ast = LogicalOrExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(false))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    # Test false || true
    ast = LogicalOrExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    # Test false || false
    ast = LogicalOrExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(false))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)
  end

  def test_evaluate_unary_expr
    # Test unary minus
    ast = UnaryExpr.new(NumericLiteral.new(5), :-)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(-5, result.value)

    # Test logical negation
    ast = UnaryExpr.new(BooleanLiteral.new(true), :!)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)
  end

  def test_evaluate_binary_expr
    ast = BinaryExpr.new(NumericLiteral.new(3), :-, NumericLiteral.new(10))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(-7, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3), :*, NumericLiteral.new(10))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(30, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3.0), :/, NumericLiteral.new(10))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(0.3, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3), :%, NumericLiteral.new(2))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(1, result.value)

    # Test for precedence
    ast = BinaryExpr.new(NumericLiteral.new(3), :+,
                         BinaryExpr.new(NumericLiteral.new(10), :*, NumericLiteral.new(2)))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(23, result.value)
  end

  def test_evaluate_binary_expr_comparison
    ast = BinaryExpr.new(NumericLiteral.new(3), :<, NumericLiteral.new(10))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3), :>, NumericLiteral.new(10))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3.0), :==, NumericLiteral.new(10))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(false, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3), :"!=", NumericLiteral.new(2))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3), :>=, NumericLiteral.new(-4))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3), :>=, NumericLiteral.new(3))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3), :<=, NumericLiteral.new(3))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)

    ast = BinaryExpr.new(NumericLiteral.new(3), :<=, NumericLiteral.new(10))
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(BooleanVal, result)
    assert_equal(true, result.value)
  end
end