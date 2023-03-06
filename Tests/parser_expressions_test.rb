require 'test/unit'
require_relative '../Parser/Parser.rb'

class TestParserExpressions < Test::Unit::TestCase
    def setup
        @parser = Parser.new()
    end
=begin
TODO 
Test for unary expressions (e.g. "-x")
Test for parentheses grouping (e.g. "(1 + 2) * 3")
Test for operator precedence (e.g. "1 + 2 * 3" vs "1 * 2 + 3")
Test for associativity of operators (e.g. "1 - 2 - 3" vs "1 - (2 - 3)")
Test for invalid expressions (e.g. "x = 1 +")
Test for expressions with variables not defined (e.g. "y = x + 2")
=end

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

    def test_parse_addition_expression
        ast = @parser.produceAST("1 + 2")
        assert_equal(ast.body[0].left.value, 1)
        assert_equal(ast.body[0].op, :+)
        assert_equal(ast.body[0].right.value, 2)
    end

    def test_parse_subtraction_expression
        ast = @parser.produceAST("10 - 5")
        assert_equal(ast.body[0].left.value, 10)
        assert_equal(ast.body[0].op, :-)
        assert_equal(ast.body[0].right.value, 5)
    end

    def test_parse_multiplication_expression
        ast = @parser.produceAST("3 * 4")
        assert_equal(ast.body[0].left.value, 3)
        assert_equal(ast.body[0].op, :*)
        assert_equal(ast.body[0].right.value, 4)
    end

    def test_parse_division_expression
        ast = @parser.produceAST("8 / 2")
        assert_equal(ast.body[0].left.value, 8)
        assert_equal(ast.body[0].op, :/)
        assert_equal(ast.body[0].right.value, 2)
    end

    def test_parse_modulo_expression
        ast = @parser.produceAST("7 % 3")
        assert_equal(ast.body[0].left.value, 7)
        assert_equal(ast.body[0].op, :%)
        assert_equal(ast.body[0].right.value, 3)
    end

    def test_parse_unary_expression
        ast = @parser.produceAST("-3")
        assert_equal(NODE_TYPES[:UnaryExpr], ast.body[0].type)
        assert_equal(:-, ast.body[0].op)
        assert_equal(3, ast.body[0].left.value)

        ast = @parser.produceAST("-3 * 4")
        assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
        assert_equal(NODE_TYPES[:UnaryExpr], ast.body[0].left.type)
        assert_equal(:-, ast.body[0].left.op)
        assert_equal(3, ast.body[0].left.left.value)
        assert_equal(:*, ast.body[0].op)
        assert_equal(4, ast.body[0].right.value)

        # Test unary on vars
        ast = @parser.produceAST("-x")
        assert_equal(NODE_TYPES[:UnaryExpr], ast.body[0].type)
        assert_equal(:-, ast.body[0].op)
        assert_equal(3, ast.body[0].left.value)
    end
end