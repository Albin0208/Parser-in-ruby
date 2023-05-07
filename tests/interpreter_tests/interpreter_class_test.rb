require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterClass < Test::Unit::TestCase
  def setup
    @parser = Parser.new
    @interpreter = Runtime::Interpreter.new
    @env = Runtime::Environment.new
  end

  def test_class_declaration
    input = "class MyClass {
                int x = 5
                func int my_func() {
                  return x
                }
              }"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('MyClass').class, Nodes::ClassDeclaration)
    assert_equal(@env.lookup_identifier('MyClass').member_variables.first.value.value, 5)
    assert_equal(@env.lookup_identifier('MyClass').member_functions.first.identifier, 'my_func')
  end

  def test_class_instantiation
    input = "class MyClass {
                int x = 5
                func int my_func() {
                  return x
                }
              }

              MyClass obj = new MyClass()"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('obj').class, Runtime::Values::ClassVal)
    assert_equal(@env.lookup_identifier('obj').type.to_s, @env.lookup_identifier('MyClass').class_name.symbol)
  end

  def test_const_class_property_access
    input = "class MyClass {
                int x = 5
                func void add(int a) {
                  x += a
                }
              }

              const MyClass obj = new MyClass()
              obj.add(5)
              obj.x"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    assert_true(@env.constants.member?('obj'))

    assert_equal(10, result.value)
  end

  def test_const_class_instantiation_and_reassign
    input = "class MyClass {
                int x = 5
                func int my_func() {
                  return x
                }
              }

              const MyClass obj = new MyClass()
              obj = new MyClass()"
    ast = @parser.produce_ast(input)
    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end

  def test_method_call
    input = "class MyClass {
                int x = 5
                func int my_func() {
                  return x
                }
              }

              MyClass obj = new MyClass()
              int result = obj.my_func()"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('result').value, 5)
  end

  def test_method_call_with_params
    input = "class MyClass {
                int x = 5
                func int my_func(int t) {
                  return x * t
                }
              }

              MyClass obj = new MyClass()
              int result = obj.my_func(3)"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('result').value, 15)
  end

  def test_property_call
    input = "class MyClass {
                int x = 5
              }

              MyClass obj = new MyClass()
              int result = obj.x"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('result').value, 5)
  end

  def test_property_reassign
    input = "class MyClass {
                int x = 5
              }

              MyClass obj = new MyClass()
              obj.x = 100
              int result = obj.x"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('result').value, 100)
  end
end
