# frozen_string_literal: true

require 'test/unit'
require_relative '../../parser/parser'

class TestParserExpressions < Test::Unit::TestCase
  def setup
    @parser = Parser.new
  end

  def test_parse_reassign_expression
    ast = @parser.produce_ast('x = 2')
    assert_equal(ast.body[0].assigne.symbol, 'x')
    assert_equal(ast.body[0].value.value, 2)

    # Try assign another variable to y
    ast = @parser.produce_ast('y = x')
    assert_equal(ast.body[0].assigne.symbol, 'y')
    assert_equal(ast.body[0].value.symbol, 'x')
  end

  def test_parse_binary_expression
    ast = @parser.produce_ast('1 + 2 * 3')
    assert_equal(ast.body[0].left.value, 1)
    assert_equal(ast.body[0].op, :+)
    assert_equal(ast.body[0].right.left.value, 2)
    assert_equal(ast.body[0].right.op, :*)
    assert_equal(ast.body[0].right.right.value, 3)
  end

  def test_parse_addition_expression
    ast = @parser.produce_ast('1 + 2')
    assert_equal(ast.body[0].left.value, 1)
    assert_equal(ast.body[0].op, :+)
    assert_equal(ast.body[0].right.value, 2)
  end

  def test_parse_subtraction_expression
    ast = @parser.produce_ast('10 - 5')
    assert_equal(ast.body[0].left.value, 10)
    assert_equal(ast.body[0].op, :-)
    assert_equal(ast.body[0].right.value, 5)
  end

  def test_parse_multiplication_expression
    ast = @parser.produce_ast('3 * 4')
    assert_equal(ast.body[0].left.value, 3)
    assert_equal(ast.body[0].op, :*)
    assert_equal(ast.body[0].right.value, 4)
  end

  def test_parse_division_expression
    ast = @parser.produce_ast('8 / 2')
    assert_equal(ast.body[0].left.value, 8)
    assert_equal(ast.body[0].op, :/)
    assert_equal(ast.body[0].right.value, 2)
  end

  def test_parse_modulo_expression
    ast = @parser.produce_ast('7 % 3')
    assert_equal(ast.body[0].left.value, 7)
    assert_equal(ast.body[0].op, :%)
    assert_equal(ast.body[0].right.value, 3)
  end

  def test_parse_unary_expression
    ast = @parser.produce_ast('-3')
    assert_equal(NODE_TYPES[:UnaryExpr], ast.body[0].type)
    assert_equal(:-, ast.body[0].op)
    assert_equal(3, ast.body[0].left.value)

    ast = @parser.produce_ast('-3 * 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(NODE_TYPES[:UnaryExpr], ast.body[0].left.type)
    assert_equal(:-, ast.body[0].left.op)
    assert_equal(3, ast.body[0].left.left.value)
    assert_equal(:*, ast.body[0].op)
    assert_equal(4, ast.body[0].right.value)

    # Test unary on vars
    ast = @parser.produce_ast('-x')
    assert_equal(NODE_TYPES[:UnaryExpr], ast.body[0].type)
    assert_equal(:-, ast.body[0].op)
    assert_equal(NODE_TYPES[:Identifier], ast.body[0].left.type)
    assert_equal('x', ast.body[0].left.symbol)
  end

  def test_parens_grouping
    ast = @parser.produce_ast('(3 + 3) * 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(:*, ast.body[0].op) # Is higher up in the ast so has lower precedence
    assert_equal(4, ast.body[0].right.value)
    addition_expr = ast.body[0].left # Extract the addition expr for easier testing
    assert_equal(NODE_TYPES[:BinaryExpr], addition_expr.type)
    assert_equal(3, addition_expr.left.value)
    assert_equal(3, addition_expr.right.value)
    assert_equal(:+, addition_expr.op)

    ast = @parser.produce_ast('(3 * (3 - 4)) * 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(:*, ast.body[0].op) # Is higher up in the ast so has lower precedence
    assert_equal(4, ast.body[0].right.value)
    first_parens = ast.body[0].left # Extract the addition expr for easier testing
    assert_equal(NODE_TYPES[:BinaryExpr], first_parens.type)
    assert_equal(3, first_parens.left.value)
    assert_equal(:*, first_parens.op)
    second_parens = first_parens.right
    assert_equal(NODE_TYPES[:BinaryExpr], second_parens.type)
    assert_equal(3, second_parens.left.value)
    assert_equal(4, second_parens.right.value)
    assert_equal(:-, second_parens.op)
  end

  def test_operator_precedence
    # Test addition and multiplication
    ast = @parser.produce_ast('1 + 2 * 3')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(:+, ast.body[0].op)
    assert_equal(1, ast.body[0].left.value)
    multiplication_expr = ast.body[0].right
    assert_equal(NODE_TYPES[:BinaryExpr], multiplication_expr.type)
    assert_equal(:*, multiplication_expr.op)
    assert_equal(2, multiplication_expr.left.value)
    assert_equal(3, multiplication_expr.right.value)

    # Test addition and division
    ast = @parser.produce_ast('1 + 2 / 3')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(:+, ast.body[0].op)
    assert_equal(1, ast.body[0].left.value)
    division_expr = ast.body[0].right
    assert_equal(NODE_TYPES[:BinaryExpr], division_expr.type)
    assert_equal(:/, division_expr.op)
    assert_equal(2, division_expr.left.value)
    assert_equal(3, division_expr.right.value)

    # Test multiplication and division are read from left to right
    ast = @parser.produce_ast('1 * 2 / 3')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(:/, ast.body[0].op)
    multiplication_expr = ast.body[0].left
    assert_equal(NODE_TYPES[:BinaryExpr], multiplication_expr.type)
    assert_equal(:*, multiplication_expr.op)
    assert_equal(1, multiplication_expr.left.value)
    assert_equal(2, multiplication_expr.right.value)
    assert_equal(3, ast.body[0].right.value)

    # Test addition, divition with unary
    ast = @parser.produce_ast('1 + 2 / -3')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(:+, ast.body[0].op)
    assert_equal(1, ast.body[0].left.value)
    division_expr = ast.body[0].right
    assert_equal(NODE_TYPES[:BinaryExpr], division_expr.type)
    assert_equal(:/, division_expr.op)
    assert_equal(2, division_expr.left.value)
    unary_expr = division_expr.right
    assert_equal(NODE_TYPES[:UnaryExpr], unary_expr.type)
    assert_equal(:-, unary_expr.op)
    assert_equal(3, unary_expr.left.value)
  end

  def test_invalid_expression
    assert_raise(InvalidTokenError) { @parser.produce_ast('4 + 3 *') }
  end

  def test_parse_less_than_expression
    ast = @parser.produce_ast('3 < 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(3, ast.body[0].left.value)
    assert_equal(:<, ast.body[0].op)
    assert_equal(4, ast.body[0].right.value)
  end

  def test_parse_less_than_or_equal_to_expression
    ast = @parser.produce_ast('3 <= 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(3, ast.body[0].left.value)
    assert_equal(:<=, ast.body[0].op)
    assert_equal(4, ast.body[0].right.value)
  end

  def test_parse_greater_than_expression
    ast = @parser.produce_ast('3 > 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(3, ast.body[0].left.value)
    assert_equal(:>, ast.body[0].op)
    assert_equal(4, ast.body[0].right.value)
  end

  def test_parse_greater_than_or_equal_to_expression
    ast = @parser.produce_ast('3 >= 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(3, ast.body[0].left.value)
    assert_equal(:>=, ast.body[0].op)
    assert_equal(4, ast.body[0].right.value)
  end

  def test_parse_equality_expression
    ast = @parser.produce_ast('3 == 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(3, ast.body[0].left.value)
    assert_equal(:==, ast.body[0].op)
    assert_equal(4, ast.body[0].right.value)
  end

  def test_parse_inequality_expression
    ast = @parser.produce_ast('3 != 4')
    assert_equal(NODE_TYPES[:BinaryExpr], ast.body[0].type)
    assert_equal(3, ast.body[0].left.value)
    assert_equal(:!=, ast.body[0].op)
    assert_equal(4, ast.body[0].right.value)
  end

  def test_parse_logical_and_expression
    ast = @parser.produce_ast('true && false')
    assert_equal(NODE_TYPES[:LogicalAnd], ast.body[0].type)
    assert_equal(:"&&", ast.body[0].op)
    assert_equal(true, ast.body[0].left.value)
    assert_equal(false, ast.body[0].right.value)
  end

  def test_parse_logical_or_expression
    ast = @parser.produce_ast('true || false')
    assert_equal(NODE_TYPES[:LogicalOr], ast.body[0].type)
    assert_equal(:"||", ast.body[0].op)
    assert_equal(true, ast.body[0].left.value)
    assert_equal(false, ast.body[0].right.value)
  end

  def test_parse_logical_not_expression
    ast = @parser.produce_ast('!true')
    assert_equal(NODE_TYPES[:UnaryExpr], ast.body[0].type)
    assert_equal(:!, ast.body[0].op)
    assert_equal(true, ast.body[0].left.value)

    ast = @parser.produce_ast('!(true && false)')
    assert_equal(NODE_TYPES[:UnaryExpr], ast.body[0].type)
    assert_equal(:!, ast.body[0].op)
    assert_equal(NODE_TYPES[:LogicalAnd], ast.body[0].left.type)
    assert_equal(true, ast.body[0].left.left.value)
    assert_equal(false, ast.body[0].left.right.value)
  end
end
