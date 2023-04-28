require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterHash < Test::Unit::TestCase
  def setup
    @parser = Parser.new()
    @interpreter = Interpreter.new
    @env = Environment.new
  end

  def test_interpret_hash_declaration
    input = "Hash<string, string> my_hash = Hash<string, string>{ 'a'='A', 'b'='B' }"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    
    assert_instance_of(HashVal, result)
    assert_equal(['a', 'b'], result.value.keys)
    values = result.value
    assert_equal(2, values.length)
    assert_equal('A', values['a'].value)
    assert_equal('B', values['b'].value)
  end

  def test_interpret_hash_access
    input = "Hash<string, string> my_hash = Hash<string, string>{ 'a'='A', 'b'='B' }
             my_hash['a']"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_instance_of(StringVal, result)
    assert_equal('A', result.value)
  end

  def test_interpret_hash_access_with_missing_key
    input = "Hash<string, string> my_hash = Hash<string, string>{ 'a'='A' }
             my_hash['b']"
    ast = @parser.produce_ast(input)

    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end

  def test_interpret_hash_assignment
    input = "Hash<string, int> my_hash = Hash<string, int>{ 'a'=1 }
             my_hash['b'] = 2"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)
    
    assert_instance_of(HashVal, result)
    assert_equal(['a', 'b'], result.value.keys)
    values = result.value
    assert_equal(2, values.length)
    assert_equal(1, values['a'].value)
    assert_equal(2, values['b'].value)
  end

end
