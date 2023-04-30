require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterClass < Test::Unit::TestCase
  def setup
    @parser = Parser.new()
    @interpreter = Interpreter.new
    @env = Environment.new
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

    assert_equal(@env.lookup_identifier('MyClass').class, ClassDeclaration)
    assert_equal(@env.lookup_identifier('MyClass').member_variables.first.value.value, 5)
    assert_equal(@env.lookup_identifier('MyClass').member_functions.first.identifier, 'my_func')
    assert_equal(@env.lookup_identifier('MyClass').env.lookup_identifier('x').value, 5)
  end

  def test_class_instantiation
    input = "class MyClass { 
                int x = 5
                func int my_func() {
                  return x
                } 
              }

              MyClass obj = new MyClass"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('obj').class, ClassVal)
    assert_equal(@env.lookup_identifier('obj').type.to_s, @env.lookup_identifier('MyClass').class_name.symbol)
  end

  def test_method_call
    input = "class MyClass { 
                int x = 5
                func int my_func() {
                  return x
                } 
              }

              MyClass obj = new MyClass
              int result = obj.my_func()"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('result').value, 5)
  end

  def test_property_call
    input = "class MyClass { 
                int x = 5
              }

              MyClass obj = new MyClass
              int result = obj.x"
    ast = @parser.produce_ast(input)
    @interpreter.evaluate(ast, @env)

    assert_equal(@env.lookup_identifier('result').value, 5)
  end
end
