require 'test/unit'
require_relative '../../parser/parser'

class TestParserVarDeclarations < Test::Unit::TestCase
  def setup
    @parser = Parser.new
  end

  def test_parse_variable_declaration
    ast = @parser.produce_ast('int x = 1')
    assert_equal(ast.body[0].identifier, 'x')
    assert_equal(ast.body[0].value.value, 1)
    assert_equal(ast.body[0].constant, false)

    ast = @parser.produce_ast('int x = 3 + 4')
    assert_equal(ast.body[0].identifier, 'x')
    # assert_equal(ast.body[0].value.value, 1)
    assert_equal(ast.body[0].constant, false)

    # Test for declaration of var to value of another var
    ast = @parser.produce_ast('int a = x')
    assert_equal(ast.body[0].identifier, 'a')
    assert_equal(ast.body[0].value.symbol, 'x')
    assert_equal(ast.body[0].constant, false)

    # Test for declaration of var to value of another var
    ast = @parser.produce_ast('string a = "Hej"')
    assert_equal(ast.body[0].identifier, 'a')
    assert_equal(ast.body[0].value.value, 'Hej')
    assert_equal(ast.body[0].constant, false)
  end

  def test_parse_variable_declaration_without_assign
    ast = @parser.produce_ast('int y')
    assert_equal(ast.body[0].identifier, 'y')
    assert_equal(ast.body[0].value, nil)
    assert_equal(ast.body[0].constant, false)

    ast = @parser.produce_ast('float v')
    assert_equal(ast.body[0].identifier, 'v')
    assert_equal(ast.body[0].value, nil)
    assert_equal(ast.body[0].constant, false)
    assert_equal(ast.body[0].value_type, 'float')
  end

  def test_parse_class_declaration
    ast = @parser.produce_ast('Test x = new Test()')
    assert_equal('x', ast.body[0].identifier)
    assert_equal('Test', ast.body[0].value.value.symbol)
    assert_equal(ast.body[0].constant, false)
  end

  def test_parse_constant_declaration
    ast = @parser.produce_ast('const int x = 1')
    assert_equal(ast.body[0].identifier, 'x')
    assert_equal(ast.body[0].value.value, 1)
    assert_equal(ast.body[0].constant, true)
  end

  def test_parse_missing_value
    assert_raise(InvalidTokenError) { @parser.produce_ast('float x = ') }
  end

  def test_parse_missing_identifier
    assert_raise(RuntimeError) { @parser.produce_ast('int = 1') }
  end

  def test_parse_mismatched_type_on_var_declaration
    assert_raise(InvalidTokenError) { @parser.produce_ast('int a = true') }
    assert_raise(InvalidTokenError) { @parser.produce_ast('bool a = 40') }
  end

  def test_parse_unknown_token
    assert_raise(InvalidTokenError) { @parser.produce_ast('int x @ 1') }
  end

  def test_parse_missing_type_specifier_on_constant
    assert_raise(RuntimeError) { @parser.produce_ast('const a = 1') }
  end

  def test_parse_missing_value_on_constant
    assert_raise(NameError) { @parser.produce_ast('const float x ') }
  end

  def test_parse_declaring_with_invalid_var_names
    assert_raise(RuntimeError) { @parser.produce_ast('int if = 4') }
    assert_raise(RuntimeError) { @parser.produce_ast('int 123 = 4') }
  end

  def test_parse_class
    input = "class Test {
                int var = 1
                int var2 = 100

                func void hello() {
                  print('Hello world')
                }
             }"

    ast = @parser.produce_ast(input)
    class_decl = ast.body[0]

    assert_instance_of(Nodes::ClassDeclaration, class_decl)
    assert_equal('Test', class_decl.class_name.symbol)
    member_vars = class_decl.member_variables
    member_func = class_decl.member_functions
    assert_equal(2, member_vars.length)
    assert_equal(1, member_func.length)
    assert_instance_of(Nodes::VarDeclaration, member_vars[0])
    assert_equal('var', member_vars[0].identifier)
    assert_equal(1, member_vars[0].value.value)
    assert_instance_of(Nodes::VarDeclaration, member_vars[1])
    assert_equal('var2', member_vars[1].identifier)
    assert_equal(100, member_vars[1].value.value)

    assert_instance_of(Nodes::FuncDeclaration, member_func[0])
    assert_equal('hello', member_func[0].identifier)
  end
end
