require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterVar < Test::Unit::TestCase
  def setup
    @interpreter = Interpreter.new
    @env = Enviroment.new
  end

  def test_evaluate_var_declaration
    ast = VarDeclaration.new(false, 'x', 'int', NumericLiteral.new(5))
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(NumberVal, @env.variables['x'])
    assert_equal(5, @env.variables['x'].value)

    # Test empty var declaration
    ast = VarDeclaration.new(false, 'empty', 'int')
    result = @interpreter.evaluate(ast, @env)
    assert_equal('null', result.value)
    assert_instance_of(NullVal, @env.variables['empty'])
    assert_equal('null', @env.variables['empty'].value)

    ast = VarDeclaration.new(true, 't', 'int', NumericLiteral.new(5))
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(NumberVal, @env.variables['t'])
    assert_equal(5, @env.variables['t'].value)
    assert_true(@env.constants.include?('t'))

    ast = VarDeclaration.new(false, 'y', 'float', NumericLiteral.new(5.34))
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5.34, result.value)
    assert_instance_of(NumberVal, @env.variables['y'])
    assert_equal(5.34, @env.variables['y'].value)

    ast = VarDeclaration.new(false, 'b', 'bool', BooleanLiteral.new(true))
    result = @interpreter.evaluate(ast, @env)
    assert_equal(true, result.value)
    assert_instance_of(BooleanVal, @env.variables['b'])
    assert_equal(true, @env.variables['b'].value)

    ast = VarDeclaration.new(false, 'str', 'string', StringLiteral.new("Hello"))
    result = @interpreter.evaluate(ast, @env)
    assert_equal('Hello', result.value)
    assert_instance_of(StringVal, @env.variables['str'])
    assert_equal('Hello', @env.variables['str'].value)
  end

  def test_evaluate_retrieval_of_var
    @env.declare_var('x', NumberVal.new(10), 'int', false)
    ast = Identifier.new('x')
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(10, result.value)
  end

  def test_evaluate_var_assignment_expr
    @env.declare_var('x', NumberVal.new(10), 'int', false)
    ast = AssignmentExpr.new(NumericLiteral.new(5), Identifier.new('x'))
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(NumberVal, @env.variables['x'])
    assert_equal(5, @env.variables['x'].value)
  end

  def test_evaluate_int_and_float_assignment_conversion
    @env.declare_var('x', NumberVal.new(10), 'int', false)
    ast = AssignmentExpr.new(NumericLiteral.new(5.3), Identifier.new('x'))
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(NumberVal, @env.variables['x'])
    assert_equal(5, @env.variables['x'].value)

    @env.declare_var('y', NumberVal.new(10.3), 'float', false)
    ast = AssignmentExpr.new(NumericLiteral.new(5), Identifier.new('x'))
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(NumberVal, @env.variables['x'])
    assert_equal(5.0, @env.variables['x'].value)
  end

  def test_evaluate_invalid_var_assignment_expr
    @env.declare_var('x', NumberVal.new(10), 'int', false)
    assert_raise(RuntimeError) { @env.declare_var('x', NumberVal.new(10), false, 'int') }

    # Test reassign of const value
    @env.declare_var('c', NumberVal.new(10), 'int', true)
    ast = AssignmentExpr.new(NumericLiteral.new(5), Identifier.new('c'))
    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }

    # Test assign of another type to int x
    ast = AssignmentExpr.new(BooleanLiteral.new(true), Identifier.new('x'))
    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end
end
