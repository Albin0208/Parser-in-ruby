require 'test/unit'
require_relative '../../parser/parser'

class TestParserFunctions < Test::Unit::TestCase
  def setup
    @parser = Parser.new
  end

  def test_parse_missing_identifier
    assert_raise(RuntimeError) { @parser.produce_ast('func int () {}') }
    assert_raise(RuntimeError) { @parser.produce_ast('func int {}') }
  end

  def test_parse_missing_func_body
    assert_raise(RuntimeError) { @parser.produce_ast('func int a()') }
  end

  def test_parse_mismatched_type_on_var_declaration
    assert_raise(InvalidTokenError) { @parser.produce_ast('int a = true') }
    assert_raise(InvalidTokenError) { @parser.produce_ast('bool a = 40') }
  end

  def test_parse_unknown_token
    assert_raise(InvalidTokenError) { @parser.produce_ast('int x @ 1') }
  end

  def test_parse_missing_type_specifier
    assert_raise(RuntimeError) { @parser.produce_ast('func a() {}') }
  end

  def test_parse_declaring_with_invalid_func_names
    assert_raise(RuntimeError) { @parser.produce_ast('func void if() {}') }
    assert_raise(RuntimeError) { @parser.produce_ast('func void 123() {}') }
  end

  def test_parse_func_decl_with_func_decl_inside
    assert_raise(RuntimeError) { @parser.produce_ast('func void test() { func void invalid() {} }') }
  end

  def test_parse_void_function
    ast = @parser.produce_ast('func void test() { 1 }')
    body = ast.body[0]
    assert_instance_of(Nodes::FuncDeclaration, body)
    assert_equal(body.identifier, 'test')
    assert_equal(body.type_specifier, 'void')
    assert_empty(body.params)
    func_body = body.body[0]
    assert_equal(1, func_body.value)
  end

  def test_parse_type_func_without_return_stmt
    assert_raise(RuntimeError) { @parser.produce_ast('func int test() {}') }
  end

  def test_parse_func_with_return_stmt
    ast = @parser.produce_ast('func int test() { return 1 }')
    body = ast.body[0]
    assert_instance_of(Nodes::FuncDeclaration, body)
    assert_equal(body.identifier, 'test')
    assert_equal(body.type_specifier, 'int')
    assert_empty(body.params)
    assert_equal(1, body.body.length)
    return_stmt = body.body[0]
    assert_instance_of(Nodes::NumericLiteral, return_stmt.body)
    assert_equal(1, return_stmt.body.value)
  end

  def test_parse_func_call
    ast = @parser.produce_ast('test()')
    body = ast.body[0]
    assert_instance_of(Nodes::CallExpr, body)
    assert_equal('test', body.func_name.symbol)
    assert_empty(body.params)
  end

  def test_parse_func_call_with_params
    ast = @parser.produce_ast('test(bot(), 2)')
    body = ast.body[0]
    assert_instance_of(Nodes::CallExpr, body)
    assert_equal('test', body.func_name.symbol)
    params = body.params
    assert_not_empty(params)
    assert_equal(2, params.length)
    assert_instance_of(Nodes::CallExpr, params[0])
    assert_equal('bot', params[0].func_name.symbol)
    assert_empty(params[0].params)
    assert_equal(2, params[1].value)
  end
end
