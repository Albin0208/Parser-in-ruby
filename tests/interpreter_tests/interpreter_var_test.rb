require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterVar < Test::Unit::TestCase
  def setup
    @parser = Parser.new
    @interpreter = Interpreter.new
    @env = Environment.new
  end

  def test_evaluate_var_declaration
    input = 'int x = 5'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(Values::NumberVal, @env.identifiers['x'])
    assert_equal(5, @env.identifiers['x'].value)

    # Test empty var declaration
    input = 'int empty'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal('null', result.value)
    assert_instance_of(Values::NullVal, @env.identifiers['empty'])
    assert_equal('null', @env.identifiers['empty'].value)

    input = 'const int t = 5'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(Values::NumberVal, @env.identifiers['t'])
    assert_equal(5, @env.identifiers['t'].value)
    assert_true(@env.constants.include?('t'))

    input = 'float y = 5.34'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5.34, result.value)
    assert_instance_of(Values::NumberVal, @env.identifiers['y'])
    assert_equal(5.34, @env.identifiers['y'].value)

    input = 'bool b = true'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(true, result.value)
    assert_instance_of(Values::BooleanVal, @env.identifiers['b'])
    assert_equal(true, @env.identifiers['b'].value)

    input = "string str = 'Hello'"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal('Hello', result.value)
    assert_instance_of(Values::StringVal, @env.identifiers['str'])
    assert_equal('Hello', @env.identifiers['str'].value)
  end

  def test_evaluate_retrieval_of_var
    @env.declare_var('x', Values::NumberVal.new(10, :int), 'int', 1, false) # Declare the var in the env

    input = 'x'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_instance_of(Values::NumberVal, result)
    assert_equal(10, result.value)
  end

  def test_evaluate_var_assignment_expr
    @env.declare_var('x', Values::NumberVal.new(10, :int), 'int', 1, false)
    input = 'x = 5'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(Values::NumberVal, @env.identifiers['x'])
    assert_equal(5, @env.identifiers['x'].value)
  end

  def test_evaluate_int_and_float_assignment_conversion
    @env.declare_var('x', Values::NumberVal.new(10, :int), 'int', 1, false)
    input = 'x = 5.3'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(Values::NumberVal, @env.identifiers['x'])
    assert_equal(5, @env.identifiers['x'].value)

    @env.declare_var('y', Values::NumberVal.new(10.3, :float), 'float', 1, false)
    input = 'y = 5'
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(5, result.value)
    assert_instance_of(Values::NumberVal, @env.identifiers['x'])
    assert_equal(5.0, @env.identifiers['x'].value)
  end

  def test_evaluate_invalid_var_assignment_expr
    @env.declare_var('x', Values::NumberVal.new(10, :int), 'int', 1, false)
    assert_raise(RuntimeError) { @env.declare_var('x', Values::NumberVal.new(10, :int), false, 'int') }

    # Test reassign of const value
    @env.declare_var('c', Values::NumberVal.new(10, :int), 'int', 1, true)
    input = 'c = 5'
    ast = @parser.produce_ast(input)
    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }

    # Test assign of another type to int x
    input = 'x = true'
    ast = @parser.produce_ast(input)
    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end
end
