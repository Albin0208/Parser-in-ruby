require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreter < Test::Unit::TestCase
  def setup
    @interpreter = Interpreter.new
    @env = Enviroment.new
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

  def test_evaluate_if_statment
    # Test a if evaling to true
    ast = IfStatement.new([NumericLiteral.new(3)],
                          LogicalAndExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(true)), nil)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(3, result.value)

    # Test a if evaling to false
    ast = IfStatement.new([NumericLiteral.new(3)], BooleanLiteral.new(false), nil)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NullVal, result)
    assert_equal('null', result.value)

    # Test a if evaling to false
    condition = BinaryExpr.new(NumericLiteral.new(5), :>, NumericLiteral.new(3))
    body = [BinaryExpr.new(NumericLiteral.new(3), :+, NumericLiteral.new(3))]
    ast = IfStatement.new(body, condition, nil)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(6, result.value)
  end

  def test_evaluate_else_statment
    # Test else
    ast = IfStatement.new([NumericLiteral.new(3)], BooleanLiteral.new(false), [NumericLiteral.new(45)])
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(45, result.value)

    # Test a if evaling to false and else running
    condition = BinaryExpr.new(NumericLiteral.new(5), :<, NumericLiteral.new(3))
    body = [BinaryExpr.new(NumericLiteral.new(5), :+, NumericLiteral.new(3))]
    else_body = [BinaryExpr.new(NumericLiteral.new(5), :-, NumericLiteral.new(3))]
    ast = IfStatement.new(body, condition, else_body)
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
