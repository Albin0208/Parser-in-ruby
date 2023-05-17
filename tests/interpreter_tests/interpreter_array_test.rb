require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterArray < Test::Unit::TestCase
  def setup
    @parser = Parser.new
    @interpreter = Runtime::Interpreter.new
    @env = Runtime::Environment.new
  end

  def test_interpret_array_declaration
    input = "int[] a = int[]{1, 2, 3}"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_instance_of(Runtime::Values::ArrayVal, result)
    values = result.value
    assert_equal(3, values.length)
    assert_equal(1, values[0].value)
    assert_equal(2, values[1].value)
    assert_equal(3, values[2].value)
  end

  def test_interpret_array_access
    input = "
      int[] a = int[]{1, 2, 3}
      int b = a[1]
      b
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_equal(2, result.value)
  end

  def test_interpret_array_assignment
    input = "
      int[] a = int[]{1, 2, 3}
      a[1] = 5
      a[1]
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_equal(5, result.value)
  end

  def test_interpret_array_append
    input = "
      int[] a = int[]{}
      a.append(10)
      a.append(2)
      a[0]
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_equal(10, result.value)
  end

  def test_interpret_array_pop
    input = "
      int[] a = int[]{2, 10}
      a.pop()
      a[0]
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_equal(2, result.value)
  end

  def test_interpret_array_of_hashes
    input = "
      Hash<string, int>[] a = Hash<string, int>[]{Hash<string, int>{'a'=2}}
      a[0]
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_instance_of(Runtime::Values::HashVal, result)

    assert_equal(2, result.value['a'].value)
  end

  def test_interpret_array_length
    input = "
      int[] a = int[]{1, 2, 3}
      int length = a.length()
      length
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_equal(3, result.value)
  end
end
