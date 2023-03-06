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
        assert_equal(NODE_TYPES[:Identifier], ast.body[0].left.type)
        assert_equal("x", ast.body[0].left.symbol)
    end

    def test_parens_grouping
        ast = @parser.produceAST("(3 + 3) * 4")
        assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
        assert_equal(:*, ast.body[0].op) # Is higher up in the ast so has lower precedence
        assert_equal(4, ast.body[0].right.value)
        additionExpr = ast.body[0].left # Extract the addition expr for easier testing
        assert_equal(NODE_TYPES[:BinaryExpr], additionExpr.type)
        assert_equal(3, additionExpr.left.value)
        assert_equal(3, additionExpr.right.value)
        assert_equal(:+, additionExpr.op)

        ast = @parser.produceAST("(3 * (3 - 4)) * 4")
        assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
        assert_equal(:*, ast.body[0].op) # Is higher up in the ast so has lower precedence
        assert_equal(4, ast.body[0].right.value)
        firstParens = ast.body[0].left # Extract the addition expr for easier testing
        assert_equal(NODE_TYPES[:BinaryExpr], firstParens.type)
        assert_equal(3, firstParens.left.value)
        assert_equal(:*, firstParens.op)
        secondParens = firstParens.right
        assert_equal(NODE_TYPES[:BinaryExpr], secondParens.type)
        assert_equal(3, secondParens.left.value)
        assert_equal(4, secondParens.right.value)
        assert_equal(:-, secondParens.op)
    end

    def test_operator_precedence
        # Test addition and multiplication
        ast = @parser.produceAST("1 + 2 * 3")
        assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
        assert_equal(:+, ast.body[0].op)
        assert_equal(1, ast.body[0].left.value)
        multiplicationExpr = ast.body[0].right
        assert_equal(NODE_TYPES[:BinaryExpr], multiplicationExpr.type)
        assert_equal(:*, multiplicationExpr.op)
        assert_equal(2, multiplicationExpr.left.value)
        assert_equal(3, multiplicationExpr.right.value)

        # Test addition and division
        ast = @parser.produceAST("1 + 2 / 3")
        assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
        assert_equal(:+, ast.body[0].op)
        assert_equal(1, ast.body[0].left.value)
        divisionExpr = ast.body[0].right
        assert_equal(NODE_TYPES[:BinaryExpr], divisionExpr.type)
        assert_equal(:/, divisionExpr.op)
        assert_equal(2, divisionExpr.left.value)
        assert_equal(3, divisionExpr.right.value)

        # Test multiplication and division are read from left to right
        ast = @parser.produceAST("1 * 2 / 3")
        assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
        assert_equal(:/, ast.body[0].op)
        multiplicationExpr = ast.body[0].left
        assert_equal(NODE_TYPES[:BinaryExpr], multiplicationExpr.type)
        assert_equal(:*, multiplicationExpr.op)
        assert_equal(1, multiplicationExpr.left.value)
        assert_equal(2, multiplicationExpr.right.value)
        assert_equal(3, ast.body[0].right.value)

        # Test addition, divition with unary
        ast = @parser.produceAST("1 + 2 / -3")
        assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
        assert_equal(:+, ast.body[0].op)
        assert_equal(1, ast.body[0].left.value)
        divisionExpr = ast.body[0].right
        assert_equal(NODE_TYPES[:BinaryExpr], divisionExpr.type)
        assert_equal(:/, divisionExpr.op)
        assert_equal(2, divisionExpr.left.value)
        unaryExpr = divisionExpr.right
        assert_equal(NODE_TYPES[:UnaryExpr], unaryExpr.type)
        assert_equal(:-, unaryExpr.op)
        assert_equal(3, unaryExpr.left.value)
    end

    def test_invalid_expression
        assert_raise(InvalidTokenError) {@parser.produceAST("4 + 3 *")}
    end
end