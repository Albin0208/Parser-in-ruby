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
    
      def test_parse_constant_declaration
        ast = @parser.produceAST("const x = 1")
        assert_equal(ast.body[0].identifier, "x")
        assert_equal(ast.body[0].value.value, 1)
        assert_equal(ast.body[0].constant, true)
      end
    
      def test_parse_assignment_expression
        ast = @parser.produceAST("x = 2")
        assert_equal(ast.body[0].assigne.symbol, "x")
        assert_equal(ast.body[0].value.value, 2)
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