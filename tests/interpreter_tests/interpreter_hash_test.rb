require 'test/unit'
require_relative '../../runtime/interpreter'

class TestInterpreterHash < Test::Unit::TestCase
  def setup
    @parser = Parser.new
    @interpreter = Runtime::Interpreter.new
    @env = Runtime::Environment.new
  end

  def test_interpret_hash_declaration
    input = "Hash<string, string> my_hash = Hash<string, string>{ 'a'='A', 'b'='B' }
            my_hash"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_instance_of(Runtime::Values::HashVal, result)
    assert_equal(%w[a b], result.value.keys)
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

    assert_instance_of(Runtime::Values::StringVal, result)
    assert_equal('A', result.value)
  end

  def test_interpret_hash_access_with_missing_key
    input = "Hash<string, string> my_hash = Hash<string, string>{ 'a'='A' }
             my_hash['b']"
    ast = @parser.produce_ast(input)

    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end

  def test_interpret_hash_access_with_wrong_key_type
    input = "Hash<string, string> my_hash = Hash<string, string>{ 'a'='A' }
             my_hash[2]"
    ast = @parser.produce_ast(input)

    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end

  def test_interpret_hash_assignment
    input = "Hash<string, int> my_hash = Hash<string, int>{ 'a'=1 }
             my_hash['b'] = 2
             my_hash['b']"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_instance_of(Runtime::Values::NumberVal, result)
    assert_equal(2, result.value)
    hash = @env.lookup_identifier('my_hash').value
    assert_equal(2, hash.length)
    assert_equal(1, hash['a'].value)
    assert_equal(2, hash['b'].value)
  end

  def test_interpret_hash_of_hashes_declaration
    input = "Hash<string, Hash<string, int>> a = Hash<string, Hash<string, int>>{ 'hash1' = Hash<string, int>{ 'a' = 1, 'b' = 2 }, 'hash2' = Hash<string, int>{ 'c' = 3, 'd' = 4 } }
            a"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_instance_of(Runtime::Values::HashVal, result)
    assert_equal(%w[hash1 hash2], result.value.keys)
    values = result.value
    assert_equal(2, values.length)

    hash1 = values['hash1'].value
    assert_equal(2, hash1.length)
    assert_equal(1, hash1['a'].value)
    assert_equal(2, hash1['b'].value)

    hash2 = values['hash2'].value
    assert_equal(2, hash2.length)
    assert_equal(3, hash2['c'].value)
    assert_equal(4, hash2['d'].value)
  end

  def test_interpret_hash_of_hashes_access
    input = "Hash<string, Hash<string, int>> a = Hash<string, Hash<string, int>>{ 'hash1' = Hash<string, int>{ 'a' = 1, 'b' = 2 }, 'hash2' = Hash<string, int>{ 'c' = 3, 'd' = 4 } }
             a['hash1']['a']"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_instance_of(Runtime::Values::NumberVal, result)
    assert_equal(1, result.value)
  end

  def test_interpret_hash_of_hashes_access_with_missing_key
    input = "Hash<string, Hash<string, int>> a = Hash<string, Hash<string, int>>{ 'hash1' = Hash<string, int>{ 'a' = 1, 'b' = 2 } }
             a['hash2']['c']"
    ast = @parser.produce_ast(input)

    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end

  def test_interpret_hash_of_hashes_access_with_wrong_key_type
    input = "Hash<string, Hash<string, int>> a = Hash<string, Hash<string, int>>{ 'hash1' = Hash<string, int>{ 'a' = 1, 'b' = 2 } }
             a[2]['a']"
    ast = @parser.produce_ast(input)

    assert_raise(RuntimeError) { @interpreter.evaluate(ast, @env) }
  end

  def test_interpret_hash_of_hashes_assignment
    input = "Hash<string, Hash<string, int>> a = Hash<string, Hash<string, int>>{ 'hash1' = Hash<string, int>{ 'a' = 1, 'b' = 2 } }
             a['hash2'] = Hash<string, int>{ 'c' = 3, 'd' = 4 }
             a"
    ast = @parser.produce_ast(input)
    result = @interpreter.evaluate(ast, @env)

    assert_instance_of(Runtime::Values::HashVal, result)

    assert_equal(%w[hash1 hash2], result.keys.value)

    hash2 = result.value['hash2'].value
    assert_equal(2, hash2.length)
    assert_equal(3, hash2['c'].value)
    assert_equal(4, hash2['d'].value)
  end
end
