require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterStatement < Test::Unit::TestCase
  def setup
    @parser = Parser.new()
    @interpreter = Interpreter.new
    @env = Environment.new
  end

  def test_evaluate_if_statment
    # Test a if evaling to true
    input = "if true && true { 3 }"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(3, result.value)

    # Test a if evaling to false
    input = "if false { 3 }"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NullVal, result)
    assert_equal('null', result.value)

    # Test a if evaling to false
    input = "if 5 > 3 { 3 + 3 }"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(6, result.value)
  end

  def test_evaluate_elsif_statment
    # Test with single elsif
    input = "if false { 3 } elsif true { 4 }"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(4, result.value)

    # Test with multiple elsif
    input = "if false && true { 3 } elsif false { 4 } elsif true { 6 }"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(6, result.value)
  end

  def test_evaluate_else_statment
    # Test else
    input = "if false { 3 } else { 45 }"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(45, result.value)

    # Test a if evaling to false and else running
    input = "if 5 < 3 {3} elsif false { 4 } elsif 6 > 100 { 10 } else { 2 }"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)
    assert_equal(2, result.value)
  end

  def test_evaluate_program
    input = "int x = 5 
             int y = 10
             x = 7
             int z = x + y
             int t = z * 2"
    ast = @parser.produce_ast(input)

    # Evaluate program
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(NumberVal, result)

    # Check variables
    assert_equal(7, @env.identifiers['x'].value)
    assert_equal(10, @env.identifiers['y'].value)
    assert_equal(17, @env.identifiers['z'].value)
    assert_equal(34, @env.identifiers['t'].value)
  end
end
