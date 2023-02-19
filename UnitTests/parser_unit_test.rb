require 'test/unit'
require_relative '../Parser/Parser.rb'

class TestParser < Test::Unit::TestCase
    def setup
        @parser = Parser.new()
    end
    
    def test_parse_variable_declaration
        ast = @parser.produceAST("let x = 1")
        assert_equal(ast.body[0].identifier, "x")
        assert_equal(ast.body[0].value.value, 1)
        assert_equal(ast.body[0].constant, false)
    end

    def test_parse_variable_declaration_without_assign
        ast = @parser.produceAST("let y")
        assert_equal(ast.body[0].identifier, "y")
        assert_equal(ast.body[0].value, nil)
        assert_equal(ast.body[0].constant, false)
    end

    def test_parse_constant_declaration
        ast = @parser.produceAST("const x = 1")
        assert_equal(ast.body[0].identifier, "x")
        assert_equal(ast.body[0].value.value, 1)
        assert_equal(ast.body[0].constant, true)
    end

    def test_parse_reassign_expression
        ast = @parser.produceAST("x = 2")
        assert_equal(ast.body[0].assigne.symbol, "x")
        assert_equal(ast.body[0].value.value, 2)

        # Try assign another variable to y
        ast = @parser.produceAST("y = x")
        assert_equal(ast.body[0].assigne.symbol, "y")
        assert_equal(ast.body[0].value.symbol, "x")
    end

    def test_parse_binary_expression
        ast = @parser.produceAST("1 + 2 * 3")
        assert_equal(ast.body[0].left.value, 1)
        assert_equal(ast.body[0].op, :+)
        assert_equal(ast.body[0].right.left.value, 2)
        assert_equal(ast.body[0].right.op, :*)
        assert_equal(ast.body[0].right.right.value, 3)
    end

    def test_parse_missing_identifier
        assert_raise(RuntimeError) { @parser.produceAST("let = 1") }
    end

    def test_parse_missing_value_on_constant
        assert_raise(NameError) { @parser.produceAST("const x ") }
    end
    
    def test_parse_missing_value
        assert_raise(InvalidTokenError) { @parser.produceAST("let x = ") }
    end
    
    def test_parse_unknown_token
        assert_raise(InvalidTokenError) { @parser.produceAST("let x @ 1") }
    end
end