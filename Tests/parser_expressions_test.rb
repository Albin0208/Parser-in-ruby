require 'test/unit'
require_relative '../Parser/Parser.rb'

class TestParserExpressions < Test::Unit::TestCase
    def setup
        @parser = Parser.new()
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
end