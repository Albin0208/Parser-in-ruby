require 'test/unit'
require_relative '../../parser/parser'

class TestParserHashDeclarations < Test::Unit::TestCase
  def setup
    @parser = Parser.new
  end

  def test_parse_hash_declaration_without_assignment
    input = "Hash<string, int> MY_HASH"
    declaration = @parser.produce_ast(input).body[0]

    assert_equal(false, declaration.constant)
    assert_equal("MY_HASH", declaration.identifier)
    assert_equal(:string, declaration.key_type)
    assert_equal(:int, declaration.value_type)
    assert_nil(declaration.value)
  end

  def test_parse_hash_declaration_with_assignment_to_hash_literal
    input = "Hash<string, string> my_hash = Hash<string, string>{ 'a'='A', 'b'='B' }"
    declaration = @parser.produce_ast(input).body[0]

    assert_equal(false, declaration.constant)
    assert_equal("my_hash", declaration.identifier)
    assert_equal(:string, declaration.key_type)
    assert_equal(:string, declaration.value_type)
    hash_literal =  declaration.value
    assert_not_nil(hash_literal)
    assert_equal(2, hash_literal.key_value_pairs.length)

    # Check the key value pairs to match
    pair_1 = hash_literal.key_value_pairs[0]
    assert_equal('a', pair_1[:key].value)
    assert_equal('A', pair_1[:value].value)
    pair_2 = hash_literal.key_value_pairs[1]
    assert_equal('b', pair_2[:key].value)
    assert_equal('B', pair_2[:value].value)
  end

  def test_parse_const_hash_declaration_with_assignment_to_hash_literal
    input = "const Hash<string, string> my_hash = Hash<string, string>{ 'a'='A', 'b'='B' }"
    declaration = @parser.produce_ast(input).body[0]

    assert_equal(true, declaration.constant)
    assert_equal("my_hash", declaration.identifier)
    assert_equal(:string, declaration.key_type)
    assert_equal(:string, declaration.value_type)
  end

  def test_parse_hash_declaration_with_assignment_to_func_call
    input = "Hash<string, int> my_hash = some_func(arg1, arg2)"
    declaration = @parser.produce_ast(input).body[0]

    assert_equal(false, declaration.constant)
    assert_equal("my_hash", declaration.identifier)
    assert_equal(:string, declaration.key_type)
    assert_equal(:int, declaration.value_type)
    assert_not_nil(declaration.value)

    func_call = declaration.value
    assert_equal("some_func", func_call.func_name.symbol)
    assert_equal(2, func_call.params.length)
  end

  def test_parse_mismatched_hash_types
    input = "const Hash<string, int> MY_HASH Hash<string, string>{ 'a'='A', 'b'='B' }"
    assert_raise(NameError) { @parser.produce_ast(input) }
  end

  def test_parse_hash_declaration_with_uninitialized_const
    input = "const Hash<string, int> MY_HASH"
    assert_raise(NameError) { @parser.produce_ast(input) }
  end
end
