require 'test/unit'
require_relative '../../Parser/Parser.rb'

class TestParserControlStatements < Test::Unit::TestCase
    def setup
        @parser = Parser.new()
    end
    
    def test_parse_if_statment
        ast = @parser.produceAST("if 3 < 4 { int a = 4}")
        assert_equal(NODE_TYPES[:IF], ast.body[0].type)
        body = ast.body[0].body
        assert_equal(NODE_TYPES[:VarDeclaration], body[0].type)
        assert_equal("a", body[0].identifier)
        assert_equal(4, body[0].value.value)
        conditions = ast.body[0].conditions
        assert_equal(NODE_TYPES[:BinaryExpr], conditions.type)

        # Assert tha else body is not set
        assert_nil(ast.body[0].else_body)

        # Test with multiple statements in body
        ast = @parser.produceAST("if 3 < 4 { int a = 4 a = 4 - 3}")
        assert_equal(2, ast.body[0].body.length) # Make sure we got two stmts in the body
        assert_equal(NODE_TYPES[:IF], ast.body[0].type)
        body = ast.body[0].body
        assert_equal(NODE_TYPES[:VarDeclaration], body[0].type)
        assert_equal("a", body[0].identifier)
        assert_equal(4, body[0].value.value)
        conditions = ast.body[0].conditions
        assert_equal(NODE_TYPES[:BinaryExpr], conditions.type)

        # Test with multiple statements in condition
        ast = @parser.produceAST("if 3 < 4 && 4 > 3 { int a = 4 a = 4 - 3}")
        conditions = ast.body[0].conditions
        assert_equal(NODE_TYPES[:LogicalAnd], conditions.type)
        assert_equal(NODE_TYPES[:BinaryExpr], conditions.left.type)
        assert_equal(NODE_TYPES[:BinaryExpr], conditions.right.type)

        # Test with multiple statements in condition
        ast = @parser.produceAST("if 3 < 4 && 4 > 3 && 3 != 4 { int a = 4 a = 4 - 3}")
        conditions = ast.body[0].conditions
        assert_equal(NODE_TYPES[:LogicalAnd], conditions.type)
        assert_equal(NODE_TYPES[:LogicalAnd], conditions.left.type)
        assert_equal(NODE_TYPES[:BinaryExpr], conditions.right.type)
    end

    def test_parse_if_else_statement
        ast = @parser.produceAST("if 3 < 4 { int a = 4} else {int a = 4 * 3}")
        assert_equal(NODE_TYPES[:IF], ast.body[0].type)
        assert_not_nil(ast.body[0].else_body)
        body = ast.body[0].else_body
        assert_equal(NODE_TYPES[:VarDeclaration], body[0].type)
        assert_equal("a", body[0].identifier)
        assert_equal(4, body[0].value.left.value)
    end


end