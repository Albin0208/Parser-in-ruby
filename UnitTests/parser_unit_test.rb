require 'test/unit'
require_relative '../Parser/Parser.rb'

class TestParser < Test::Unit::TestCase
    def setup
        @parser = Parser.new()
    end
    
    def test_parse_variable_declaration
        ast = @parser.produceAST("int x = 1")
        assert_equal(ast.body[0].identifier, "x")
        assert_equal(ast.body[0].value.value, 1)
        assert_equal(ast.body[0].constant, false)

        # Test for declaration of var to valu of another var
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

    def test_parse_if_statment
        ast = @parser.produceAST("if 3 < 4 { int a = 4}")
        p ast.body
        assert_equal(NODE_TYPES[:IF], ast.body[0].type)
        body = ast.body[0].body
        assert_equal(NODE_TYPES[:VarDeclaration], body[0].type)
        assert_equal("a", body[0].identifier)
        assert_equal(4, body[0].value.value)
        conditions = ast.body[0].conditions
        assert_equal(NODE_TYPES[:BinaryExpr], conditions.type)

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
    end

    def test_parse_missing_identifier
        assert_raise(RuntimeError) { @parser.produceAST("int = 1") }
    end

    def test_parse_missing_type_specifier_on_constant
        assert_raise(RuntimeError) { @parser.produceAST("const a = 1") }
    end

    def test_parse_missing_value_on_constant
        assert_raise(NameError) { @parser.produceAST("const float x ") }
    end
    
    def test_parse_missing_value
        assert_raise(InvalidTokenError) { @parser.produceAST("float x = ") }
    end
    
    def test_parse_unknown_token
        assert_raise(InvalidTokenError) { @parser.produceAST("int x @ 1") }
    end
end