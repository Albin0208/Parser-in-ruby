require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterMethodCall < Test::Unit::TestCase
  def setup
    @parser = Parser.new()
    @interpreter = Interpreter.new
    @env = Environment.new
    @env.setup_native_functions()
  end

  def test_evaluate_print_method
    input = "print(2)"

    ast = @parser.produce_ast(input)

    @interpreter.evaluate(ast, @env)
  end

  def test_evaluate_type_method
    input = "1.type()"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal("int", result.to_s)

    input = "1.0.type()"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal("float", result.to_s)

    input = "'hej'.type()"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal("string", result.to_s)

    input = "true.type()"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal("boolean", result.to_s)

    input = "null.type()"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal("null", result.to_s)
  end

  def test_evaluate_string_length
    input = "'hej'.length()"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(3, result.value)
  end

  def test_evaluate_string_length_with_binary
    input = "'hej'.length() + 4"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(7, result.value)

    input = "4 + 'hej'.length()"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(7, result.value)

    input = "'hej'.length() + 'hejsan'.length()"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(9, result.value)
  end
end
