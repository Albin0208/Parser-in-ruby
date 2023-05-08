require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterEnv < Test::Unit::TestCase
  def setup
    @parser = Parser.new
    @interpreter = Runtime::Interpreter.new
    @env = Runtime::Environment.new
  end

  def test_evaluate_var_declared_in_if
    input = "if true { int a = 2 }
             a"
    ast = @parser.produce_ast(input)
    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end

  def test_evaluate_redeclaring_var_int_if
    input = "int a = 2
             if true { int a = 2 }"
    ast = @parser.produce_ast(input)
    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end

  def test_evaluate_changing_var_in_if
    input = "int a = 2
             if true { a = 20 }
             a"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_equal(20, result.value)
  end
end
