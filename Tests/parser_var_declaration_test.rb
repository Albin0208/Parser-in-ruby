require 'test/unit'
require_relative '../Parser/Parser.rb'

class TestParserVarDeclarations < Test::Unit::TestCase
    def setup
        @parser = Parser.new()
    end

    def test_parse_variable_declaration
        ast = @parser.produceAST("int x = 1")
        assert_equal(ast.body[0].identifier, "x")
        assert_equal(ast.body[0].value.value, 1)
        assert_equal(ast.body[0].constant, false)

        # Test for declaration of var to value of another var
        ast = @parser.produceAST("int a = x")
        assert_equal(ast.body[0].identifier, "a")
        assert_equal(ast.body[0].value.symbol, "x")
        assert_equal(ast.body[0].constant, false)
    end

    def test_parse_variable_declaration_without_assign
        ast = @parser.produceAST("int y")
        assert_equal(ast.body[0].identifier, "y")
        assert_equal(ast.body[0].value, nil)
        assert_equal(ast.body[0].constant, false)

        ast = @parser.produceAST("float v")
        assert_equal(ast.body[0].identifier, "v")
        assert_equal(ast.body[0].value, nil)
        assert_equal(ast.body[0].constant, false)
        assert_equal(ast.body[0].value_type, "float")
    end

    def test_parse_constant_declaration
        ast = @parser.produceAST("const int x = 1")
        assert_equal(ast.body[0].identifier, "x")
        assert_equal(ast.body[0].value.value, 1)
        assert_equal(ast.body[0].constant, true)
    end

    def test_parse_missing_value
        assert_raise(InvalidTokenError) { @parser.produceAST("float x = ") }
    end

    def test_parse_missing_identifier
        assert_raise(RuntimeError) { @parser.produceAST("int = 1") }
    end

    def test_parse_mismatched_type_on_var_declaration
        assert_raise(InvalidTokenError) { @parser.produceAST("int a = true") }
        assert_raise(InvalidTokenError) { @parser.produceAST("bool a = 40") }
    end
            
    def test_parse_unknown_token
        assert_raise(InvalidTokenError) { @parser.produceAST("int x @ 1") }
    end

    def test_parse_missing_type_specifier_on_constant
        assert_raise(RuntimeError) { @parser.produceAST("const a = 1") }
    end

    def test_parse_missing_value_on_constant
        assert_raise(NameError) { @parser.produceAST("const float x ") }
    end
end