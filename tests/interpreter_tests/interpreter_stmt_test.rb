require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterStatement < Test::Unit::TestCase
  def setup
    @interpreter = Interpreter.new
    @env = Enviroment.new
  end

  def test_evaluate_if_statment
    # Test a if evaling to true
    ast = IfStatement.new([NumericLiteral.new(3)],
                          LogicalAndExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(true)), nil, nil)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(3, result.value)

    # Test a if evaling to false
    ast = IfStatement.new([NumericLiteral.new(3)], BooleanLiteral.new(false), nil, nil)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NullVal, result)
    assert_equal('null', result.value)

    # Test a if evaling to false
    condition = BinaryExpr.new(NumericLiteral.new(5), :>, NumericLiteral.new(3))
    body = [BinaryExpr.new(NumericLiteral.new(3), :+, NumericLiteral.new(3))]
    ast = IfStatement.new(body, condition, nil, nil)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(6, result.value)
  end

  def test_evaluate_elsif_statment
    # Test with single elsif
    elsifs = [ElsifStatement.new([NumericLiteral.new(4)], LogicalAndExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(true)))]
    ast = IfStatement.new([NumericLiteral.new(3)],
                          LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true)), nil, elsifs)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(4, result.value)

    # Test with multiple elsif
    elsifs = [ElsifStatement.new([NumericLiteral.new(4)], LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true))),
              ElsifStatement.new([NumericLiteral.new(6)], LogicalAndExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(true)))]
    ast = IfStatement.new([NumericLiteral.new(3)],
                          LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true)), nil, elsifs)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(6, result.value)
  end

  def test_evaluate_else_statment
    # Test else
    ast = IfStatement.new([NumericLiteral.new(3)], BooleanLiteral.new(false), [NumericLiteral.new(45)], nil)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(45, result.value)

    # Test a if evaling to false and else running
    condition = BinaryExpr.new(NumericLiteral.new(5), :<, NumericLiteral.new(3))
    body = [BinaryExpr.new(NumericLiteral.new(5), :+, NumericLiteral.new(3))]
    elsif_stmts = [ElsifStatement.new([NumericLiteral.new(4)], LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true))),
              ElsifStatement.new([NumericLiteral.new(6)], LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true)))]
    else_body = [BinaryExpr.new(NumericLiteral.new(5), :-, NumericLiteral.new(3))]
    ast = IfStatement.new(body, condition, else_body, elsif_stmts)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(2, result.value)
  end

  def test_evaluate_program
    # Declare variables
    ast1 = VarDeclaration.new(false, 'x', 'int', NumericLiteral.new(5))
    ast2 = VarDeclaration.new(false, 'y', 'int', NumericLiteral.new(10))

    # Assign to variable x
    ast3 = AssignmentExpr.new(NumericLiteral.new(7), Identifier.new('x'))

    # Calculate z = x + y
    ast4 = BinaryExpr.new(Identifier.new('x'), :+, Identifier.new('y'))
    ast5 = VarDeclaration.new(false, 'z', 'int', ast4)

    # Calculate t = z * 2
    ast6 = BinaryExpr.new(Identifier.new('z'), :*, NumericLiteral.new(2))
    ast7 = VarDeclaration.new(false, 't', 'int', ast6)

    # Create program
    program = Program.new([ast1, ast2, ast3, ast5, ast7])

    # Evaluate program
    result = @interpreter.evaluate(program, @env)
    assert_instance_of(NumberVal, result)

    # Check variables
    assert_equal(7, @env.variables['x'].value)
    assert_equal(10, @env.variables['y'].value)
    assert_equal(17, @env.variables['z'].value)
    assert_equal(34, @env.variables['t'].value)
  end
end
