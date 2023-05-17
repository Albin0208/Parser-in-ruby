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

  def test_interpret_nested_array_declaration
    input = "int[][] a = int[][]{int[]{1, 2}}"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
  
    assert_instance_of(Runtime::Values::ArrayVal, result)
    values = result.value
    assert_equal(1, values.length) # Outer array length
    inner_array = values[0].value
    assert_equal(2, inner_array.length) # Inner array length
    assert_equal(1, inner_array[0].value) # Inner array value at index 0
    assert_equal(2, inner_array[1].value) # Inner array value at index 1
  end

  def test_interpret_access_nested_array_value
    input = "
      int[][] a = int[][]{int[]{1, 2, 3}, int[]{4, 5, 6}, int[]{7, 8, 9}}
      int value1 = a[0][1]
      int value2 = a[1][2]
      int value3 = a[2][0]
      int value4 = a[2][2]
      value1 + value2 + value3 + value4
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
  
    assert_equal(24, result.value)
  end
  

  def test_interpret_triple_nested_array_declaration
    input = "int[][][] a = int[][][]{int[][]{int[]{1, 2}, int[]{3, 4}}, int[][]{int[]{5, 6}, int[]{7, 8}}}"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
  
    assert_instance_of(Runtime::Values::ArrayVal, result)
    values = result.value
    assert_equal(2, values.length) # Outer array length
    outer_inner_array_1 = values[0].value
    outer_inner_array_2 = values[1].value
  
    assert_equal(2, outer_inner_array_1.length) # First outer inner array length
    assert_equal(2, outer_inner_array_2.length) # Second outer inner array length
  
    assert_equal(1, outer_inner_array_1[0].value[0].value) # First outer inner array, first inner array, first value
    assert_equal(2, outer_inner_array_1[0].value[1].value) # First outer inner array, first inner array, second value
    assert_equal(3, outer_inner_array_1[1].value[0].value) # First outer inner array, second inner array, first value
    assert_equal(4, outer_inner_array_1[1].value[1].value) # First outer inner array, second inner array, second value
  
    assert_equal(5, outer_inner_array_2[0].value[0].value) # Second outer inner array, first inner array, first value
    assert_equal(6, outer_inner_array_2[0].value[1].value) # Second outer inner array, first inner array, second value
    assert_equal(7, outer_inner_array_2[1].value[0].value) # Second outer inner array, second inner array, first value
    assert_equal(8, outer_inner_array_2[1].value[1].value) # Second outer inner array, second inner array, second value
  end

  def test_interpret_triple_nested_array_access
    input = "
      int[][][] a = int[][][]{int[][]{int[]{1, 2}, int[]{3, 4}}, int[][]{int[]{5, 6}, int[]{7, 8}}}
      int value = a[1][0][1]
      value
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
  
    assert_equal(6, result.value)
  end
  
  def test_interpret_triple_nested_array_assignment
    input = "
      int[][][] a = int[][][]{int[][]{int[]{1, 2}, int[]{3, 4}}, int[][]{int[]{5, 6}, int[]{7, 8}}}
      a[0][1][0] = 10
      a[0][1][0]
    "
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
  
    assert_equal(10, result.value)
  end

  def test_interpret_nested_array_errors
    input = "
      int[][] a = int[][]{int[]{1, 2, 3}, int[]{4, 5}, int[]{6, 7, 8, 9}}
      int value1 = a[0][3]  # Accessing non-existent element
      int value2 = a[1][0]  # Accessing non-existent element
      int value3 = a[2][2]  # Accessing correct element
      value1 + value2 + value3
    "
    ast = @parser.produce_ast(input)
  
    # Error: Accessing non-existent element in the nested array
    assert_raise(RuntimeError) do
      @interpreter.evaluate(ast, @env)
    end
  
    input = "
      int[][] a = int[][]{int[]{1, 2, 3}, int[]{4, 5, 6}, int[]{7, 8, 'nine'}}
      int value1 = a[0][0]  # Accessing correct element
      int value2 = a[2][2]  # Accessing element with different type
      value1 + value2
    "
    ast = @parser.produce_ast(input)
  
    # Error: Accessing element with different type in the nested array
    assert_raise(RuntimeError) do
      @interpreter.evaluate(ast, @env)
    end
  end
  
end
