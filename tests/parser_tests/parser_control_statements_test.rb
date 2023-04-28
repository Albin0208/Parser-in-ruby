require 'test/unit'
require_relative '../../parser/parser'

class TestParserControlStatements < Test::Unit::TestCase
  def setup
    @parser = Parser.new
  end

  def test_parse_if_statment
    ast = @parser.produce_ast('if 3 < 4 { int a = 4}')
    assert_equal(NODE_TYPES[:IF], ast.body[0].type)
    body = ast.body[0].body
    assert_equal(NODE_TYPES[:VarDeclaration], body[0].type)
    assert_equal('a', body[0].identifier)
    assert_equal(4, body[0].value.value)
    conditions = ast.body[0].conditions
    assert_equal(NODE_TYPES[:BinaryExpr], conditions.type)

    # Assert tha else body is not set
    assert_nil(ast.body[0].else_body)

    # Test with multiple statements in body
    ast = @parser.produce_ast('if 3 < 4 { int a = 4 a = 4 - 3}')
    assert_equal(2, ast.body[0].body.length) # Make sure we got two stmts in the body
    assert_equal(NODE_TYPES[:IF], ast.body[0].type)
    body = ast.body[0].body
    assert_equal(NODE_TYPES[:VarDeclaration], body[0].type)
    assert_equal('a', body[0].identifier)
    assert_equal(4, body[0].value.value)
    conditions = ast.body[0].conditions
    assert_equal(NODE_TYPES[:BinaryExpr], conditions.type)

    # Test with multiple statements in condition
    ast = @parser.produce_ast('if 3 < 4 && 4 > 3 { int a = 4 a = 4 - 3}')
    conditions = ast.body[0].conditions
    assert_equal(NODE_TYPES[:LogicalAnd], conditions.type)
    assert_equal(NODE_TYPES[:BinaryExpr], conditions.left.type)
    assert_equal(NODE_TYPES[:BinaryExpr], conditions.right.type)

    # Test with multiple statements in condition
    ast = @parser.produce_ast('if 3 < 4 && 4 > 3 && 3 != 4 { int a = 4 a = 4 - 3}')
    conditions = ast.body[0].conditions
    assert_equal(NODE_TYPES[:LogicalAnd], conditions.type)
    assert_equal(NODE_TYPES[:LogicalAnd], conditions.left.type)
    assert_equal(NODE_TYPES[:BinaryExpr], conditions.right.type)
  end

  def test_parse_single_elsif_statements
    # Test if with one else if
    ast = @parser.produce_ast('if 3 < 4 { int a = 4} elsif 3 > 4 {int a = 4 * 3}')
    assert_equal(NODE_TYPES[:IF], ast.body[0].type)
    assert_nil(ast.body[0].else_body)
    assert_not_nil(ast.body[0].elsif_stmts)
    conditions = ast.body[0].elsif_stmts[0].conditions
    assert_equal(NODE_TYPES[:BinaryExpr], conditions.type)
    body = ast.body[0].elsif_stmts[0].body
    assert_equal(NODE_TYPES[:VarDeclaration], body[0].type)
    assert_equal('a', body[0].identifier)
    assert_equal(4, body[0].value.left.value)
  end

  def test_parse_multiple_elsif_statements
    ast = @parser.produce_ast('if 3 < 4 { int a = 4} elsif 3 > 4 {int a = 4 * 3} elsif 3 == 4 { 3 + 3}')
    assert_equal(NODE_TYPES[:IF], ast.body[0].type)
    assert_nil(ast.body[0].else_body)
    assert_not_nil(ast.body[0].elsif_stmts)
    assert_equal(2, ast.body[0].elsif_stmts.length) # Make sure we have 2 elsifs

    ast = @parser.produce_ast('if 3 < 4 { int a = 4} elsif 3 > 4 {int a = 4 * 3} elsif 3 == 4 { 3 + 3} elsif 3 == 4 { 3 + 3}')
    assert_equal(NODE_TYPES[:IF], ast.body[0].type)
    assert_nil(ast.body[0].else_body)
    assert_not_nil(ast.body[0].elsif_stmts)
    assert_equal(3, ast.body[0].elsif_stmts.length) # Make sure we have 2 elsifs
  end

  def test_parse_if_else_statement
    ast = @parser.produce_ast('if 3 < 4 { int a = 4} else {int a = 4 * 3}')
    assert_equal(NODE_TYPES[:IF], ast.body[0].type)
    assert_not_nil(ast.body[0].else_body)
    body = ast.body[0].else_body
    assert_equal(NODE_TYPES[:VarDeclaration], body[0].type)
    assert_equal('a', body[0].identifier)
    assert_equal(4, body[0].value.left.value)
  end
  
  def test_parse_if_elsif_else_statement
    ast = @parser.produce_ast('if 3 < 4 { int a = 4} elsif 3 > 4 { 3 + 3 } else {int a = 4 * 3}')
    assert_equal(NODE_TYPES[:IF], ast.body[0].type)
    assert_not_nil(ast.body[0].else_body)
    assert_not_nil(ast.body[0].elsif_stmts)
  end

  def test_parse_while_loop
    ast = @parser.produce_ast('while i < 10 { i = i + 1 }')
    assert_equal(NODE_TYPES[:WHILE_LOOP], ast.body[0].type)
    condition = ast.body[0].conditions
    assert_instance_of(BinaryExpr, condition)
    assert_equal(:<, condition.op)
    assert_equal('i', condition.left.symbol)
    assert_equal(10, condition.right.value)
    body = ast.body[0].body[0]
    assert_instance_of(AssignmentStmt, body)
    assert_equal('i', body.assigne.symbol)
    assign_expr = body.value
    assert_instance_of(BinaryExpr, assign_expr)
    assert_equal(:+, assign_expr.op)
    assert_equal('i', assign_expr.left.symbol)
    assert_equal(1, assign_expr.right.value)
  end 
end
